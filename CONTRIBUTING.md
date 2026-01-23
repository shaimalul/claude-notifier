# Contributing to ClaudeNotifier

Thank you for your interest in contributing to ClaudeNotifier!

## Development Setup

### Prerequisites

- macOS 13.0 or later
- Xcode 15+ with Command Line Tools
- Swift 5.9+
- [jq](https://stedolan.github.io/jq/) for JSON processing

### Getting Started

1. Fork and clone the repository
2. Build the project:
   ```bash
   swift build
   ```
3. Run tests:
   ```bash
   swift test
   ```

### Code Style

We use SwiftLint and SwiftFormat to maintain consistent code style.

```bash
# Check linting
swiftlint lint

# Auto-format code
swiftformat .
```

**Guidelines:**
- Maximum 150 lines per file
- Maximum 30 lines per function
- Use meaningful variable names
- Add protocols for testability

## Pull Request Process

1. Fork the repository
2. Create a feature branch:
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. Make your changes following our code style
4. Add tests for new functionality
5. Ensure all tests pass:
   ```bash
   swift test
   ```
6. Ensure linting passes:
   ```bash
   swiftlint lint
   ```
7. Commit with clear messages following [Conventional Commits](https://www.conventionalcommits.org/):
   ```bash
   git commit -m "feat: add notification sound customization"
   ```
8. Push and create a Pull Request

### Commit Message Format

- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

## Reporting Issues

### Bug Reports

Use the bug report template and include:
- macOS version
- Steps to reproduce
- Expected vs actual behavior
- Contents of `/tmp/claudenotifier_debug.log`

### Feature Requests

Use the feature request template and describe:
- The problem you're trying to solve
- Your proposed solution
- Alternative approaches considered

## Questions?

Feel free to open a discussion or issue if you have questions about contributing.
