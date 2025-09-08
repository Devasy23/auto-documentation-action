import json
import sys
import os
import requests
import time
import random
import ast
import re

def sanitize_prompt(prompt):
    """Sanitize prompt to prevent injection attacks and limit size"""
    if not isinstance(prompt, str):
        return ""
    
    # Remove potentially harmful content
    forbidden_patterns = ['<script>', 'javascript:', 'data:', 'eval(', 'exec(']
    sanitized = prompt
    for pattern in forbidden_patterns:
        sanitized = sanitized.replace(pattern, '')
    
    # Limit prompt size to prevent excessive API costs
    return sanitized[:15000]

def validate_generated_content(content, language):
    """Validate that generated content is syntactically correct"""
    if not content or not content.strip():
        return False, "Empty content"
    
    language = language.lower()
    
    try:
        if language == 'python':
            # Check Python syntax
            ast.parse(content)
        elif language == 'javascript' or language == 'typescript':
            # Basic TypeScript/JavaScript validation
            if not re.search(r'(function|class|interface|export|const|let|var)', content):
                return False, "No valid JS/TS constructs found"
        elif language == 'go':
            # Basic Go validation
            if not re.search(r'(func|type|var|const|package)', content):
                return False, "No valid Go constructs found"
        elif language == 'java':
            # Basic Java validation
            if not re.search(r'(class|public|private|protected|interface)', content):
                return False, "No valid Java constructs found"
        
        return True, "Valid"
    except SyntaxError as e:
        return False, f"Syntax error: {str(e)}"
    except Exception as e:
        return False, f"Validation error: {str(e)}"

def exponential_backoff_retry(func, max_retries=3):
    """Retry function with exponential backoff"""
    for attempt in range(max_retries):
        try:
            return func()
        except Exception as e:
            if attempt == max_retries - 1:
                raise e
            wait_time = (2 ** attempt) + random.uniform(0, 1)
            print(f"Attempt {attempt + 1} failed, retrying in {wait_time:.2f}s...", file=sys.stderr)
            time.sleep(wait_time)

def call_anthropic_api(prompt, max_tokens=3000):
    api_key = os.environ.get('ANTHROPIC_API_KEY')
    if not api_key:
        return None, "ANTHROPIC_API_KEY not set"

    url = "https://api.anthropic.com/v1/messages"
    headers = {
        "Content-Type": "application/json",
        "x-api-key": api_key,
        "anthropic-version": "2023-06-01"
    }
    data = {
        "model": "claude-3-sonnet-20240229",
        "max_tokens": max_tokens,
        "messages": [{"role": "user", "content": prompt}]
    }

    try:
        response = requests.post(url, headers=headers, json=data, timeout=60)
        if response.status_code == 200:
            result = response.json()
            content = result.get('content', [{}])[0].get('text', '')
            return content, None
        else:
            return None, f"HTTP {response.status_code}: {response.text[:200]}"
    except Exception as e:
        return None, str(e)

def call_gemini_api(prompt, max_tokens=3000):
    api_key = os.environ.get('GEMINI_API_KEY')
    if not api_key:
        return None, "GEMINI_API_KEY not set"

    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={api_key}"
    headers = {"Content-Type": "application/json"}
    data = {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {
            "maxOutputTokens": max_tokens,
            "temperature": 0.3
        }
    }

    try:
        response = requests.post(url, headers=headers, json=data, timeout=60)
        if response.status_code == 200:
            result = response.json()
            candidates = result.get('candidates', [])
            if candidates:
                content = candidates[0].get('content', {}).get('parts', [{}])[0].get('text', '')
                return content, None
            else:
                return None, "No candidates in response"
        else:
            return None, f"HTTP {response.status_code}: {response.text[:200]}"
    except Exception as e:
        return None, str(e)

def call_ai_api(prompt, max_tokens=3000):
    provider = os.environ.get('MODEL_PROVIDER', 'anthropic').lower()
    
    # Sanitize input
    prompt = sanitize_prompt(prompt)
    
    # Use exponential backoff for reliability
    def api_call():
        if provider == 'anthropic':
            return call_anthropic_api(prompt, max_tokens)
        elif provider == 'gemini':
            return call_gemini_api(prompt, max_tokens)
        else:
            return None, f"Unknown provider: {provider}"
    
    try:
        return exponential_backoff_retry(api_call)
    except Exception as e:
        return None, f"API call failed after retries: {str(e)}"

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python ai_api_helper.py <prompt_file> [max_tokens] [language]")
        sys.exit(1)

    prompt_file = sys.argv[1]
    max_tokens = int(sys.argv[2]) if len(sys.argv) > 2 else 3000
    language = sys.argv[3] if len(sys.argv) > 3 else "unknown"

    try:
        with open(prompt_file, 'r', encoding='utf-8') as f:
            prompt = f.read()

        content, error = call_ai_api(prompt, max_tokens)

        if error:
            print(f"ERROR: {error}", file=sys.stderr)
            sys.exit(1)
        
        # Validate generated content
        is_valid, validation_message = validate_generated_content(content, language)
        if not is_valid:
            print(f"WARNING: Generated content validation failed: {validation_message}", file=sys.stderr)
            print(f"INFO: Proceeding with unvalidated content", file=sys.stderr)
        
        print(content)
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)
