# Quick Reference

**For detailed standards, see:**
- `code-standards.md` - TypeScript, React, NestJS, database patterns
- `security-guidelines.md` - Auth, validation, encryption, vulnerabilities

## Critical Rules

### TypeScript
- Strict mode, explicit types, no `any`
- Interfaces for objects, types for unions
- Files: kebab-case, exports: PascalCase/camelCase

### React/NextJS
- Server components default (App Router)
- `'use client'` for interactivity
- Props interface above component
- Components <120 lines (body only)

### Backend (NestJS)
- Controllers: thin, HTTP only
- Services: business logic
- DTOs: validate with class-validator
- Always parameterized queries (no string concatenation)

### Security (Top Priority)
```typescript
// ❌ NEVER
const query = `SELECT * FROM users WHERE email = '${email}'`;
const apiKey = 'hardcoded-secret';

// ✅ ALWAYS
const query = 'SELECT * FROM users WHERE email = $1';
await db.query(query, [email]);
const apiKey = process.env.API_KEY;
```

### Required Checks
- [ ] All secrets in env vars
- [ ] Auth on all endpoints
- [ ] Input validation (DTOs)
- [ ] SQL queries parameterized
- [ ] XSS prevention (no innerHTML with user data)
- [ ] Error handling comprehensive
- [ ] Tests included

### Git Commits
```
feat: add feature
fix: resolve bug
refactor: improve code
docs: update documentation
test: add tests
```

### Escalation
**Escalate to @architect for:**
- Cross-domain architectural decisions
- Major refactors affecting multiple domains
- System design reviews
