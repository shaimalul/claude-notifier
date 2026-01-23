.PHONY: install uninstall build test lint format clean setup-hooks help

# Default target
help:
	@echo "Claude Notifier - Available targets:"
	@echo ""
	@echo "  make install    - Build and install app + plugin"
	@echo "  make uninstall  - Remove app and plugin"
	@echo "  make build      - Build app only (no install)"
	@echo "  make test       - Run test suite"
	@echo "  make lint       - Run SwiftLint"
	@echo "  make format     - Format code with SwiftFormat"
	@echo "  make setup-hooks - Install git pre-commit hook"
	@echo "  make clean      - Clean build artifacts"
	@echo ""

# Full installation
install:
	@./scripts/install.sh

# Uninstallation
uninstall:
	@./scripts/uninstall.sh

# Build only
build:
	@echo "Building ClaudeNotifier..."
	swift build -c release
	./scripts/create-app-bundle.sh
	@echo "Build complete: .build/release/ClaudeNotifier.app"

# Run tests
test:
	@echo "Running tests..."
	swift test

# Run SwiftLint
lint:
	@echo "Running SwiftLint..."
	@if command -v swiftlint >/dev/null 2>&1; then \
		swiftlint lint; \
	else \
		echo "SwiftLint not installed. Install with: brew install swiftlint"; \
		exit 1; \
	fi

# Format code with SwiftFormat
format:
	@echo "Formatting code..."
	@if command -v swiftformat >/dev/null 2>&1; then \
		swiftformat .; \
	else \
		echo "SwiftFormat not installed. Install with: brew install swiftformat"; \
		exit 1; \
	fi

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	swift package clean
	rm -rf .build
	@echo "Clean complete"

# Setup git hooks
setup-hooks:
	@echo "Setting up git hooks..."
	@cp scripts/pre-commit .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "Pre-commit hook installed"
