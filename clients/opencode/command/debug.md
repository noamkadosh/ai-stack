---
description: Analyze and debug an issue with root cause analysis
agent: debugger
temperature: 0.1
---

# Debug Issue

$ARGUMENTS

## Investigation Process

1. **Reproduce**: Analyze error/symptom, verify across environments
2. **Recent Changes**: Check git history for related changes
3. **Root Cause**: Identify exact cause with stack traces, logs, code review
4. **Fix**: Propose minimal solution with before/after code
5. **Prevention**: Suggest how to prevent similar issues

## Recent Changes

```bash
git log --oneline -10
git log --since="2 days ago" --oneline
```

## Output Format

### Summary
Brief description of the issue.

### Root Cause
Detailed explanation of what's causing it and why.

### Location
- File: `src/path/to/file.ts`
- Line: 42
- Function: `functionName()`

### Fix
```typescript
// Before (problematic)
const user = users.find(u => u.id === id);
return user.email; // Crashes if user not found

// After (fixed)
const user = users.find(u => u.id === id);
if (!user) throw new NotFoundException(`User ${id} not found`);
return user.email;
```

### Testing
How to verify the fix works:
1. Test with invalid user ID
2. Verify proper error response
3. Check error logging

### Prevention
- Add null checks after array.find()
- Use TypeScript strict mode
- Add test for missing user scenario

### Priority
- **Critical**: System down, data loss
- **High**: Major functionality broken
- **Medium**: Feature impaired
- **Low**: Minor inconvenience
