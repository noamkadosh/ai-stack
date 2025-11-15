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

## Common Issues & Patterns

**Null/Undefined Errors:**
```typescript
// ❌ CRASHES - No null check
const user = users.find(u => u.id === id);
return user.email; // TypeError if not found

// ✅ SAFE - Null check
const user = users.find(u => u.id === id);
if (!user) throw new NotFoundException();
return user.email;
```

**Async/Await Issues:**
```typescript
// ❌ BUG - Missing await
async function getData() {
  const data = api.fetch(); // Returns Promise, not data!
  return data.value; // undefined
}

// ✅ FIXED
async function getData() {
  const data = await api.fetch();
  return data.value;
}
```

**React Hooks Dependency Issues:**
```typescript
// ❌ BUG - Missing dependency causes stale closure
useEffect(() => {
  fetchData(userId); // Uses stale userId
}, []); // Missing userId!

// ✅ FIXED
useEffect(() => {
  fetchData(userId);
}, [userId]); // Re-runs when userId changes
```

**Memory Leaks:**
```typescript
// ❌ LEAK - No cleanup
useEffect(() => {
  const interval = setInterval(() => tick(), 1000);
  // Component unmounts but interval keeps running!
}, []);

// ✅ FIXED - Cleanup
useEffect(() => {
  const interval = setInterval(() => tick(), 1000);
  return () => clearInterval(interval); // Cleanup on unmount
}, []);
```

## Recent Changes

```bash
git log --oneline -10
git log --since="2 days ago" --oneline
git diff HEAD~5..HEAD  # Changes in last 5 commits
```

## Debugging Tools

**Backend:**
```bash
# Enable Node.js inspector
node --inspect dist/main.js

# Memory profiling
node --prof dist/main.js
node --prof-process isolate-*.log > profile.txt
```

**Frontend:**
```bash
# React DevTools Profiler
# Chrome DevTools → Performance tab
# Network tab → Check waterfall

# Bundle analysis
npm run build -- --stats
npx webpack-bundle-analyzer dist/stats.json
```

**Database:**
```sql
-- Query analysis
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@example.com';

-- Check indexes
SELECT * FROM pg_indexes WHERE tablename = 'users';
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
