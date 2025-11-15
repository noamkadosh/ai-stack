# Security Guidelines

**High-level security overview. For detailed implementation patterns, see @security agent.**

## Critical Rules

### Never Hardcode Secrets
```typescript
// ❌ VULNERABLE
const apiKey = 'sk-1234567890abcdef';
const query = `SELECT * FROM users WHERE email = '${email}'`;

// ✅ SECURE
const apiKey = process.env.API_KEY;
if (!apiKey) throw new Error('API_KEY not configured');
const query = 'SELECT * FROM users WHERE email = $1';
await db.query(query, [email]);
```

### Never Commit
- API keys, tokens, passwords
- Private keys, certificates
- Database credentials
- `.env` files (use `.env.example` template)

## Security Domains

### Authentication & Authorization
**Detailed patterns in @security agent**
- Password hashing: bcrypt (cost ≥12) or Argon2
- JWT: ≤24h access, ≤7d refresh tokens
- Session timeout: 30 minutes idle
- Account lockout: 5 failed attempts
- RBAC on all endpoints

### Input Validation
**Detailed patterns in @security agent**
- **SQL Injection**: Parameterized queries ONLY
- **XSS**: Never use `innerHTML` with user input
- **CSRF**: Token protection for state changes
- **Command Injection**: Avoid shell execution
- **Path Traversal**: Validate file paths

### API Security
**Detailed patterns in @security, @backend agents**
- Rate limiting on endpoints
- CORS: Specific origins only (no `*`)
- Auth guards on all routes
- Authorization checks (user owns resource)
- Security headers (Helmet, HSTS, CSP)

### Data Protection
**Detailed patterns in @security agent**
- **In transit**: TLS 1.2+ everywhere
- **At rest**: Encrypt PII, financial data
- **Secrets**: AWS Secrets Manager, Vault
- **PII**: Minimize collection, GDPR compliance

### Infrastructure Security
**Detailed patterns in @infrastructure agent**
- **Containers**: Non-root user, minimal base images
- **Network**: VPC isolation, restrictive security groups
- **Dependencies**: Regular `npm audit`, update strategy

## Pre-Deployment Checklist

- [ ] All secrets in environment variables
- [ ] TLS/HTTPS enabled
- [ ] Authentication + Authorization on all endpoints
- [ ] Input validation (DTOs with class-validator)
- [ ] SQL queries parameterized
- [ ] Rate limiting configured
- [ ] Security headers set (Helmet)
- [ ] Dependencies scanned (`npm audit`)
- [ ] Logging excludes sensitive data
- [ ] Backups encrypted

## When to Use @security Agent

- Security audits before deployment
- Review authentication/authorization logic
- Validate input handling patterns
- Check compliance requirements (GDPR, SOC2, PCI-DSS)
- Investigate security incidents
- Dependency vulnerability assessment

## Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP Cheat Sheets](https://cheatsheetseries.owasp.org/)
- [CWE Top 25](https://cwe.mitre.org/top25/)
- **@security agent** for detailed implementation patterns
