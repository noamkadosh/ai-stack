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

### Quick Wins (Easy + High Impact)

**Database N+1 Queries:**
```typescript
// ❌ SLOW - N+1 queries
const users = await userRepo.find();
for (const user of users) {
  user.posts = await postRepo.findByUserId(user.id); // N queries!
}

// ✅ FAST - Eager loading
const users = await userRepo.find({ relations: ['posts'] }); // 1 query

// Expected: 90% faster for 10+ users
```

**React Re-renders:**
```typescript
// ❌ SLOW - Creates new object every render
<Component style={{ margin: 10 }} />

// ✅ FAST - Stable reference
const styles = { margin: 10 };
<Component style={styles} />

// ❌ SLOW - Re-creates function every render
<button onClick={() => handleClick(id)}>Click</button>

// ✅ FAST - Memoized callback
const handleClick = useCallback(() => doSomething(id), [id]);
<button onClick={handleClick}>Click</button>
```

**Missing Database Indexes:**
```sql
-- ❌ SLOW - Full table scan
SELECT * FROM users WHERE email = 'test@example.com'; -- 2000ms

-- ✅ FAST - Index scan
CREATE INDEX idx_users_email ON users(email);
SELECT * FROM users WHERE email = 'test@example.com'; -- 5ms

-- Expected: 99% faster for 100k+ rows
```

**Bundle Size:**
```typescript
// ❌ LARGE BUNDLE - Import entire library
import _ from 'lodash'; // 70KB

// ✅ SMALL BUNDLE - Import specific functions
import { debounce } from 'lodash-es'; // 2KB

// ✅ Code splitting - Lazy load heavy components
const Dashboard = lazy(() => import('./Dashboard'));
```

### Medium Effort

**Caching:**
```typescript
// Add Redis cache for frequent queries
async getUser(id: string) {
  const cached = await redis.get(`user:${id}`);
  if (cached) return JSON.parse(cached);
  
  const user = await db.users.findById(id);
  await redis.set(`user:${id}`, JSON.stringify(user), 'EX', 300); // 5min TTL
  return user;
}
```

**Query Optimization:**
```sql
-- Add composite index for common queries
CREATE INDEX idx_posts_user_published 
ON posts(user_id, published, created_at DESC);
```

### Long-term
1. Implement CDN for static assets
2. Database read replicas
3. Horizontal scaling (load balancer)
4. Microservices for independent scaling

### Monitoring
- Metrics to track
- Alerts to set (thresholds)
- Performance budgets

### Expected Results
- Response time targets
- Resource usage limits
- User experience improvements
