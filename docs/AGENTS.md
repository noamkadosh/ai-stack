# Agent System Guide

This document explains the tech stack, code standards, and **how to effectively delegate work to specialized agents** in this project.

## Tech Stack

**Frontend**: TypeScript, React, NextJS, Storybook  
**Backend**: NestJS, Node.js, REST API, GraphQL  
**Database**: PostgreSQL  
**Infrastructure**: Docker, AWS, Nix  
**Testing**: Jest (unit), Vitest (unit), Playwright (e2e)  
**Tools**: GitHub (code reviews), Obsidian (notes)

## Code Standards Overview

Detailed standards are in `code-standards.md` and `security-guidelines.md`. Key principles:

### TypeScript
- Strict mode, explicit types, no `any`
- Prefer `type` over `interface`
- Use `satisfies` for type narrowing
- String enums only (no numeric enums)

### React/NextJS
- Server components default (App Router)
- `'use client'` for client components
- Props interface above component
- Components <120 lines (body only, excluding imports and type definitions)
- Functional components only (no class components)

### Backend (NestJS)
- Controllers: thin, HTTP only
- Services: business logic
- DTOs: validation with class-validator
- Always use parameterized queries (never string concatenation)
- Repository pattern for database access

### Database
- Migrations for all schema changes
- Indexes on foreign keys and frequently queried columns
- Transactions for multi-step operations
- Use meaningful constraint names

### Testing
- Unit: Jest/Vitest, `*.spec.ts` or `*.test.ts`
- E2E: Playwright
- Coverage: 80%+ critical paths
- Test file co-located with source (in `__tests__/` subfolder)

### Git
- Branches: `feature/`, `fix/`, `refactor/`, `docs/`, `chore/`
- Commits: conventional format (feat:, fix:, docs:, refactor:, test:, chore:)
- PRs: what changed, why, how to test

### Security
- **CRITICAL**: No secrets in code, use environment variables
- Validate all user input (DTOs)
- Parameterized queries only (SQL injection prevention)
- Rate limiting on public endpoints
- HTTPS only, CORS configured
- Never log sensitive data (passwords, tokens, PII)

---

## Standard Development Workflow

All development tasks follow this standardized workflow from planning through merge:

| Stage | Agent | Key Activities | May Delegate To |
|-------|-------|----------------|-----------------|
| **1. PLAN** | OpenCode built-in | Analyze task, review codebase, plan approach, identify risks | @architect, @database, @security, @test |
| **2. BUILD** | OpenCode built-in | Implement changes, write tests, follow standards | @frontend, @backend, @database, @test |
| **3. VALIDATE** | BUILD agent | Run tests, linting, type-checking, security audit | @security (for comprehensive audit) |
| **4. DOCUMENT** | BUILD agent | Update API docs, README, ADRs, code comments (skip for minor fixes) | @documentation |
| **5. COMMIT** | Main agent (you) | Commit with conventional format (`feat:`, `fix:`, etc.), push to remote | - |
| **6. OPEN PR** | Main agent (you) | Create PR with `gh pr create`, describe changes, testing steps | - |
| **7. REVIEW LOOP** | Main agent (you) | User reviews → agent updates → repeat until approved | Domain specialists as needed |
| **8. MERGE** | User or you | **Squash merge** to main, delete branch, verify CI/CD | - |

**Workflow Diagram**:

```
┌─────────────────────────────────────────────────────────────┐
│  1. PLAN                                                    │
│     • Analyze task                                          │
│     • Plan approach (may delegate to specialists)           │
└────────────────────────┬────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│  2. BUILD                                                   │
│     • Implement changes (may delegate to specialists)       │
│     • Write tests                                           │
└────────────────────────┬────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│  3. VALIDATE                                                │
│     • Run tests, linting, type-checking                     │
│     • Security audit                                        │
└────────────────────────┬────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│  4. DOCUMENT                                                │
│     • Update docs, ADRs, comments                           │
└────────────────────────┬────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│  5. COMMIT                                                  │
│     • Commit with conventional format                       │
│     • Push to remote                                        │
└────────────────────────┬────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│  6. OPEN PR                                                 │
│     • Create PR with gh CLI                                 │
│     • Describe changes, testing steps                       │
└────────────────────────┬────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│  7. REVIEW LOOP ←──────────────┐                            │
│     • User reviews              │                            │
│     • Agent updates             │                            │
│     • Repeat until approved ────┘                            │
└────────────────────────┬────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│  8. MERGE                                                   │
│     • Squash merge to main                                  │
│     • Delete branch                                         │
└─────────────────────────────────────────────────────────────┘
```

---

## Delegation Strategy

### When to Delegate

**DO delegate when:**
- Task requires specialized domain knowledge beyond your expertise
- Task is complex and benefits from focused, deep analysis
- Multiple independent subtasks can be executed in parallel
- Architecture decisions that affect multiple domains
- Code quality review or security audit needed
- Comprehensive testing strategy required

**DON'T delegate when:**
- Task is simple and straightforward (< 20 lines of code)
- You can implement it quickly yourself (< 5 minutes)
- Task requires tight coordination across domains (you should coordinate)
- Delegation overhead exceeds implementation time
- Context sharing would be more expensive than doing it yourself

### Complexity Tradeoffs

Consider these factors before delegating:

1. **Latency**: Delegation adds coordination overhead
2. **Cost**: Each agent interaction consumes tokens/resources
3. **Context**: Sharing context between agents has overhead
4. **Accuracy**: Specialists often produce higher quality for domain tasks

**Rule of thumb**: Start simple. Only delegate when it demonstrably improves outcomes.

---

## Specialized Agents

This project has 10 specialized agents. Each is an expert in their domain.

### @architect - System Architect

**Authority**: Final decision-maker on architectural matters.

**Use for:**
- Architecture decisions (technology choices, patterns, structure)
- System design (components, data flow, service boundaries)
- API design (REST vs GraphQL, versioning, contract design)
- Scalability planning and performance architecture
- Cross-domain solutions that affect multiple systems
- Technology stack evaluations

**Example invocations:**
```
@architect design API architecture for multi-tenant SaaS with REST and GraphQL

@architect should we use microservices or monolith for this e-commerce platform?

@architect review the proposed database schema for scalability issues
```

**Escalation:**
- **FROM**: Never escalates (final authority)
- **TO**: Major architecture decisions, cross-domain issues, technology choices

---

### @backend - Backend Specialist

**Expertise**: NestJS, Node.js, REST API, GraphQL, server-side logic.

**Use for:**
- Building NestJS APIs (REST/GraphQL endpoints)
- Controller/Service/Repository pattern implementation
- DTO validation with class-validator
- JWT authentication, RBAC implementation
- Backend business logic and data processing
- API versioning and deprecation strategies

**Example invocations:**
```
@backend create CRUD API for products with NestJS, DTOs, tests, auth guards

@backend implement JWT refresh token rotation with Redis storage

@backend add pagination and filtering to the products endpoint
```

**Escalation:**
- Database schema changes → @database
- Infrastructure/deployment → @infrastructure
- Frontend contract changes → @frontend
- Architectural decisions → @architect

---

### @frontend - Frontend Specialist

**Expertise**: React, NextJS, TypeScript, Storybook, client-side architecture.

**Use for:**
- React/NextJS component development
- TypeScript components with proper typing
- Storybook stories for component documentation
- Client-side state management (Context, Zustand, etc.)
- Performance optimization (memoization, lazy loading, code splitting)
- Responsive design and accessibility (WCAG compliance)

**Example invocations:**
```
@frontend create ProductCard component with image, price, add-to-cart button

@frontend implement infinite scroll with React Query for the products list

@frontend optimize the dashboard page - it's rendering slowly
```

**Escalation:**
- Backend API changes → @backend
- Database modifications → @database
- Infrastructure → @infrastructure
- Architectural decisions → @architect

---

### @database - Database Specialist

**Expertise**: PostgreSQL schema design, migrations, query optimization.

**Use for:**
- PostgreSQL schema design and normalization
- Migration files (up/down) with proper rollback strategies
- Query optimization and EXPLAIN analysis
- Indexing strategy (B-tree, partial, composite)
- Database performance tuning
- Constraint design (foreign keys, check constraints, unique)

**Example invocations:**
```
@database design schema for multi-tenant e-commerce with users, products, orders

@database optimize the slow product search query - it's taking 3 seconds

@database create migration to add soft delete to the users table
```

**Escalation:**
- Infrastructure (replication, sharding) → @infrastructure
- Major schema redesign → @architect
- Performance beyond query optimization → @architect

---

### @test - Testing Specialist

**Expertise**: Jest, Vitest, Playwright, test strategy, coverage analysis.

**Use for:**
- Unit tests (Jest/Vitest) with proper mocking
- E2E tests (Playwright) for critical user flows
- Storybook interaction tests
- Test strategy and coverage analysis
- Testing edge cases and error scenarios
- Test performance and flakiness debugging

**Example invocations:**
```
@test generate comprehensive unit tests for UserService with 90%+ coverage

@test create E2E test for the checkout flow from cart to payment confirmation

@test fix the flaky test in products.spec.ts - it fails randomly
```

**Escalation:**
- Performance/load testing → @infrastructure
- Testing infrastructure → @infrastructure
- Testing strategy decisions → @architect

---

### @reviewer - Code Reviewer

**Expertise**: Code quality, best practices, maintainability, performance.

**Use for:**
- Code quality review against project standards
- Best practices verification (SOLID, DRY, KISS)
- Security vulnerability identification
- Performance issue detection
- Test coverage assessment
- Naming conventions and code organization

**Example invocations:**
```
@reviewer review UserController for security, error handling, code quality

@reviewer check this PR for best practices violations and potential issues

@reviewer assess test coverage for the payment module
```

**Escalation:**
- Architectural concerns → @architect
- Major performance implications → @architect
- Security architecture issues → @security

---

### @security - Security Auditor

**Expertise**: Security vulnerabilities, authentication, authorization, compliance.

**Use for:**
- Security vulnerability audits (OWASP Top 10)
- Authentication/authorization review
- Input validation and sanitization checks
- Secrets management verification
- Dependency vulnerability scanning
- Compliance checks (GDPR, SOC2, PCI-DSS)

**Example invocations:**
```
@security audit the authentication system for vulnerabilities

@security review this payment endpoint for security issues

@security check if we're GDPR compliant with user data handling
```

**Escalation:**
- Critical vulnerabilities → **Immediate notification to user**
- Architectural security flaws → @architect
- Compliance questions → Product/Business stakeholders

---

### @debugger - Debugger Specialist

**Expertise**: Root cause analysis, performance debugging, error investigation.

**Use for:**
- Troubleshooting bugs and unexpected behavior
- Root cause analysis with systematic investigation
- Performance debugging (CPU, memory, network)
- Stack trace analysis
- Memory leak investigation
- Reproducing and isolating issues

**Example invocations:**
```
@debugger debug "Cannot read property id" error in UserService.getProfile

@debugger investigate why the API response time increases after 1 hour of runtime

@debugger find why the test suite is 3x slower than last week
```

**Escalation:**
- Infrastructure issues → @infrastructure
- Database performance → @database
- Architectural flaws → @architect
- Security incidents → @security

---

### @documentation - Documentation Specialist

**Expertise**: Technical writing, API docs, ADRs, user guides.

**Use for:**
- Technical documentation (architecture, design decisions)
- API documentation (endpoints, request/response formats)
- README files (installation, configuration, usage)
- Architecture Decision Records (ADRs)
- User guides and tutorials
- Code documentation standards

**Example invocations:**
```
@documentation create comprehensive README for the user-service microservice

@documentation write ADR for choosing PostgreSQL over MongoDB

@documentation generate API documentation for the products endpoints
```

**Escalation:**
- Architecture decisions → @architect
- Technical accuracy → Domain specialist

---

### @infrastructure - Infrastructure Specialist

**Expertise**: Docker, AWS, CI/CD, deployment, infrastructure as code.

**Use for:**
- Docker containerization (Dockerfile, docker-compose)
- AWS deployment (EC2, ECS, Lambda, RDS, S3)
- CI/CD pipelines (GitHub Actions, GitLab CI)
- Nix development environments
- Infrastructure as code (Terraform, CloudFormation)
- Monitoring and logging setup (CloudWatch, DataDog, Sentry)

**Example invocations:**
```
@infrastructure create production-ready Dockerfile for NestJS app

@infrastructure set up CI/CD pipeline for automated testing and deployment

@infrastructure configure auto-scaling for the API servers on AWS
```

**Escalation:**
- Major architectural changes → @architect
- Security architecture → @security
- Multi-region setup → @architect

---

## Delegation Best Practices

### 1. Be Specific

Vague requests lead to generic solutions. Provide details.

```
❌ BAD: "Review the code"

✅ GOOD: "Review UserController for security vulnerabilities, focusing on 
authentication, authorization, and input validation. Check for SQL injection 
and XSS risks. Prioritize findings by severity."
```

### 2. Provide Context

Specialists work better with full context.

```
✅ GOOD: "Create API endpoint for user registration. System uses JWT auth with 
refresh tokens stored in Redis. PostgreSQL database with user table already exists. 
Send welcome email via SendGrid after registration. Include validation for email 
uniqueness and password strength (min 8 chars, 1 number, 1 special char)."
```

### 3. Specify Expected Output

Define what success looks like.

```
✅ GOOD: "Design database schema for order management. 

Expected deliverables:
- ER diagram (Mermaid format)
- Migration files (up/down)
- Index strategy with rationale
- Explanation of design decisions (ADR format)"
```

### 4. Delegate in Parallel When Possible

Independent tasks can run concurrently.

**Example: Building a product listing feature**
```
User wants: Product listing page with filters, search, pagination

Parallel delegation (independent tasks):
1. @frontend - Create ProductList component with filters UI
2. @backend - Create products API with pagination and filtering
3. @database - Design products schema with proper indexes
4. @test - Create E2E test plan for product listing

Sequential integration (after parallel work completes):
5. Integrate frontend with backend API
6. @test - Execute E2E tests
7. @reviewer - Final code review
```

### 5. Sequential Delegation for Dependencies

When tasks depend on each other, delegate sequentially:

```
Feature: Multi-tenant e-commerce platform

Sequential delegation (dependencies):
1. @architect - Design multi-tenant architecture
   ↓ (architecture decisions inform database design)
2. @database - Create schema based on architecture
   ↓ (schema defines API contracts)
3. @backend - Implement API using schema
   ↓ (API consumed by frontend)
4. @frontend - Build UI consuming API
   ↓ (full feature implemented)
5. @test - Create comprehensive tests
   ↓ (tests validate implementation)
6. @reviewer - Code quality review
7. @security - Security audit
```

### 6. Provide Complete Context Upfront

Specialists work autonomously and cannot ask follow-up questions. Include:

- **What**: Exact requirements
- **Why**: Business/technical rationale
- **How**: Preferred approach or constraints
- **Where**: File paths, affected systems
- **Examples**: Similar implementations to reference

---

## Agent Communication Flow

```
User Request
    ↓
You (Main Agent)
    ↓
┌─────────────────────────────────────────┐
│  Assess Complexity & Domain             │
│  • Simple? → Implement yourself         │
│  • Complex? → Consider delegation       │
│  • Uncertain? → Start simple, iterate   │
└─────────────────────────────────────────┘
    ↓
Decision: Delegate or Implement
    ↓
┌─────────────────────────────────────────┐
│  IF Delegate:                           │
│  • Choose appropriate specialist        │
│  • Provide complete context             │
│  • Specify expected output              │
│  • Invoke specialist                    │
└─────────────────────────────────────────┘
    ↓
Specialist Works Autonomously
    ↓
┌─────────────────────────────────────────┐
│  Specialist:                            │
│  • Reads relevant code                  │
│  • Makes decisions in domain            │
│  • Implements solution                  │
│  • Returns complete result              │
└─────────────────────────────────────────┘
    ↓
You (Main Agent)
    ↓
┌─────────────────────────────────────────┐
│  Post-Delegation:                       │
│  • Review specialist output             │
│  • Integrate with other work            │
│  • Test integration                     │
│  • Present to user                      │
└─────────────────────────────────────────┘
```

---

## Escalation Chain

Escalate decisions upward when specialist's expertise is exceeded.

```
Level 1: Domain Specialists
@frontend, @backend, @database, @test, @infrastructure
    ↓
Level 2: Cross-Cutting Specialists
@reviewer (for code quality)
@security (for security issues)
@debugger (for bugs/performance)
@documentation (for docs)
    ↓
Level 3: Architecture Authority
@architect
(Final authority on all architectural decisions)
```

**Escalation Rules:**
- Domain specialists handle their domain
- Cross-domain issues escalate to @architect
- Security issues escalate to @security, then @architect if architectural
- All architectural decisions ultimately go to @architect

---

## Common Workflows

### New Feature Implementation

End-to-end feature development workflow:

1. **Architecture** (@architect): Design overall approach, technology choices
2. **Database** (@database): Schema design, migrations, indexes
3. **Backend** (@backend): API implementation, business logic
4. **Frontend** (@frontend): UI components, state management
5. **Testing** (@test): Unit tests, E2E tests, coverage verification
6. **Review** (@reviewer): Code quality check, best practices
7. **Security** (@security): Security audit, vulnerability scan
8. **Documentation** (@documentation): Update docs, API references

### Bug Fix

Systematic bug resolution workflow:

1. **Debugger** (@debugger): Root cause analysis, reproduction steps
2. **Implement fix**: You or appropriate domain specialist
3. **Test** (@test): Regression tests to prevent recurrence
4. **Review** (@reviewer): Ensure fix is correct and maintainable

### Performance Optimization

Performance improvement workflow:

1. **Debugger** (@debugger): Identify bottlenecks (profiling, monitoring)
2. **Specialist fixes**: Domain specialist implements optimization
   - Frontend performance → @frontend
   - API performance → @backend
   - Database performance → @database
3. **Test** (@test): Performance benchmarks, load testing
4. **Infrastructure** (@infrastructure): If infrastructure changes needed

### Security Audit

Comprehensive security review workflow:

1. **Security** (@security): Vulnerability audit, OWASP Top 10 check
2. **Fix critical issues**: Immediate fixes for high-severity issues
3. **Review** (@reviewer): Verify fixes don't introduce new issues
4. **Test** (@test): Security test coverage, penetration testing
5. **Documentation** (@documentation): Security documentation updates

### Refactoring

Code improvement without changing behavior:

1. **Reviewer** (@reviewer): Identify code smells, technical debt
2. **Architect** (@architect): Design refactoring strategy if large-scale
3. **Domain specialist**: Implement refactoring
4. **Test** (@test): Ensure no behavior changes (regression tests)
5. **Review** (@reviewer): Verify improvements

---

## Agent Behavior Guidelines

### All Agents Should

**Before making changes:**
- Read existing code to understand context and patterns
- Check related files for consistency
- Review project standards (`code-standards.md`, `security-guidelines.md`)
- Identify dependencies and potential impact

**When implementing:**
- Follow existing patterns and conventions
- Use project's established architecture
- Write clear, self-documenting code
- Add comments only for complex logic (why, not what)
- Reference files with format: `path/to/file.ts:123`

**After changes:**
- Run tests and ensure they pass
- Verify linting/formatting compliance
- Check for security implications
- Consider performance impact
- Update documentation if needed

**Communication:**
- Ask for clarification when requirements are ambiguous
- Provide rationale for technical decisions
- Surface tradeoffs and alternatives considered
- Flag potential issues proactively

### Main Agent (You) Should

**Task assessment:**
- Evaluate complexity before delegating
- Choose appropriate specialist(s) for the task
- Determine if parallel or sequential delegation

**Delegation:**
- Provide complete context to specialists
- Specify expected deliverables
- Set success criteria

**Integration:**
- Review specialist outputs for correctness
- Integrate work from multiple specialists
- Resolve conflicts between specialist recommendations
- Test cross-domain interactions

**Decision-making:**
- Make simple implementation decisions yourself
- Escalate architectural decisions to @architect
- Coordinate multi-domain changes
- Present final results to user

---

## Quick Reference

| Situation | Agent to Use |
|-----------|--------------|
| Simple task (<20 lines) | **Do it yourself** |
| Complex task in one domain | **Delegate to domain specialist** |
| Cross-domain task | **Coordinate multiple specialists** |
| Architecture decision | **@architect** |
| Technology stack choice | **@architect** |
| Security concern | **@security** |
| Bug investigation | **@debugger** |
| Performance issue | **@debugger** → specialist |
| Code quality review | **@reviewer** |
| Documentation needed | **@documentation** |
| New API endpoint | **@backend** |
| New UI component | **@frontend** |
| Database schema | **@database** |
| Tests needed | **@test** |
| Deployment/infrastructure | **@infrastructure** |

---

## Cost and Efficiency Considerations

### When Delegation Makes Sense

**High-value delegation scenarios:**
- Specialized domain knowledge required (database optimization, security audit)
- High complexity where specialist expertise reduces errors
- Parallel execution possible (multiple independent tasks)
- Quality critical (production system, user-facing feature)

**Low-value delegation scenarios:**
- Simple CRUD operations
- Boilerplate code generation
- Minor text/documentation changes
- One-line bug fixes

### Optimization Strategies

1. **Batch similar tasks**: Group related work for single specialist
2. **Minimize context switching**: Complete specialist work before moving on
3. **Reuse specialist knowledge**: Apply specialist recommendations to similar tasks yourself
4. **Learn from specialists**: Improve your own capabilities over time

### Quality vs Speed Tradeoffs

- **Prototype/MVP**: Implement yourself, iterate quickly
- **Production feature**: Delegate to specialists, prioritize quality
- **Critical system**: Multiple specialists (implementation + review + security)
- **Refactoring**: Specialists ensure maintainability

---

## Remember

**Simplicity First**: Start with the simplest solution. Add complexity only when needed.

**Delegate Strategically**: Delegation has overhead. Use it when the benefit exceeds the cost.

**Specialists Are Autonomous**: Provide complete context. They work independently.

**You Coordinate**: Main agent orchestrates. Specialists execute in their domain.

**Quality Matters**: Use specialists for critical, complex, or risky work.

**Iterate and Learn**: Over time, you'll develop intuition for when to delegate.
