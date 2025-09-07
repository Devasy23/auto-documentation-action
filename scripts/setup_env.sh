#!/bin/bash
echo "MODEL_PROVIDER=${MODEL_PROVIDER}" >> $GITHUB_ENV
if [ "${MODEL_PROVIDER}" = "anthropic" ]; then
  echo "ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}" >> $GITHUB_ENV
elif [ "${MODEL_PROVIDER}" = "gemini" ]; then
  echo "GEMINI_API_KEY=${GEMINI_API_KEY}" >> $GITHUB_ENV
fi
