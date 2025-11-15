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

## Common Issues to Check

**Type Safety:**
```typescript
// ❌ UNSAFE
function processData(data: any) { ... }

// ✅ TYPE SAFE
function processData(data: User): UserDto { ... }
```

**Error Handling:**
```typescript
// ❌ SWALLOWING ERRORS
try {
  await operation();
} catch (e) {
  console.log(e);
}

// ✅ PROPER HANDLING
try {
  await operation();
} catch (error) {
  logger.error('Operation failed', { error });
  throw new ServiceException('Operation failed', error);
}
```

**React Hooks:**
```typescript
// ❌ MISSING DEPENDENCY
useEffect(() => {
  fetchData(userId);
}, []); // userId missing!

// ✅ COMPLETE DEPENDENCIES
useEffect(() => {
  fetchData(userId);
}, [userId]);
```

**Async/Await:**
```typescript
// ❌ NOT AWAITING
async function getUser(id: string) {
  const user = this.repo.findById(id); // Missing await!
  return user;
}

// ✅ PROPERLY AWAITED
async function getUser(id: string): Promise<User> {
  const user = await this.repo.findById(id);
  if (!user) throw new NotFoundException();
  return user;
}
```

**Imports/Exports:**
```typescript
// ❌ BAD - Default exports
export default MyComponent;

// ✅ GOOD - Named exports
export const MyComponent = ...;
```

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
