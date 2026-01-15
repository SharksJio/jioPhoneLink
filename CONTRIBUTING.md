# Contributing to Jio Phone Link

Thank you for your interest in contributing to Jio Phone Link! This document provides guidelines and instructions for contributing to this project.

## Code of Conduct

Please be respectful and constructive in all interactions with the project and its community.

## How to Contribute

### Reporting Bugs

If you find a bug, please create an issue with:
- A clear, descriptive title
- Steps to reproduce the issue
- Expected behavior
- Actual behavior
- Screenshots (if applicable)
- Device/OS information

### Suggesting Enhancements

Enhancement suggestions are welcome! Please create an issue with:
- A clear description of the enhancement
- Use cases and benefits
- Potential implementation approach (optional)

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Follow the existing code style**
   - For Kotlin: Follow [Kotlin Coding Conventions](https://kotlinlang.org/docs/coding-conventions.html)
   - For Dart/Flutter: Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
3. **Write clear commit messages**
   - Use present tense ("Add feature" not "Added feature")
   - Reference issues in commit messages when applicable
4. **Test your changes** thoroughly
5. **Update documentation** if needed
6. **Submit a pull request** with a clear description

## Development Setup

### Tablet App (Android)
```bash
cd tablet-app
# Open in Android Studio or build with Gradle
./gradlew build
```

### Companion App (Flutter)
```bash
cd companion-app
flutter pub get
flutter run
```

## Coding Standards

### Kotlin (Tablet App)
- Use meaningful variable and function names
- Keep functions small and focused
- Add comments for complex logic
- Follow MVVM architecture pattern
- Use coroutines for async operations

### Dart/Flutter (Companion App)
- Use meaningful widget and variable names
- Keep widgets small and reusable
- Add comments for complex logic
- Follow Flutter best practices
- Use async/await for asynchronous code

## Testing

- Write unit tests for new features
- Ensure all existing tests pass
- Test on multiple devices if possible

## Documentation

- Update README.md if you change functionality
- Add code comments for complex logic
- Update ARCHITECTURE.md for architectural changes

## Review Process

1. Submit pull request
2. Automated checks will run
3. Project maintainers will review
4. Address feedback if any
5. Once approved, your PR will be merged

## Questions?

Feel free to create an issue for any questions or clarifications needed.

Thank you for contributing! 🎉
