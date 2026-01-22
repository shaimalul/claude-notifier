.PHONY: install uninstall build clean help

# Default target
help:
	@echo "Claude Notifier - Available targets:"
	@echo ""
	@echo "  make install    - Build and install app + plugin"
	@echo "  make uninstall  - Remove app and plugin"
	@echo "  make build      - Build app only (no install)"
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

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	swift package clean
	rm -rf .build
	@echo "Clean complete"
