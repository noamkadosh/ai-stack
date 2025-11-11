---
description: Generate comprehensive unit tests (Jest/Vitest)
agent: test
temperature: 0.1
---

Generate tests for: **@$FILE_PATH**

$ARGUMENTS

## Requirements

- Test all exports
- Arrange-Act-Assert pattern
- Happy path + edge cases + errors
- Mock external dependencies
- 80%+ coverage

Check test framework:
!grep -l "jest\|vitest" package.json
