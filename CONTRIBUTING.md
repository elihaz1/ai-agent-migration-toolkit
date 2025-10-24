# Contributing to AI Agent Migration Toolkit

Thank you for your interest in contributing! This project welcomes contributions from the community.

## How to Contribute

### Reporting Issues

- Use GitHub Issues to report bugs or request features
- Include detailed information: steps to reproduce, expected vs actual behavior
- For security issues, please email privately instead of creating a public issue

### Submitting Changes

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**
   - Follow existing code style and conventions
   - Add/update documentation as needed
   - Test your changes thoroughly
4. **Commit your changes**
   ```bash
   git commit -m "Add: brief description of changes"
   ```
5. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```
6. **Submit a Pull Request**
   - Describe what changes you made and why
   - Reference any related issues

## Areas for Contribution

### High Priority

- [ ] Additional AI agent prompts (phases 2-6)
- [ ] AWS/Azure Terraform modules
- [ ] Additional test scripts (security, performance)
- [ ] Complete migration examples (GCP, AWS, Azure)

### Medium Priority

- [ ] Firewall vendor parsers (FortiGate, Checkpoint, Cisco ASA)
- [ ] Documentation translations
- [ ] Troubleshooting guides
- [ ] Video tutorials

### Nice to Have

- [ ] Web UI for configuration
- [ ] CI/CD pipeline examples
- [ ] Cost estimation tools
- [ ] Compliance framework mappings

## Code Style Guidelines

### Terraform

- Use `terraform fmt` before committing
- Follow HashiCorp best practices
- Add comments for non-obvious configurations
- Use variables for environment-specific values

### Bash Scripts

- Follow Google Shell Style Guide
- Use `set -euo pipefail` at the top
- Add error handling
- Include usage documentation

### Markdown Documentation

- Use clear headings and structure
- Include code examples
- Add tables for structured data
- Link to related docs

### AI Prompts

- Follow template structure (Context, Task, Output, Validation, Example)
- Be specific and unambiguous
- Include expected input/output formats
- Provide complete examples

## Testing

Before submitting a PR:

- [ ] Test Terraform modules with `terraform validate` and `terraform plan`
- [ ] Run shellcheck on bash scripts
- [ ] Verify markdown renders correctly (GitHub preview)
- [ ] Test on a clean environment (not just your local setup)

## Documentation

When adding features:

- Update relevant documentation in `docs/`
- Add examples to `examples/`
- Update main README.md if needed
- Include inline code comments

## Pull Request Process

1. **PR Title:** Use clear, descriptive titles
   - Good: "Add AWS VPC module with Transit Gateway support"
   - Bad: "Update files"

2. **PR Description:** Include:
   - What changed and why
   - How to test the changes
   - Any breaking changes
   - Related issues (e.g., "Fixes #123")

3. **Review Process:**
   - Maintainers will review within 7 days
   - Address feedback and update PR
   - Once approved, PR will be merged

4. **After Merge:**
   - Delete your feature branch
   - Your contribution will be credited in release notes

## Code of Conduct

### Our Standards

- Be respectful and inclusive
- Welcome newcomers
- Focus on constructive feedback
- Assume good intentions

### Unacceptable Behavior

- Harassment or discriminatory language
- Trolling or insulting comments
- Publishing others' private information
- Other unprofessional conduct

### Enforcement

Violations may result in:
- Warning
- Temporary ban
- Permanent ban

Report issues to: [maintainer email]

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Questions?

- Open a GitHub Discussion for general questions
- Use Issues for bug reports or feature requests
- Check existing docs before asking

Thank you for contributing! 🎉
