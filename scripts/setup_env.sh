#!/bin/bash

# Enhanced logging and validation
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [SETUP] $1" >&2
}

log "Starting environment setup..."

# Validate MODEL_PROVIDER
if [[ ! "$MODEL_PROVIDER" =~ ^(anthropic|gemini)$ ]]; then
  log "ERROR: Invalid MODEL_PROVIDER: $MODEL_PROVIDER"
  exit 1
fi

log "Setting MODEL_PROVIDER to: $MODEL_PROVIDER"
echo "MODEL_PROVIDER=${MODEL_PROVIDER}" >> $GITHUB_ENV

# Validate and set API keys securely
if [ "${MODEL_PROVIDER}" = "anthropic" ]; then
  if [ -z "$ANTHROPIC_API_KEY" ]; then
    log "ERROR: ANTHROPIC_API_KEY is required for anthropic provider"
    exit 1
  fi
  
  # Basic format validation for Anthropic keys
  if [[ ! "$ANTHROPIC_API_KEY" =~ ^sk-ant-[a-zA-Z0-9_-]+$ ]]; then
    log "WARNING: ANTHROPIC_API_KEY format appears invalid"
  fi
  
  echo "ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}" >> $GITHUB_ENV
  log "Anthropic API key configured"
  
elif [ "${MODEL_PROVIDER}" = "gemini" ]; then
  if [ -z "$GEMINI_API_KEY" ]; then
    log "ERROR: GEMINI_API_KEY is required for gemini provider"
    exit 1
  fi
  
  # Basic length validation for Gemini keys
  if [ ${#GEMINI_API_KEY} -lt 20 ]; then
    log "WARNING: GEMINI_API_KEY appears too short"
  fi
  
  echo "GEMINI_API_KEY=${GEMINI_API_KEY}" >> $GITHUB_ENV
  log "Gemini API key configured"
fi

# Set up additional security environment variables
echo "PYTHONDONTWRITEBYTECODE=1" >> $GITHUB_ENV
echo "PYTHONUNBUFFERED=1" >> $GITHUB_ENV

log "Environment setup completed successfully"
