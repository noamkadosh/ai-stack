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
| **3. VALIDATE** | BUILD agent | Run tests, linting, type-checking | - |
| **4. REVIEW** | @reviewer | **Evaluator-optimizer**: Code quality check, identify improvements | - |
| **5. ITERATE** | BUILD agent | Address review feedback (if needed), max 2 cycles | Domain specialists |
| **6. DOCUMENT** | @documentation | Update API docs, README, ADRs, code comments (skip for minor fixes) | - |
| **7. COMMIT** | Main agent (you) | Commit with conventional format (`feat:`, `fix:`, etc.), push to remote | - |
| **8. OPEN PR** | Main agent (you) | Create PR with `gh pr create`, describe changes, testing steps | - |
| **9. REVIEW LOOP** | Main agent (you) | User reviews → agent updates → repeat until approved | Domain specialists as needed |
| **10. MERGE** | User or you | **Squash merge** to main, delete branch, verify CI/CD | - |

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
└────────────────────────┬────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│  4. REVIEW (@reviewer - Evaluator-Optimizer Pattern)       │
│     • Code quality check                                    │
│     • Security scan                                         │
│     • Performance review                                    │
│     • Best practices verification                           │
└────────────────────────┬────────────────────────────────────┘
                         ↓
                 ┌───────┴────────┐
                 ↓                ↓
         Issues Found?        Approved?
                 ↓                ↓
┌────────────────┴────────────────────────────────────────────┐
│  5. ITERATE (if issues found, max 2 cycles)                │
│     • Address feedback                                      │
│     • Re-run VALIDATE                                       │
│     • Re-run REVIEW                                         │
└────────────────────────┬────────────────────────────────────┘
                         ↓ (if approved or max cycles)
┌─────────────────────────────────────────────────────────────┐
│  6. DOCUMENT                                                │
│     • Update docs, ADRs, comments                           │
└────────────────────────┬────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│  7. COMMIT                                                  │
│     • Commit with conventional format                       │
│     • Push to remote                                        │
└────────────────────────┬────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│  8. OPEN PR                                                 │
│     • Create PR with gh CLI                                 │
│     • Describe changes, testing steps                       │
└────────────────────────┬────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│  9. REVIEW LOOP ←──────────────┐                            │
│     • User reviews              │                            │
│     • Agent updates             │                            │
│     • Repeat until approved ────┘                            │
└────────────────────────┬────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│  10. MERGE                                                  │
│     • Squash merge to main                                  │
│     • Delete branch                                         │
└─────────────────────────────────────────────────────────────┘
```

### Evaluator-Optimizer Workflow (Step 4-5)

After implementing changes in BUILD mode, invoke @reviewer for quality gates:

**Review invocation:**
```
@reviewer review the changes in [files] for:
- Code quality and best practices
- Security vulnerabilities  
- Performance implications
- Test coverage adequacy
```

**Decision point:**
- ✅ **If @reviewer approves** → Proceed to DOCUMENT
- ❌ **If @reviewer flags issues** → ITERATE
  - Address critical/high priority issues
  - Re-run VALIDATE (tests must still pass)
  - Re-run REVIEW (verify fixes)

**Maximum iterations**: 2 review cycles
- After 2 cycles, present to user for decision
- Prevents infinite loops

**Example flow:**
```
User: "Add user login feature"
    ↓
BUILD: Implements @backend API + @frontend UI + @database schema
    ↓
VALIDATE: All tests pass ✅
    ↓
REVIEW (@reviewer): [HIGH] Missing rate limiting on login endpoint
    ↓
ITERATE: Adds rate limiting, updates tests
    ↓
VALIDATE: Tests pass ✅
    ↓
REVIEW (@reviewer): Approved ✅
    ↓
DOCUMENT: Updates API docs
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

## Agent Coordination Patterns

How to coordinate multiple agents for complex tasks.

### Pattern 1: Sequential (Dependencies)

**When to use**: Tasks must happen in order, output of one informs next

**Example:**
```
User: "Implement multi-tenant database architecture"

Sequential delegation:
1. @architect → Design multi-tenant schema
2. @database → Create schema (depends on #1 architecture)
3. @backend → Implement tenant isolation (depends on #2 schema)
4. @test → Create tests (depends on #1-3 implementation)
5. @security → Audit tenant isolation (depends on #1-4 completion)
6. @reviewer → Final code review
```

**Benefits**: Clear dependencies, each step informs next  
**Drawbacks**: Slower (sequential), blocks on each step

---

### Pattern 2: Parallel (Independent)

**When to use**: Tasks are independent, no dependencies, speed matters

**Example:**
```
User: "Build product listing page with filters"

Parallel delegation (simultaneous):
- @frontend → UI components (ProductList, FilterBar, ProductCard)
- @backend → API endpoints (GET /api/v1/products with query params)
- @database → Schema + indexes (products table, indexes on category, price)
- @test → E2E test plan (test filtering, sorting, pagination)

Then: Main agent integrates results
```

**Benefits**: Fast (parallel execution), maximizes throughput  
**Drawbacks**: Integration complexity, potential conflicts

---

### Pattern 3: Iterative (Refinement)

**When to use**: Measurable success criteria, iterative improvement possible

**Example:**
```
User: "Optimize dashboard performance to load in <1 second"

Iteration loop (max 3 cycles):
1. @performance → Analyze bottlenecks (measure current: 5s)
2. @backend/@frontend → Implement top 3 fixes (parallel)
3. @performance → Re-measure (current: 2.5s)
4. Repeat until target (<1s) or max iterations

Iteration 1: 5s → 2.5s (caching, code splitting)
Iteration 2: 2.5s → 1.2s (lazy loading, query optimization)
Iteration 3: 1.2s → 0.8s (memoization, indexes) ✅ Target met
```

**Benefits**: Continuous improvement, measurable progress  
**Drawbacks**: Time-consuming, may not reach target

---

### Pattern 4: Cascade (Escalation)

**When to use**: Agent encounters decision beyond its domain expertise

**Example:**
```
@backend working on API endpoint:
"This pagination approach affects frontend, database, and caching strategy"
    ↓ escalate (decision beyond backend domain)
    
@architect makes architectural decision:
"Use cursor-based pagination with Redis caching"
    ↓ delegate back with decision
    
@backend implements per architecture
@database creates indexes per architecture
@frontend consumes API per architecture
```

**Benefits**: Expertise applied appropriately, consistent decisions  
**Drawbacks**: Coordination overhead, potential delays

---

### Choosing the Right Pattern

| Scenario | Pattern | Why |
|----------|---------|-----|
| New feature spanning domains | **Parallel** | Independent work, faster delivery |
| Database migration | **Sequential** | Schema → Backend → Frontend dependencies |
| Performance optimization | **Iterative** | Measure → Improve → Re-measure loop |
| API design disagreement | **Cascade** | Escalate to @architect for decision |
| Bug fix in one domain | **None** | Handle directly, no coordination needed |

---

## Specialized Agents

This project has **12 specialized subagents**. Each is an expert in their domain.

> **Note**: These are OpenCode "subagents" - they are invoked by primary agents (or manually with @ mention) for focused tasks. They work autonomously and create child sessions. They are **not** meant to be full conversation partners, but specialized tools for specific tasks.

---

## Agent Categories

Agents are organized into two categories based on their applicability:

### Universal Agents (Cross-Domain)

These agents work across ALL domains and tech stacks:

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| **@reviewer** | Code quality across all languages | After any implementation |
| **@security** | Security audit across all domains | Before deployment, after auth/permission changes |
| **@debugger** | Troubleshoot any issue | When bugs occur in any domain |
| **@performance** | Optimize any bottleneck | When performance issues detected anywhere |
| **@refactoring** | Improve any code quality | When technical debt accumulates |
| **@documentation** | Write docs for anything | After features, for APIs, ADRs |

**Characteristics**:
- No domain-specific knowledge required
- Apply general principles (SOLID, security, performance)
- Can be invoked for frontend, backend, database, or infrastructure code

---

### Conditional Agents (Domain-Specific)

These agents only work in specific technology domains:

| Agent | Domain | Tech Stack | When NOT to Use |
|-------|--------|------------|-----------------|
| **@architect** | Multi-domain planning | All (coordination) | Simple single-domain tasks |
| **@backend** | Server-side code | NestJS, Node.js, REST, GraphQL | Frontend or database work |
| **@frontend** | Client-side code | React, NextJS, TypeScript | Backend or database work |
| **@database** | Data layer | PostgreSQL | Application logic |
| **@test** | Testing code | Jest, Vitest, Playwright | Production code |
| **@infrastructure** | DevOps/deployment | Docker, AWS, Nix, CI/CD | Application code |

**Characteristics**:
- Deep domain expertise
- Domain-specific tools and patterns
- May not apply to other tech stacks

---

### Decision Tree: Which Agent to Use?

```
Is this a code quality/security/performance/debugging issue?
    ↓ YES
    → Use Universal Agent (@reviewer, @security, @performance, @debugger)
    
    ↓ NO
    
Does this require domain-specific technical knowledge?
    ↓ YES
    → Use Conditional Agent (@backend, @frontend, @database, etc.)
    
    ↓ NO
    
Is it an architectural decision affecting multiple domains?
    ↓ YES
    → Escalate to @architect
    
    ↓ NO
    
Simple enough to handle yourself?
    ↓ YES
    → Implement directly (no delegation needed)
```

---

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

### @performance - Performance Optimizer

**Expertise**: Performance analysis, bottleneck identification, optimization strategies.

**Use for:**
- Identify performance bottlenecks (CPU, memory, network, database)
- Profile application performance
- Bundle size analysis and optimization
- Database query performance analysis
- React rendering optimization
- Caching strategy recommendations

**Example invocations:**
```
@performance analyze why the dashboard page takes 5 seconds to load

@performance identify N+1 queries in the user listing endpoint

@performance review bundle size - it's 450KB and should be <200KB
```

**Escalation:**
- Architectural performance issues → @architect
- Infrastructure scaling → @infrastructure
- Database schema redesign → @database
- Algorithm optimization → Domain specialist

---

### @refactoring - Refactoring Specialist

**Expertise**: Code quality improvements, design pattern application, technical debt reduction.

**Use for:**
- Apply SOLID principles and design patterns
- Extract reusable code (DRY principle)
- Simplify complex functions (KISS)
- Remove code duplication
- Improve naming and readability
- Modernize legacy code

**Example invocations:**
```
@refactoring improve UserService - it's 350 lines and has 4 responsibilities

@refactoring extract duplicate validation logic across controllers

@refactoring apply Strategy pattern to payment processing code
```

**Escalation:**
- Architectural refactoring → @architect
- Performance optimization → @performance
- Database schema changes → @database
- Security improvements → @security

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
Level 1: Domain Specialists (Implementation)
@frontend, @backend, @database, @test, @infrastructure, @documentation
    ↓
Level 2: Cross-Cutting Specialists (Analysis & Improvement)
@reviewer (for code quality)
@refactoring (for code improvement)
@performance (for optimization)
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

## Safety Guardrails

Critical safeguards to prevent destructive operations.

### High-Risk Operations (Always Ask User)

These operations MUST get explicit user confirmation:

#### 1. Data Loss Risk
- Database schema drops (`DROP TABLE`, `DROP COLUMN`)
- File deletions (`rm`, `delete`, especially `rm -rf`)
- Git force push (`git push --force`)
- Production deployments
- Irreversible migrations

#### 2. Security Risk
- Authentication system changes
- Permission/role modifications
- API key rotation
- CORS configuration changes
- Security header modifications

#### 3. Breaking Changes
- Public API modifications (versioned endpoints)
- Database migrations affecting production
- Dependency major version upgrades
- Contract changes (API, GraphQL schema)

---

### Checkpoint Pattern

When agent detects high-risk operation:

```
Agent detects HIGH-RISK operation
    ↓
PAUSE execution
    ↓
Show user:
- What operation is planned
- Why it's high-risk
- What could go wrong
- Recommended mitigation
    ↓
Wait for EXPLICIT user approval
    ↓
If APPROVED → Execute with extra caution (backups, rollback plan)
If REJECTED → Suggest safer alternative
```

---

### Example: Database Migration Checkpoint

```
@database: "About to drop 'legacy_users' table for migration"
    ↓ CHECKPOINT
    
⚠️  HIGH-RISK OPERATION DETECTED

Operation: DROP TABLE legacy_users
Risk Level: 🔴 CRITICAL
Impact: Data loss for 10,000+ user records
Reason: Migration consolidates users into new table

Mitigation checklist:
[ ] Backup database
[ ] Verify data copied to new table
[ ] Create rollback migration
[ ] Test on staging first
[ ] Schedule maintenance window

Proceed? [yes/NO] _
```

---

### Safety By Default

Agents should:
- ✅ Assume production environment unless stated otherwise
- ✅ Create backups before destructive operations
- ✅ Write reversible migrations (up + down)
- ✅ Use soft deletes instead of hard deletes
- ✅ Ask before executing bash commands with `rm`, `drop`, `force`
- ✅ Validate data integrity before/after changes

---

## Error Handling & Recovery

How to handle agent failures and conflicts.

### Common Failure Modes

#### 1. Agent Can't Complete Task

**Symptoms**: Agent returns "I cannot complete this task" or gets stuck

**Recovery steps:**
```
Step 1: Verify agent is correct for domain
Problem: @frontend invoked for database schema?
Fix: Use @database instead

Step 2: Break down task further
Problem: Task too complex for single agent?
Fix: Manual decomposition into smaller subtasks

Step 3: Provide more context
Problem: Missing requirements or unclear specs?
Fix: Add detailed specifications, examples, constraints

Step 4: Escalate if needed
Problem: @backend stuck on architectural decision?
Fix: Escalate to @architect for guidance
```

---

#### 2. Agent Produces Incorrect Output

**Symptoms**: Code doesn't work, tests fail, wrong approach taken

**Recovery steps:**
```
Step 1: Invoke @reviewer to diagnose
@reviewer review [agent output] for correctness and identify specific issues

Step 2: Provide SPECIFIC feedback (not generic)
❌ BAD: "This is wrong, fix it"
✅ GOOD: "The authentication should use JWT (not sessions).
          Refer to existing implementation in src/auth/jwt.strategy.ts
          for the correct pattern."

Step 3: Re-invoke with corrections
@backend fix authentication to use JWT following the pattern in 
src/auth/jwt.strategy.ts

Step 4: Hard stop after 2 failed attempts
After 2 attempts → Present to user for decision or implement yourself
```

---

#### 3. Agents Conflict (Disagreement)

**Symptoms**: @frontend and @backend disagree on API contract, data format, etc.

**Recovery:**
```
Escalate to @architect for authoritative decision:

@architect resolve API contract disagreement:

Context:
- @frontend expects: GET /api/users → User[]
- @backend implemented: GET /api/users → { data: User[], meta: {...} }

Which approach should we standardize on project-wide?
```

**After @architect decides:**
- Affected agents update their implementations
- Document decision in ADR (Architecture Decision Record)
- Update coding standards if pattern applies broadly

---

#### 4. Infinite Loop / Agent Stuck

**Symptoms**: Agent repeatedly tries same failed approach

**Hard stop protocol:**
```
Attempt 1: Original approach (agent's first try)
    ↓ FAILS
Attempt 2: Agent self-corrects (agent tries different way)
    ↓ FAILS
Attempt 3: With explicit guidance from you (specific instructions)
    ↓ FAILS
    
STOP → Human intervention required

Present to user:
1. What was attempted (all 3 approaches)
2. Why each failed (error messages, root cause)
3. Request human guidance or suggest alternative approach
```

**Prevent infinite loops:**
- Maximum 3 attempts per agent per task
- Track attempt count automatically
- After max attempts, escalate to user

---

#### 5. Integration Conflicts

**Symptoms**: Work from multiple agents doesn't integrate properly

**Recovery:**
```
Step 1: Identify conflict
Example: @frontend built UI expecting sync API,
         @backend built async API with job queues

Step 2: Determine correct approach
- Check architectural decisions (@architect)
- Review project patterns (existing code)
- Consider user requirements

Step 3: Reconcile
Option A: Update @frontend to handle async
Option B: Add sync endpoint in @backend
Option C: Hybrid (sync for simple, async for complex)

Step 4: Update both agents with decision
@frontend: Update to handle async responses
@backend: Add webhook for job completion notification
```

---

### Error Prevention Best Practices

**Before delegating:**
- ✅ Clearly define success criteria
- ✅ Specify constraints and requirements
- ✅ Provide examples of expected output
- ✅ Reference existing patterns to follow

**During execution:**
- ✅ Monitor for early warning signs (agent uncertainty, multiple attempts)
- ✅ Intervene early if agent shows signs of struggle
- ✅ Provide course corrections before complete failure

**After failures:**
- ✅ Document what failed and why
- ✅ Update agent instructions if pattern repeats
- ✅ Consider if task should be broken down differently

---

## Quick Start Workflows

Common scenarios with exact agent invocation patterns.

### Workflow 1: New Feature End-to-End

```bash
# USER: "Build user notification system with email and in-app notifications"

# Step 1: Architecture (if feature is complex)
@architect design notification system architecture including:
- Delivery channels (email, in-app, push)
- Storage (notification preferences, history)
- Queueing strategy (immediate vs batched)

# Step 2: Parallel implementation
@database create notifications schema with:
- notifications table (id, user_id, type, content, read_at, created_at)
- notification_preferences table (user_id, channel, enabled)
- indexes on user_id and created_at

@backend create notifications API:
- POST /api/v1/notifications (create notification)
- GET /api/v1/notifications (list user's notifications)
- PATCH /api/v1/notifications/:id/read (mark as read)
- Background job for email delivery

@frontend create notification components:
- NotificationBell (shows unread count)
- NotificationList (dropdown with notifications)
- NotificationPreferences (user settings)

# Step 3: Testing
@test create E2E tests for:
- User receives notification
- Email is sent
- Notification is marked as read
- Preferences are respected

# Step 4: Quality gates (AUTOMATIC via evaluator-optimizer)
@reviewer reviews all changes
@security audits notification system

# Step 5: Documentation
@documentation update:
- API documentation for notification endpoints
- User guide for notification preferences
```

---

### Workflow 2: Bug Fix

```bash
# USER: "Login fails with 500 error after password reset"

# Step 1: Investigation
@debugger investigate "Login fails with 500 error after password reset"
Expected output:
- Root cause analysis
- Reproduction steps
- Affected code locations

# Step 2: Implement fix based on root cause
# (Suppose @debugger found: "Password hash not updated in database")
@backend fix password reset to update hash in database:
- File: src/auth/auth.service.ts
- Function: resetPassword()
- Issue: Sends email but doesn't save new hash

# Step 3: Regression test
@test add regression test for password reset bug:
- Test: User can login after password reset
- Verify: New password hash is saved
- Verify: Old password no longer works

# Step 4: Review
@reviewer verify bug fix doesn't introduce new issues
```

---

### Workflow 3: Performance Optimization

```bash
# USER: "Dashboard takes 5 seconds to load, target is <1 second"

# Step 1: Analysis
@performance analyze why dashboard takes 5 seconds to load
Expected output:
- Bottleneck identification (database, rendering, network)
- Ranked list of optimization opportunities
- Expected impact of each

# Step 2: Implement top 3 fixes (parallel)
@frontend implement code-splitting for dashboard:
- Lazy load heavy components
- Use React.lazy() for charts library
- Expected: 450KB → 150KB bundle

@backend add caching to products endpoint:
- Redis cache for product listings (5 min TTL)
- Cache invalidation on product updates
- Expected: 800ms → 50ms response time

@database add index on products.created_at:
- CREATE INDEX idx_products_created_at ON products(created_at DESC)
- Expected: Full table scan → index scan

# Step 3: Measure improvement
@performance re-measure dashboard load time after optimizations
Target: <1 second

# Step 4: Iterate if needed
# If still >1s, @performance suggests next round of fixes
```

---

### Workflow 4: Security Audit

```bash
# USER: "Audit authentication system for security vulnerabilities"

# Step 1: Comprehensive audit
@security audit authentication system for OWASP Top 10:
- A01: Broken Access Control
- A02: Cryptographic Failures  
- A03: Injection
- A07: Identification and Authentication Failures
Focus on: JWT implementation, password storage, session management

# Step 2: Review findings and prioritize
@security provides report with severity levels:
- CRITICAL: Fix immediately (e.g., hardcoded secret)
- HIGH: Fix before next release (e.g., weak password policy)
- MEDIUM: Fix in next sprint (e.g., missing rate limiting)
- LOW: Technical debt (e.g., deprecated crypto library)

# Step 3: Fix critical/high issues
@backend fix critical security issues:
1. Move JWT secret to environment variable
2. Implement rate limiting on login endpoint
3. Add account lockout after 5 failed attempts

# Step 4: Re-audit
@security verify fixes for [specific vulnerabilities]

# Step 5: Documentation
@documentation document security measures for compliance:
- How authentication works
- Security controls in place
- Compliance with OWASP guidelines
```

---

### Workflow 5: Code Refactoring

```bash
# USER: "UserService is 350 lines with 4 responsibilities - refactor it"

# Step 1: Analysis
@reviewer analyze UserService for code smells and suggest refactoring strategy:
- Identify distinct responsibilities
- Suggest class extraction
- Highlight violation of Single Responsibility Principle

# Step 2: Refactoring strategy (if complex)
@architect design refactoring approach for UserService:
- UserService (core user management)
- UserAuthenticationService (login, logout, password)
- UserProfileService (profile updates, avatar)
- UserNotificationService (email, preferences)

# Step 3: Implement refactoring
@refactoring split UserService into 4 services per @architect design:
- Extract methods into new services
- Update dependency injection
- Maintain backwards compatibility
- Update tests

# Step 4: Verify no behavior changes
@test ensure all existing tests still pass:
- Run full test suite
- Add integration tests if needed
- Verify API contracts unchanged

# Step 5: Quality check
@reviewer verify refactoring improves code quality:
- Reduced complexity
- Better separation of concerns
- Improved testability
```

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
| Performance bottleneck | **@performance** |
| Code quality review | **@reviewer** |
| Code refactoring | **@refactoring** |
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
