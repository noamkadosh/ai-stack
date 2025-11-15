# Primary Agent Modes Guide

OpenCode now has **5 primary agent modes**, each optimized for specific workflows. Switch between modes using Tab key or clicking the mode selector.

> **Note**: For detailed agent delegation patterns and subagent usage, see [`AGENTS.md`](/docs/AGENTS.md).

---


## Overview

| Mode | Purpose | Tools | When to Use |
|------|---------|-------|-------------|
| **build** | Implementation | Read/Write/Edit/Bash | Default - building features, fixing bugs |
| **plan** | Analysis | Read only | Planning, research (no code changes) |
| **review** | Code Review | Read/Bash | Reviewing PRs, code quality checks |
| **debug** | Debugging | Read/Write/Edit/Bash (ask) | Investigating bugs, adding logs |
| **research** | Learning | Read/WebFetch | Documentation lookup, learning new tech |

---

## Mode Details

### 1. Build Mode (Default)

**Purpose**: Full implementation - write code, run tests, make changes

**Tools**:
- ✅ Read (code, files)
- ✅ Write (create new files)
- ✅ Edit (modify existing files)
- ✅ Bash (run commands, tests)
- ✅ All domain agents available

**Permissions**:
- Edit: Allowed
- Bash: Ask for destructive commands (`git push`, `npm publish`, `rm -rf`)

**Use for**:
- Implementing new features
- Fixing bugs
- Writing tests
- Refactoring code
- Database migrations
- Any code changes

**Example workflow**:
```
<build mode>
User: "Add user registration with email verification"

Agent:
1. @backend creates API endpoint
2. @frontend creates registration form
3. @database creates users table
4. @test writes E2E tests
5. Runs tests to verify
6. Opens PR
```

---

### 2. Plan Mode

**Purpose**: Analysis only - understand codebase, plan approach, no changes

**Tools**:
- ✅ Read (code, files)
- ❌ No Write
- ❌ No Edit
- ❌ No Bash
- ✅ All domain agents available (read-only)

**Use for**:
- Understanding unfamiliar codebase
- Planning implementation approach
- Estimating complexity
- Identifying risks
- Reviewing architecture
- Learning how code works

**Example workflow**:
```
<plan mode>
User: "How does the authentication system work?"

Agent:
1. Reads auth-related files
2. Traces authentication flow
3. Identifies JWT strategy, refresh tokens
4. Documents findings
5. Suggests improvements (but doesn't implement)
```

**Tip**: Use plan mode before build mode for complex features to understand existing patterns first.

---

### 3. Review Mode (NEW)

**Purpose**: Code review workflow - analyze quality, run tests, no modifications

**Tools**:
- ✅ Read (code, files)
- ✅ Bash (git diff, git log, npm test)
- ❌ No Write
- ❌ No Edit
- ✅ Domain agents available (@reviewer, @security, @performance)

**Permissions**:
- Bash: Allowed for git commands and tests
- Bash: Ask for other commands
- Edit: Denied

**Use for**:
- Reviewing pull requests
- Code quality checks
- Security audits
- Performance analysis
- Pre-merge reviews
- Evaluator-optimizer pattern

**Example workflow**:
```
<review mode>
User: "Review PR #123"

Agent:
1. Runs git diff to see changes
2. Analyzes code quality (@reviewer)
3. Checks security (@security)
4. Runs tests to verify
5. Provides structured feedback:
   - ✅ What's good
   - ⚠️  Issues found (severity levels)
   - 💡 Suggestions for improvement
```

**Review output format**:
```markdown
## Code Review Summary

### Overall Assessment
[Brief summary of changes and quality]

### Critical Issues (Must Fix)
- [ ] **Security**: Hardcoded API key in config.ts:23
- [ ] **Bug**: Missing null check in getUserById()

### High Priority
- [ ] **Performance**: N+1 query in user listing (use eager loading)
- [ ] **Best Practice**: Missing error handling in async function

### Suggestions
- 💡 Consider extracting validation logic to utility
- 💡 Add JSDoc comments for public API functions

### Test Coverage
- ✅ 85% coverage (target: 80%+)
- ⚠️  Missing tests for error scenarios

### Recommendation
❌ **REQUEST CHANGES** - Address critical issues before merging
✅ **APPROVE** - Looks good to merge
```

---

### 4. Debug Mode (NEW)

**Purpose**: Debugging workflow - investigate issues, add diagnostic logs

**Tools**:
- ✅ Read (code, files)
- ✅ Write (create log files, test files)
- ✅ Edit (add console.log, debug statements) - with permission
- ✅ Bash (run tests, diagnostics) - with permission
- ✅ Domain agents available (@debugger, @performance)

**Permissions**:
- Edit: Ask (to add logs/debug code)
- Bash: Ask (safety for diagnostic commands)

**Use for**:
- Investigating bugs
- Adding diagnostic logging
- Running debuggers
- Performance profiling
- Root cause analysis
- Reproducing issues

**Example workflow**:
```
<debug mode>
User: "API returns 500 error on user login"

Agent:
1. @debugger analyzes error logs
2. Identifies: "JWT secret undefined"
3. Asks permission to add debug logs
4. Adds console.log to trace issue
5. Runs npm test to reproduce
6. Identifies root cause: Missing .env variable
7. Suggests fix (but doesn't implement - switch to build mode)
```

**Debug output format**:
```markdown
## Debug Investigation Report

### Issue
API returns 500 error on POST /api/auth/login

### Root Cause
JWT_SECRET environment variable is undefined in production

### Evidence
1. Error log: "Error: secretOrPrivateKey must have a value"
2. File: src/auth/jwt.strategy.ts:12
3. Occurs when: Verifying JWT token
4. Environment: Production only (works in dev)

### Why It Happens
- .env.example has JWT_SECRET
- .env.production missing JWT_SECRET
- No validation on startup

### Recommended Fix
1. Add startup validation for required env vars
2. Add JWT_SECRET to production .env
3. Use secrets manager (AWS Secrets Manager)
4. Add health check endpoint

### Testing
Created reproduction test: src/auth/__tests__/jwt-missing-secret.test.ts
```

**After debugging**, switch to **build mode** to implement the fix.

---

### 5. Research Mode (NEW)

**Purpose**: Learning and documentation lookup - no code changes

**Tools**:
- ✅ Read (code, files)
- ✅ WebFetch (documentation, guides)
- ❌ No Write
- ❌ No Edit
- ❌ No Bash
- ✅ Context7 MCP (library documentation)
- ✅ AWS Documentation MCP

**Permissions**:
- WebFetch: Allowed (for docs.opencode.ai, MDN, etc.)

**Use for**:
- Learning new libraries/frameworks
- Reading documentation
- Understanding best practices
- Researching solutions
- Exploring APIs
- Technology comparison

**Example workflow**:
```
<research mode>
User: "How does React Server Components work in Next.js 14?"

Agent:
1. Fetches Next.js 14 documentation
2. Reads React docs on Server Components
3. Checks Context7 for Next.js guides
4. Summarizes key concepts:
   - Server Components (default)
   - Client Components ('use client')
   - Data fetching patterns
   - Performance benefits
5. Provides code examples
6. Suggests when to use each
```

**Research output format**:
```markdown
## Research: React Server Components in Next.js 14

### Summary
Server Components are the default in Next.js App Router. They run on the server only, reducing bundle size and improving performance.

### Key Concepts

**1. Server Components (Default)**
- Rendered on server
- No JavaScript sent to client
- Can access backend resources directly
- Cannot use hooks, event handlers

**2. Client Components**
- Marked with 'use client'
- Run on both server (initial render) and client
- Can use hooks, state, effects
- Interactive components

### When to Use Each

| Use Server Component | Use Client Component |
|---------------------|---------------------|
| Fetch data | Handle user interactions |
| Access backend | Use state/effects |
| Render static content | Access browser APIs |
| Large dependencies | Event handlers |

### Code Examples
[Examples with explanations]

### Best Practices
[Guidelines from official docs]

### Resources
- https://nextjs.org/docs/app/building-your-application/rendering/server-components
- https://react.dev/reference/rsc/server-components
```

---

## Mode Switching Strategy

### When to Switch Modes

**Build → Review**:
```
After implementing feature:
<TAB to review mode>
"Review the changes I just made for quality and security"
```

**Review → Build**:
```
After review identifies issues:
<TAB to build mode>
"Fix the issues identified in the review"
```

**Build → Debug**:
```
When bug occurs:
<TAB to debug mode>
"Investigate why the login endpoint returns 500"
```

**Debug → Build**:
```
After identifying root cause:
<TAB to build mode>
"Implement the fix for the JWT secret issue"
```

**Research → Build**:
```
After learning new pattern:
<TAB to build mode>
"Implement user registration using the pattern from React Hook Form docs"
```

---

## Workflow Combinations

### 1. Full Feature Development

```
Step 1: Research (if unfamiliar tech)
<research mode> Learn about Next.js Server Actions

Step 2: Plan
<plan mode> Analyze existing auth system, plan integration

Step 3: Build
<build mode> Implement server actions for form submission

Step 4: Review
<review mode> Check code quality, run tests

Step 5: Iterate (if needed)
<build mode> Address review feedback

Step 6: Final review
<review mode> Verify fixes
```

### 2. Bug Fix

```
Step 1: Debug
<debug mode> Investigate error, reproduce, identify root cause

Step 2: Build
<build mode> Implement fix, add regression test

Step 3: Review
<review mode> Verify fix doesn't break anything
```

### 3. Code Review

```
Step 1: Review
<review mode> Analyze PR, check quality/security/performance

Step 2: Feedback
Provide structured feedback to developer

Step 3: Re-review
<review mode> Verify changes after developer updates
```

---

## Keyboard Shortcuts

- **Tab**: Cycle through modes
- **Ctrl+1**: Build mode
- **Ctrl+2**: Plan mode
- **Ctrl+3**: Review mode
- **Ctrl+4**: Debug mode
- **Ctrl+5**: Research mode

---

## Best Practices

### 1. Start in the Right Mode

- ❌ Starting in build mode for learning: "How does auth work?" → Use research mode
- ✅ Starting in research mode for learning, then switch to build

### 2. Use Review Mode for Quality Gates

```
Standard workflow:
build → review → (iterate if needed) → approve → commit
```

### 3. Debug Mode for Investigation Only

- ✅ Use debug mode to find root cause
- ✅ Use build mode to implement fix
- ❌ Don't implement fixes in debug mode (limited edit permissions)

### 4. Leverage Mode Strengths

Each mode has optimized prompts and behaviors:
- **Build**: Action-oriented, implements solutions
- **Plan**: Analysis-oriented, provides options
- **Review**: Critical-oriented, finds issues
- **Debug**: Diagnostic-oriented, investigates problems
- **Research**: Learning-oriented, explains concepts

---

## Summary

**5 modes, each with specific purpose**:

1. **build** → Do things (implement, fix, create)
2. **plan** → Understand things (analyze, learn, plan)
3. **review** → Check things (quality, security, tests)
4. **debug** → Find things (bugs, root causes, issues)
5. **research** → Learn things (docs, patterns, concepts)

**Use the right mode for the right task** for optimal results.
