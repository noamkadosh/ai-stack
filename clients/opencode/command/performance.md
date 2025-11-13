---
description: Analyze and optimize performance issues
agent: debugger
temperature: 0.2
---

# Performance Analysis: @$FILE_PATH

$ARGUMENTS

## Analysis Areas

**Frontend:**
- React re-renders
- Bundle size
- Core Web Vitals (FCP, LCP, CLS, TTI)
- Memory leaks

**Backend:**
- N+1 queries
- Missing database indexes
- Slow endpoints (>500ms)
- Caching opportunities

**Network:**
- Request count
- Payload size
- CDN usage

## Profiling

**Frontend:**
```bash
npm run build -- --stats
npx webpack-bundle-analyzer dist/stats.json
```

**Backend:**
```typescript
// Measure operation time
const start = Date.now();
await operation();
const duration = Date.now() - start;
if (duration > 100) logger.warn(`Slow: ${duration}ms`);
```

**Database:**
```sql
EXPLAIN ANALYZE
SELECT * FROM users WHERE email = 'test@example.com';
```

## Output Format

### Issues Found

**Critical** (>2s response or >90% resources):
- Issue description
- Location: file:line
- Measurement: Current vs expected
- Impact: Users affected

**High** (>1s response or >70% resources):
- Issue with impact

**Medium** (>500ms or >50% resources):
- Issue description

### Recommendations

#### Quick Wins (Easy + High Impact)
1. Recommendation with expected improvement
   ```typescript
   // Before (slow)
   const users = await Promise.all(
     ids.map(id => db.users.findById(id))
   ); // N queries

   // After (fast)
   const users = await db.users.findByIds(ids); // 1 query

   // Expected: 90% faster for 10+ users
   ```

#### Medium Effort
1. Implementation approach
2. Expected improvement

#### Long-term
1. Architectural changes
2. Infrastructure upgrades

### Monitoring
- Metrics to track
- Alerts to set (thresholds)
- Performance budgets

### Expected Results
- Response time targets
- Resource usage limits
- User experience improvements
