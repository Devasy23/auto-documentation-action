#!/bin/bash
CONFIG_DIR="config"

# Enhanced logging function
log() {
    local level=$1
    local message=$2
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $message" >&2
}

# Create backup function
backup_file() {
    local file=$1
    local backup_dir=".backup/$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    cp "$file" "$backup_dir/$(basename "$file")"
    log "INFO" "Backed up $file to $backup_dir"
}

for config_file in $(find "$CONFIG_DIR" -name "*.json"); do
  language=$(jq -r '.language' "$config_file")
  prompt_array=$(jq -r '.prompt | @json' "$config_file")

  FILES_VAR_NAME="${language,,}_files"
  FILES_VAR_NAME=${FILES_VAR_NAME// /_}

  # Get the list of files from the environment variable
  FILES=${!FILES_VAR_NAME}

  if [ -z "$FILES" ]; then
    log "INFO" "No $language files to process"
    continue
  fi

  log "INFO" "Starting $language documentation generation"
  UPDATED_FILES=0
  FAILED_FILES=0

  for FILE in $FILES; do
    log "INFO" "Processing $language file: $FILE"

    # Check file exists and is readable
    if [ ! -f "$FILE" ] || [ ! -r "$FILE" ]; then
      log "ERROR" "File not found or not readable: $FILE"
      FAILED_FILES=$((FAILED_FILES + 1))
      continue
    fi

    # Check file size (skip very large files)
    file_size=$(wc -c < "$FILE")
    if [ "$file_size" -gt 102400 ]; then # 100KB limit
      log "WARN" "Skipping large file: $FILE (${file_size} bytes)"
      continue
    fi

    # Backup original file
    backup_file "$FILE"

    # Create prompt file with error handling
    if ! echo "$prompt_array" | jq -r '.[]' > prompt.txt 2>/dev/null; then
      log "ERROR" "Failed to create prompt for $FILE"
      FAILED_FILES=$((FAILED_FILES + 1))
      continue
    fi

    # Add file content to prompt with validation
    if ! cat "$FILE" >> prompt.txt 2>/dev/null; then
      log "ERROR" "Failed to read file content: $FILE"
      FAILED_FILES=$((FAILED_FILES + 1))
      rm -f prompt.txt
      continue
    fi

    # Call AI API with retry logic and validation
    log "INFO" "📡 Calling $MODEL_PROVIDER API for $language docstrings..."
    
    RETRY_COUNT=3
    SUCCESS=false
    
    for attempt in $(seq 1 $RETRY_COUNT); do
      log "INFO" "Attempt $attempt/$RETRY_COUNT for $FILE"
      
      # Pass language for validation
      NEW_CONTENT=$(python3 scripts/ai_api_helper.py prompt.txt 4000 "$language" 2>/tmp/api_error.log)
      API_EXIT_CODE=$?
      
      if [ $API_EXIT_CODE -eq 0 ] && [ -n "$NEW_CONTENT" ]; then
        # Additional content validation
        if echo "$NEW_CONTENT" | grep -q "ERROR:\|failed\|invalid" >/dev/null 2>&1; then
          log "WARN" "Generated content appears to contain errors for $FILE"
          if [ $attempt -eq $RETRY_COUNT ]; then
            log "ERROR" "All attempts failed for $FILE"
            break
          fi
          sleep $((attempt * 2))
          continue
        fi
        
        # Write new content atomically
        if echo "$NEW_CONTENT" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"; then
          log "INFO" "✅ Updated $language file: $FILE"
          UPDATED_FILES=$((UPDATED_FILES + 1))
          SUCCESS=true
          break
        else
          log "ERROR" "Failed to write updated content to $FILE"
        fi
      else
        log "WARN" "API call failed for $FILE (attempt $attempt)"
        if [ -f /tmp/api_error.log ]; then
          log "ERROR" "API Error: $(cat /tmp/api_error.log)"
        fi
        
        if [ $attempt -lt $RETRY_COUNT ]; then
          sleep $((attempt * 3))
        fi
      fi
    done

    if [ "$SUCCESS" = false ]; then
      FAILED_FILES=$((FAILED_FILES + 1))
      log "ERROR" "⚠️ Failed to process $FILE after $RETRY_COUNT attempts"
    fi

    # Rate limiting with progressive backoff
    sleep $((3 + RANDOM % 3))

    # Clean up
    rm -f prompt.txt "$FILE.tmp" /tmp/api_error.log
  done

  log "INFO" "📊 $language Processing Summary: $UPDATED_FILES updated, $FAILED_FILES failed"
  echo "Updated $UPDATED_FILES $language files successfully"
  
  if [ $FAILED_FILES -gt 0 ]; then
    echo "⚠️ Warning: $FAILED_FILES $language files failed to process"
  fi
done
