#!/bin/bash
CONFIG_DIR="config"

for config_file in $(find "$CONFIG_DIR" -name "*.json"); do
  language=$(jq -r '.language' "$config_file")
  prompt_array=$(jq -r '.prompt | @json' "$config_file")

  FILES_VAR_NAME="${language,,}_files"
  FILES_VAR_NAME=${FILES_VAR_NAME// /_}

  # Get the list of files from the environment variable
  FILES=${!FILES_VAR_NAME}

  if [ -z "$FILES" ]; then
    continue
  fi

  UPDATED_FILES=0

  for FILE in $FILES; do
    echo "Processing $language file: $FILE..."

    # Create prompt file
    echo "$prompt_array" | jq -r '.[]' > prompt.txt

    # Add file content to prompt
    cat "$FILE" >> prompt.txt

    # Call AI API using our helper
    echo "📡 Calling $MODEL_PROVIDER API for $language docstrings..."
    NEW_CONTENT=$(python3 scripts/ai_api_helper.py prompt.txt 4000 2>/dev/null)

    if [ $? -eq 0 ] && [ -n "$NEW_CONTENT" ]; then
      echo "$NEW_CONTENT" > "$FILE"
      echo "✅ Updated $language file: $FILE"
      UPDATED_FILES=$((UPDATED_FILES + 1))
    else
      echo "⚠️ No valid content generated for $FILE"
    fi

    # Rate limiting
    sleep 3

    # Clean up
    rm -f prompt.txt
  done

  echo "Updated $UPDATED_FILES $language files successfully"
done
