import json
import sys
import os
import requests

def call_anthropic_api(prompt, max_tokens=3000):
    """Calls the Anthropic Claude API.

    Args:
        prompt (str): The prompt to send to the API.
        max_tokens (int, optional): The maximum number of tokens to generate. Defaults to 3000.

    Returns:
        tuple: A tuple containing the API response content and an error message (or None if successful).

    Raises:
        None: This function does not raise exceptions, instead returning errors as strings.
    """
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
    """Calls the Google Gemini API.

    Args:
        prompt (str): The prompt to send to the API.
        max_tokens (int, optional): The maximum number of tokens to generate. Defaults to 3000.

    Returns:
        tuple: A tuple containing the API response content and an error message (or None if successful).

    Raises:
        None: This function does not raise exceptions, instead returning errors as strings.
    """
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
    """Calls either the Anthropic or Gemini API based on environment variable.

    Args:
        prompt (str): The prompt to send to the API.
        max_tokens (int, optional): The maximum number of tokens to generate. Defaults to 3000.

    Returns:
        tuple: A tuple containing the API response content and an error message (or None if successful).

    Raises:
        None: This function does not raise exceptions, instead returning errors as strings.
    """
    provider = os.environ.get('MODEL_PROVIDER', 'anthropic').lower()
    
    if provider == 'anthropic':
        return call_anthropic_api(prompt, max_tokens)
    elif provider == 'gemini':
        return call_gemini_api(prompt, max_tokens)
    else:
        return None, f"Unknown provider: {provider}"

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python ai_api_helper.py <prompt_file> [max_tokens]")
        sys.exit(1)
    
    prompt_file = sys.argv[1]
    max_tokens = int(sys.argv[2]) if len(sys.argv) > 2 else 3000
    
    try:
        with open(prompt_file, 'r', encoding='utf-8') as f:
            prompt = f.read()
        
        content, error = call_ai_api(prompt, max_tokens)
        
        if error:
            print(f"ERROR: {error}", file=sys.stderr)
            sys.exit(1)
        else:
            print(content)
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)
