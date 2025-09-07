# Auto Documentation & Docstrings Action

A GitHub Action that automatically generates comprehensive documentation and docstrings for multi-language codebases using AI models (Anthropic Claude or Google Gemini).

## 🚀 Features

- **Multi-language Support**: Works with Go, TypeScript, and Python
- **AI-Powered**: Uses either Anthropic Claude or Google Gemini for intelligent documentation generation
- **Automatic Detection**: Scans your codebase and identifies files that need documentation
- **Smart Documentation**: Generates appropriate docstrings following language-specific conventions
- **Repository Analysis**: Creates an AI_CONTEXT.md file with comprehensive project context
- **Pull Request Workflow**: Creates a new branch with documentation changes for review

## 🎯 Supported Languages

| Language | Documentation Style | Features |
|----------|-------------------|----------|
| **Go** | `// FunctionName does...` | Exported functions, parameters, return values |
| **TypeScript** | `/** @description */` TSDoc | Functions, classes, interfaces with JSDoc tags |
| **Python** | `"""Triple quotes"""` | Functions and classes with Google/NumPy style |

## 🔧 Setup

### Prerequisites

You'll need an API key from either:
- **Anthropic Claude**: Get your API key from [Anthropic Console](https://console.anthropic.com/)
- **Google Gemini**: Get your API key from [Google AI Studio](https://aistudio.google.com/)

### Repository Secrets

Add your chosen API key to your repository secrets:

```
ANTHROPIC_API_KEY=your_anthropic_api_key_here
# OR
GEMINI_API_KEY=your_gemini_api_key_here
```

## 📝 Usage

### Basic Usage (Anthropic Claude)

```yaml
name: Auto Documentation

on:
  push:
    branches: [main, develop]
  pull_request:
    types: [opened, synchronize]

jobs:
  documentation:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
    
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Auto Documentation & Docstrings
        uses: devasy23/auto-documentation-action@v1
        with:
          model_provider: 'anthropic'
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

### Using Google Gemini

```yaml
      - name: Auto Documentation & Docstrings
        uses: devasy23/auto-documentation-action@v1
        with:
          model_provider: 'gemini'
          gemini_api_key: ${{ secrets.GEMINI_API_KEY }}
```

### Advanced Configuration

```yaml
      - name: Auto Documentation & Docstrings
        uses: devasy23/auto-documentation-action@v1
        with:
          model_provider: 'anthropic'
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          target_branches: 'main,master,develop,staging'
          commit_message: 'docs: Update documentation with AI assistance'
```

### Manual Trigger with Model Selection

```yaml
name: Auto Documentation

on:
  workflow_dispatch:
    inputs:
      model_provider:
        description: 'AI Model Provider'
        required: true
        default: 'anthropic'
        type: choice
        options:
        - anthropic
        - gemini

jobs:
  documentation:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
    
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Auto Documentation & Docstrings
        uses: devasy23/auto-documentation-action@v1
        with:
          model_provider: ${{ github.event.inputs.model_provider }}
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          gemini_api_key: ${{ secrets.GEMINI_API_KEY }}
```

## 📊 Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `model_provider` | AI model provider (`anthropic` or `gemini`) | No | `anthropic` |
| `anthropic_api_key` | Anthropic API key for Claude AI | No* | - |
| `gemini_api_key` | Google Gemini API key | No* | - |
| `target_branches` | Comma-separated list of branches to run on | No | `main,master,develop` |
| `commit_message` | Custom commit message for documentation updates | No | `docs: Auto-generated multi-language documentation` |

*Required based on selected `model_provider`

## 📤 Outputs

| Output | Description |
|--------|-------------|
| `files_processed` | Number of files that were processed |
| `context_md_generated` | Whether AI_CONTEXT.md was generated (`true`/`false`) |
| `branch_created` | Name of the branch created with changes |

## 🔍 What It Does

1. **Repository Analysis**: Scans your codebase structure and creates a comprehensive AI_CONTEXT.md file
2. **File Detection**: Identifies Go, TypeScript, and Python files that lack proper documentation
3. **AI Documentation**: Uses your chosen AI provider to generate appropriate docstrings and comments
4. **Quality Validation**: Ensures generated content follows language-specific conventions
5. **Branch Creation**: Creates a new branch with all documentation changes
6. **Summary Report**: Provides a detailed summary of what was processed and updated

## 📋 Example Output

The action will create documentation like this:

### Go
```go
// CalculateTotal calculates the total sum of all items in the given slice.
// It accepts a slice of integers and returns the computed total.
// Returns 0 if the slice is empty or nil.
func CalculateTotal(items []int) int {
    // ... existing code
}
```

### TypeScript
```typescript
/**
 * @description Validates user input and returns formatted data
 * @param input - The raw user input string
 * @param options - Configuration options for validation
 * @returns Promise resolving to validated and formatted data
 */
export async function validateInput(input: string, options: ValidationOptions): Promise<ValidatedData> {
    // ... existing code
}
```

### Python
```python
def process_data(data: List[Dict], filter_key: str) -> List[Dict]:
    """
    Processes and filters a list of dictionaries based on the specified key.
    
    Args:
        data: List of dictionaries to process
        filter_key: The key to use for filtering data
        
    Returns:
        List of filtered and processed dictionaries
        
    Raises:
        ValueError: If filter_key is not found in any dictionary
    """
    # ... existing code
```

## 🎨 Generated AI_CONTEXT.md

The action automatically creates an `AI_CONTEXT.md` file containing:

- **Project Overview**: Intelligent analysis of your project's purpose
- **Architecture**: Inferred structure and design patterns
- **Technology Stack**: Detected languages, frameworks, and tools
- **Development Guidelines**: Language-specific best practices
- **Build Instructions**: Appropriate commands for your project type
- **Testing Strategy**: Recommended testing approaches

## 🔒 Security & Privacy

- API keys are handled securely through GitHub Secrets
- All AI API calls are made over HTTPS
- No code is stored or cached by the AI providers beyond the request
- Generated documentation is reviewed before merging via pull request workflow

## 🐛 Troubleshooting

### Common Issues

**API Key Not Working**
- Ensure your API key is correctly added to repository secrets
- Verify the API key has proper permissions and isn't expired
- Check that you're using the correct provider (`anthropic` vs `gemini`)

**No Files Processed**
- The action only processes files with undocumented exported functions/classes
- Ensure your code follows standard conventions for exports
- Check the action logs for detailed file scanning results

**Generated Content Issues**
- AI-generated content is validated but may occasionally need manual review
- The action creates a review branch specifically for this purpose
- You can adjust prompts by modifying the action workflow

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 🙏 Acknowledgments

- [Anthropic](https://anthropic.com/) for Claude AI
- [Google](https://ai.google.dev/) for Gemini AI
- The open-source community for inspiration and feedback
