#!/bin/bash
echo "Scanning for files without proper documentation..."

TOTAL_FILES=0
CONFIG_DIR="config"

for config_file in $(find "$CONFIG_DIR" -name "*.json"); do
  language=$(jq -r '.language' "$config_file")
  extensions_str=$(jq -r '.extensions | join(" ")' "$config_file")
  definitions_regex=$(jq -r '.detection_logic.definitions' "$config_file")
  documented_regex=$(jq -r '.detection_logic.documented' "$config_file")

  files_to_check=""
  for ext in $extensions_str; do
    files_to_check+=$(find . -name "*.$ext" -not -path "./vendor/*" -not -path "./node_modules/*" -not -path "./.git/*")
    files_to_check+=" "
  done

  FILES_VAR_NAME="${language,,}_files"
  FILES_VAR_NAME=${FILES_VAR_NAME// /_}

  UNDOCUMENTED_FILES=""

  for file in $files_to_check; do
    if [ -z "$file" ]; then
      continue
    fi
    echo "Checking $language file: $file..."

    DEFS=$(grep -cE "$definitions_regex" "$file" 2>/dev/null || echo "0")
    DOCS=$(grep -cE "$documented_regex" "$file" 2>/dev/null || echo "0")

    [[ ! "$DEFS" =~ ^[0-9]+$ ]] && DEFS=0
    [[ ! "$DOCS" =~ ^[0-9]+$ ]] && DOCS=0

    echo "  → $language Definitions: $DEFS, Documented: $DOCS"

    if [ "$DEFS" -gt "$DOCS" ] && [ "$DEFS" -gt 0 ]; then
      echo "  → Needs $language docstrings"
      UNDOCUMENTED_FILES="$UNDOCUMENTED_FILES $file"
      TOTAL_FILES=$((TOTAL_FILES + 1))
    fi
  done

  echo "${FILES_VAR_NAME}=${UNDOCUMENTED_FILES}" >> $GITHUB_OUTPUT
done

echo "total_files=$TOTAL_FILES" >> $GITHUB_OUTPUT
echo "Found $TOTAL_FILES files needing documentation"
