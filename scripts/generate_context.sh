#!/bin/bash
if [ ! -f "AI_CONTEXT.md" ]; then
  echo "generating_context_md=true" >> $GITHUB_OUTPUT

  echo "🤖 Analyzing repository to generate AI_CONTEXT.md with AI..."
  echo "🔧 Using provider: $MODEL_PROVIDER"

  # Gather repository information
  echo "=== Gathering repository analysis ==="

  # Create analysis file step by step
  echo "Repository Analysis:" > repo_info.txt
  echo "" >> repo_info.txt

  echo "Go Files:" >> repo_info.txt
  find . -name "*.go" -not -path "./vendor/*" | head -20 >> repo_info.txt
  echo "" >> repo_info.txt

  echo "TypeScript Files:" >> repo_info.txt
  find . -name "*.ts" -o -name "*.tsx" -not -path "./node_modules/*" | head -10 >> repo_info.txt
  echo "" >> repo_info.txt

  echo "Python Files:" >> repo_info.txt
  find . -name "*.py" | head -10 >> repo_info.txt
  echo "" >> repo_info.txt

  echo "Directory Structure:" >> repo_info.txt
  find . -type d -not -path "./.git*" -not -path "./node_modules*" -not -path "./vendor*" | head -15 | sort >> repo_info.txt
  echo "" >> repo_info.txt

  echo "Configuration Files:" >> repo_info.txt
  find . -name "*.json" -o -name "*.yaml" -o -name "*.yml" -o -name "Dockerfile" -o -name "Makefile" -o -name "go.mod" | head -10 >> repo_info.txt
  echo "" >> repo_info.txt

  if [ -f "package.json" ]; then
    echo "Package.json:" >> repo_info.txt
    head -20 package.json >> repo_info.txt
  fi

  if [ -f "go.mod" ]; then
    echo "Go.mod:" >> repo_info.txt
    cat go.mod >> repo_info.txt
  fi

  # Create prompt file
  cat > context_prompt.txt << 'PROMPT_EOF'
You are a technical documentation expert. Analyze this repository structure and create a comprehensive AI_CONTEXT.md file that will serve as context for AI assistants working on this codebase.

Create an AI_CONTEXT.md file that includes:
1. **Project Overview** - Intelligent analysis of what this project does based on the structure
2. **Architecture** - Infer the architecture from the directory structure and file types
3. **Key Components** - Identify main modules/packages and their purposes
4. **Technology Stack** - List technologies based on file types and configs
5. **Development Guidelines** - Appropriate coding standards for the languages used
6. **Build & Run Instructions** - Smart commands based on the project type
7. **Testing Strategy** - Testing approaches for the identified languages
8. **API Documentation** - If web APIs are detected
9. **Deployment** - If infrastructure files are found

Make it comprehensive but concise. Focus on what an AI assistant would need to understand to effectively help with this codebase.

Repository Information:
PROMPT_EOF

      # Append repository analysis to prompt
      cat repo_info.txt >> context_prompt.txt

      # Call AI API using our helper
      echo "📡 Calling $MODEL_PROVIDER API to generate AI_CONTEXT.md..."
      CONTEXT_CONTENT=$(python3 scripts/ai_api_helper.py context_prompt.txt 3000 2>/dev/null)

      if [ $? -eq 0 ] && [ -n "$CONTEXT_CONTENT" ]; then
        echo "$CONTEXT_CONTENT" > AI_CONTEXT.md
        echo "✅ Generated intelligent AI_CONTEXT.md using $MODEL_PROVIDER AI"
      else
        echo "⚠️ Failed to generate content with $MODEL_PROVIDER"
        echo "Creating fallback AI_CONTEXT.md..."
        cat > AI_CONTEXT.md << 'FALLBACK_EOF'
# Project Documentation - AI Context

## Project Overview
Multi-language application with support for Go, TypeScript, and Python.

## Key Commands
- `go build`: Build Go applications
- `go test ./...`: Run Go tests
- `npm run build`: Build TypeScript projects

## Documentation Standards
- Go: Use // FunctionName does... format
- TypeScript: Use /** @description */ TSDoc format
- Python: Use triple-quote docstrings
FALLBACK_EOF
    echo "⚠️ Used fallback template for AI_CONTEXT.md"
  fi

  # Cleanup temporary files
  rm -f context_prompt.txt repo_info.txt

else
  echo "generating_context_md=false" >> $GITHUB_OUTPUT
  echo "✅ AI_CONTEXT.md already exists"
fi
