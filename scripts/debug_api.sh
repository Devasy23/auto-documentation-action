#!/bin/bash
echo "🔍 Debugging API Configuration..."

if [ "$MODEL_PROVIDER" = "anthropic" ]; then
  # Check if Anthropic secret is set
  if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "❌ ANTHROPIC_API_KEY is not set!"
    echo "Please provide the anthropic_api_key input."
    exit 1
  fi

  echo "ANTHROPIC_API_KEY length: ${#ANTHROPIC_API_KEY}"
  echo "ANTHROPIC_API_KEY prefix: ${ANTHROPIC_API_KEY:0:10}..."

  # Test API key format
  if [[ "$ANTHROPIC_API_KEY" =~ ^sk-ant-[a-zA-Z0-9]+$ ]]; then
    echo "✅ API key format looks correct (sk-ant-...)"
  else
    echo "⚠️ API key format may be incorrect"
    echo "Expected format: sk-ant-... followed by alphanumeric characters"
  fi

  # Test basic API connectivity
  echo "🧪 Testing basic Anthropic API connectivity..."
  TEST_RESPONSE=$(curl -s -w "HTTP_STATUS:%{http_code}" -X POST https://api.anthropic.com/v1/messages \
    -H "Content-Type: application/json" \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "anthropic-version: 2023-06-01" \
    -d '{"model":"claude-3-sonnet-20240229","max_tokens":10,"messages":[{"role":"user","content":"Hello"}]}')

  TEST_HTTP_STATUS=$(echo "$TEST_RESPONSE" | grep -o "HTTP_STATUS:[0-9]*" | cut -d: -f2)

  if [ "$TEST_HTTP_STATUS" = "200" ]; then
    echo "✅ Anthropic API connectivity successful"
  else
    echo "❌ Anthropic API test failed (Status: $TEST_HTTP_STATUS)"
    exit 1
  fi

elif [ "$MODEL_PROVIDER" = "gemini" ]; then
  # Check if Gemini secret is set
  if [ -z "$GEMINI_API_KEY" ]; then
    echo "❌ GEMINI_API_KEY is not set!"
    echo "Please provide the gemini_api_key input."
    exit 1
  fi

  echo "GEMINI_API_KEY length: ${#GEMINI_API_KEY}"
  echo "GEMINI_API_KEY prefix: ${GEMINI_API_KEY:0:10}..."

  # Test basic API connectivity
  echo "🧪 Testing basic Gemini API connectivity..."
  TEST_RESPONSE=$(curl -s -w "HTTP_STATUS:%{http_code}" -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{"contents":[{"parts":[{"text":"Hello"}]}]}')

  TEST_HTTP_STATUS=$(echo "$TEST_RESPONSE" | grep -o "HTTP_STATUS:[0-9]*" | cut -d: -f2)

  if [ "$TEST_HTTP_STATUS" = "200" ]; then
    echo "✅ Gemini API connectivity successful"
  else
    echo "❌ Gemini API test failed (Status: $TEST_HTTP_STATUS)"
    exit 1
  fi

else
  echo "❌ Unknown model provider: $MODEL_PROVIDER"
  exit 1
fi
