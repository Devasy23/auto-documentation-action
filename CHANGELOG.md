# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-12-XX

### Added
- Initial release of Auto Documentation & Docstrings Action
- Support for multi-language documentation generation (Go, TypeScript, Python)
- Dual AI provider support (Anthropic Claude and Google Gemini)
- Automatic repository analysis and CLAUDE.md generation
- Smart file detection for undocumented code
- Language-specific docstring generation following best practices
- Automatic branch creation and pull request workflow
- Comprehensive error handling and fallback mechanisms
- Configurable inputs for customization
- Detailed outputs and summary reporting

### Features
- **Go Documentation**: Generates `// FunctionName does...` style comments for exported functions
- **TypeScript Documentation**: Creates TSDoc comments with `@description`, `@param`, and `@returns` tags
- **Python Documentation**: Adds Google/NumPy style docstrings with proper sections
- **Repository Analysis**: Intelligent project structure analysis with CLAUDE.md generation
- **Multi-Provider AI**: Choice between Anthropic Claude 3 Sonnet and Google Gemini 1.5 Flash
- **Rate Limiting**: Built-in delays to respect API rate limits
- **Validation**: Content validation to ensure quality documentation
- **Branch Management**: Automatic branch creation with meaningful commit messages

### Technical Details
- Built as a composite GitHub Action for maximum compatibility
- Uses Python for robust AI API integration
- Supports all major programming languages through file detection
- Includes comprehensive error handling and logging
- Optimized for performance with intelligent scanning algorithms
