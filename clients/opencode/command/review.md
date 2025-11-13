---
description: Comprehensive code review for quality, security, and performance
agent: reviewer
temperature: 0.1
---

# Code Review: @$FILE_PATH

$ARGUMENTS

## Review Checklist

- **Code Quality**: Naming, abstraction, DRY, error handling
- **Functionality**: Solves problem, handles edge cases
- **Performance**: No obvious issues, efficient algorithms
- **Security**: Input validation, no hardcoded secrets
- **Testing**: Tests included, adequate coverage
- **Documentation**: Complex logic documented

## Output Format

### Summary
Brief overview of code quality and purpose.

### Strengths
- What's done well
- Good practices followed
- Effective solutions

### Issues

**[BLOCKING]** Critical issues (must fix before merge):
- Security vulnerabilities
- Data corruption risks
- Critical bugs

**[HIGH]** Important issues (should fix):
- Bugs affecting functionality
- Performance problems
- Missing error handling

**[MEDIUM]** Improvements (nice to have):
- Refactoring opportunities
- Test coverage gaps
- Documentation updates

**[LOW]** Minor suggestions:
- Code style preferences
- Minor optimizations

### Recommendations
Overall recommendations and refactoring suggestions.

### Approval
- ☐ Approved
- ☐ Approved with comments
- ☐ Request changes (explain why)

## Example Issue Format

```markdown
**[HIGH]** Missing Authorization Check
- Location: `src/orders/orders.controller.ts:28`
- Issue: No verification that user owns the order
- Impact: Users can access other users' orders
- Fix:
  ```typescript
  if (user.id !== order.userId && !user.isAdmin) {
    throw new ForbiddenException();
  }
  ```
```
