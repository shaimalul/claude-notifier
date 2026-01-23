# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability in ClaudeNotifier, please report it responsibly.

### How to Report

1. **Do not** open a public GitHub issue for security vulnerabilities
2. Email the maintainers directly or use GitHub's private vulnerability reporting
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### What to Expect

- Acknowledgment within 48 hours
- Regular updates on progress
- Credit in the release notes (if desired)

## Severity Classification

| Severity | Description | Response Time | Patch Timeline |
|----------|-------------|---------------|----------------|
| Critical | RCE, data breach, privilege escalation | 24 hours | 48 hours |
| High | Local code execution, auth bypass | 48 hours | 7 days |
| Medium | DoS, information disclosure | 5 days | 14 days |
| Low | Minor issues, hardening | 7 days | Next release |

## Coordinated Disclosure

We follow a 90-day coordinated disclosure timeline:

1. **Day 0**: Vulnerability reported
2. **Day 1-7**: Initial triage and acknowledgment
3. **Day 8-60**: Patch development and testing
4. **Day 61-75**: Patch release preparation
5. **Day 76-90**: Coordinated public disclosure

Security fixes are released before public disclosure. Researchers receive credit unless they prefer anonymity.

## Security Considerations

### Permissions Required

ClaudeNotifier requires the following system permissions:

1. **Notifications** - To display alerts when Claude Code needs attention
2. **Accessibility** - To focus the correct Cursor window when clicking notifications

### Network Access

- The app runs a local HTTP server on port 19847
- Only accepts connections from localhost
- No external network connections are made

### Data Handling

- No user data is collected or transmitted
- Debug logs are stored locally at `/tmp/claudenotifier_debug.log`
- Logs contain only operational information (timestamps, events)

### App Sandboxing

The app runs without sandboxing to enable:
- HTTP server on a specific port
- Accessibility API access
- Window management across applications

This is standard for developer tools that need system integration.
