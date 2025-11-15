# Shared Agent Memory

How agents can share knowledge and context across sessions using the MCP Memory server.

---

## Overview

The Memory server provides a **knowledge graph** for persistent storage of:
- Architectural decisions
- Code patterns and conventions
- Known issues and solutions
- Project-specific context
- User preferences

**Benefits**:
- Agents remember decisions across sessions
- Consistent application of patterns
- Avoid repeating mistakes
- Share knowledge between agents
- Faster onboarding to project context

---

## How It Works

### Architecture

```
Primary Agent (build/plan/review)
    ↓ stores/retrieves
MCP Memory Server (knowledge graph)
    ↓ persists to
Docker Volume (claude-memory)
    ↓ format
JSONL (JSON Lines)
```

### Data Model

**Entities** (nodes):
- People, projects, concepts, technologies

**Relations** (edges):
- Connections between entities

**Observations** (facts):
- Information about entities

---

## MCP Memory Tools

### 1. create_entities

Create nodes in the knowledge graph:

```typescript
// Store architectural decision
{
  "name": "api_versioning_strategy",
  "entityType": "architecture_decision",
  "observations": [
    "Use URL path versioning (e.g., /api/v1/, /api/v2/)",
    "Decided on 2025-11-14",
    "Rationale: Clearer for clients, easier to deprecate old versions"
  ]
}
```

### 2. create_relations

Define relationships:

```typescript
{
  "from": "user_service",
  "to": "jwt_authentication",
  "relationType": "uses"
}
```

### 3. add_observations

Add facts about entities:

```typescript
{
  "entityName": "user_service",
  "observations": [
    "Must validate email uniqueness before creating user",
    "Rate limit: 100 requests per minute per user"
  ]
}
```

### 4. read_graph

Retrieve entire knowledge graph:

```typescript
// Returns all entities, relations, observations
```

### 5. search_nodes

Query by name, type, or content:

```typescript
{
  "query": "authentication",
  "searchType": "content"  // or "name" or "type"
}
```

### 6. delete_* operations

Cleanup operations:
- `delete_entities`
- `delete_observations`
- `delete_relations`

---

## What to Store

### Architectural Decisions

```typescript
// When @architect makes decision
create_entities({
  name: "database_choice",
  entityType: "architecture_decision",
  observations: [
    "Use PostgreSQL for primary datastore",
    "Reason: Strong ACID guarantees, JSON support, team expertise",
    "Alternatives considered: MongoDB (rejected - no transactions)",
    "Date: 2025-11-14"
  ]
})
```

### Code Patterns

```typescript
// When @reviewer identifies pattern
create_entities({
  name: "error_handling_pattern",
  entityType: "code_pattern",
  observations: [
    "Always wrap external API calls in try/catch",
    "Use NestJS exception filters for HTTP errors",
    "Log errors with logger.error(), not console.error()",
    "Example: src/users/users.service.ts:45"
  ]
})
```

### Known Issues

```typescript
// When @debugger solves issue
create_entities({
  name: "jwt_secret_validation",
  entityType: "known_issue",
  observations: [
    "Problem: JWT_SECRET undefined in production causes 500 errors",
    "Solution: Add startup validation in main.ts",
    "Root cause: Missing environment variable validation",
    "Fixed: 2025-11-14",
    "Regression test: src/auth/__tests__/startup-validation.spec.ts"
  ]
})
```

### Technology Choices

```typescript
// When researching/choosing libraries
create_entities({
  name: "form_library_choice",
  entityType: "technology_decision",
  observations: [
    "Use React Hook Form for forms",
    "Reason: Better performance than Formik, smaller bundle",
    "Integrates with Zod for validation",
    "Example usage: src/components/RegistrationForm.tsx"
  ]
})
```

### Coding Standards

```typescript
// Project-specific standards
create_entities({
  name: "component_structure",
  entityType: "coding_standard",
  observations: [
    "Props interface above component",
    "Components <120 lines (body only)",
    "Use Server Components by default",
    "Add 'use client' only when needed (state, effects, browser APIs)"
  ]
})
```

### Security Patterns

```typescript
// Security decisions
create_entities({
  name: "api_authentication",
  entityType: "security_pattern",
  observations: [
    "All API endpoints require JWT authentication (except /health)",
    "JWT secret stored in AWS Secrets Manager",
    "Refresh tokens stored in Redis with 7-day TTL",
    "Rate limiting: 100 req/min per user, 1000 req/min global"
  ]
})
```

---

## When to Store

### Automatically

Agents should store knowledge when:
- Making architectural decisions (@architect)
- Identifying reusable patterns (@reviewer)
- Solving bugs (@debugger)
- Choosing technologies (@research)
- Finding security issues (@security)
- Optimizing performance (@performance)

### Agent Guidelines

**@architect should store:**
- Every architectural decision
- Technology stack choices
- Design patterns to follow
- System boundaries and responsibilities

**@reviewer should store:**
- Code quality patterns
- Common mistakes to avoid
- Best practices for this project
- Coding standards violations found

**@debugger should store:**
- Root causes of bugs
- Solutions that worked
- Known issues and workarounds
- Common failure patterns

**@security should store:**
- Security requirements
- Vulnerability fixes
- Authentication/authorization patterns
- Compliance requirements

**@performance should store:**
- Performance targets met/failed
- Optimization techniques that worked
- Performance bottlenecks identified
- Caching strategies

---

## When to Retrieve

### Before Making Decisions

```typescript
// Check for existing decisions
search_nodes({
  query: "authentication",
  searchType: "content"
})

// If found: Use existing pattern
// If not found: Make decision and store
```

### Before Implementing

```typescript
// Check for known patterns
search_nodes({
  query: "form validation",
  searchType: "content"
})

// Use established patterns instead of reinventing
```

### Before Debugging

```typescript
// Check for known issues
search_nodes({
  query: "login 500 error",
  searchType: "content"
})

// May find existing solution
```

---

## Example Workflows

### Workflow 1: Making Architectural Decision

```
User: "Should we use REST or GraphQL?"

@architect:
1. Search memory: search_nodes({ query: "api architecture" })
2. Found: "Already using REST for /api/v1/* endpoints"
3. Decision: Continue with REST for consistency
4. Store decision:
   create_entities({
     name: "api_style_consistency",
     entityType: "architecture_decision",
     observations: [
       "Continue using REST for all APIs",
       "Reason: Existing infrastructure, team expertise, consistency",
       "Date: 2025-11-14"
     ]
   })
```

### Workflow 2: Code Review Pattern

```
User: "Review this new API endpoint"

@reviewer:
1. Search memory: search_nodes({ query: "api patterns" })
2. Found: "All APIs must have rate limiting, input validation, auth"
3. Check endpoint against standards
4. If new pattern emerges, store it:
   add_observations({
     entityName: "api_patterns",
     observations: [
       "Pagination pattern: Use cursor-based with limit parameter",
       "Example: src/products/products.controller.ts"
     ]
   })
```

### Workflow 3: Bug Investigation

```
User: "Login fails with JWT error"

@debugger:
1. Search memory: search_nodes({ query: "JWT error" })
2. Found: "jwt_secret_validation - JWT_SECRET undefined causes 500"
3. Check if same issue
4. If same: Apply known solution
5. If different: Store new issue after fixing
```

---

## Memory Management

### Periodic Cleanup

Memory accumulates over time. Periodically review and clean:

```typescript
// Delete outdated decisions
delete_entities({
  entityNames: ["old_framework_choice"]
})

// Remove solved issues
delete_observations({
  entityName: "known_issues",
  observations: ["Bug XYZ - fixed in v2.0"]
})
```

### Keep It Relevant

**Store**:
- ✅ Architectural decisions
- ✅ Recurring patterns
- ✅ Known issues (until fixed)
- ✅ Security requirements
- ✅ Performance targets

**Don't store**:
- ❌ Temporary debugging notes
- ❌ One-off solutions
- ❌ Implementation details that change frequently
- ❌ Personal preferences (unless team-wide)

---

## Storage Location

**Docker Volume**: `claude-memory:/app/dist`

**Format**: JSONL (JSON Lines)

**Persistence**: Data survives Docker container restarts

**Backup**: Consider backing up the volume periodically

```bash
# Backup memory
docker run --rm -v claude-memory:/data -v $(pwd):/backup alpine \
  tar czf /backup/memory-backup.tar.gz /data

# Restore memory
docker run --rm -v claude-memory:/data -v $(pwd):/backup alpine \
  tar xzf /backup/memory-backup.tar.gz -C /
```

---

## Security Considerations

### What NOT to Store

❌ **Never store**:
- API keys or secrets
- Passwords or tokens
- Personal identifiable information (PII)
- Sensitive business data
- Customer data

✅ **Safe to store**:
- Architectural decisions
- Code patterns
- Technology choices
- Performance targets
- Coding standards

### Access Control

Memory is shared across all agents and sessions. Store only information that should be universally accessible.

---

## MCP Memory Configuration

Already configured in your `opencode.json`:

```json
{
  "mcp": {
    "MCP_DOCKER": {
      "type": "local",
      "command": ["docker", "mcp", "gateway", "run", "--catalog", "mcp-servers"]
    }
  }
}
```

Memory server is defined in `mcp/docker/servers-catalog.yaml` and automatically available.

---

## Best Practices

### 1. Be Specific

```typescript
// ❌ Vague
{ name: "api_decision", observations: ["Use REST"] }

// ✅ Specific
{
  name: "api_versioning_strategy",
  observations: [
    "Use URL path versioning: /api/v1/, /api/v2/",
    "Rationale: Client compatibility, easier deprecation",
    "Date: 2025-11-14",
    "Decided by: @architect"
  ]
}
```

### 2. Use Consistent Entity Types

Standard entity types:
- `architecture_decision`
- `code_pattern`
- `known_issue`
- `technology_decision`
- `coding_standard`
- `security_pattern`
- `performance_target`

### 3. Include Context

Always include:
- Date when decision was made
- Who made it (which agent)
- Why (rationale)
- Where it's applied (file paths if relevant)

### 4. Update, Don't Duplicate

```typescript
// ❌ Creating duplicate
create_entities({ name: "error_handling_2" })

// ✅ Update existing
add_observations({
  entityName: "error_handling_pattern",
  observations: ["New pattern: Use Result<T, E> for expected errors"]
})
```

---

## Integration with Agents

Agents should automatically check memory:

**Before implementing**:
```
1. Search for existing patterns
2. Apply established conventions
3. Store new patterns if created
```

**Before deciding**:
```
1. Search for previous decisions
2. Follow existing architecture
3. Store new decisions
```

**After solving**:
```
1. Store solution
2. Link to related entities
3. Add observations
```

---

## Summary

**MCP Memory** enables:
- ✅ Persistent knowledge across sessions
- ✅ Consistent patterns and decisions
- ✅ Faster problem solving
- ✅ Knowledge sharing between agents
- ✅ Project-specific context

**Use it for**:
- Architectural decisions
- Code patterns
- Known issues
- Technology choices
- Security requirements

**Avoid storing**:
- Secrets or credentials
- Personal data
- Temporary notes
- One-off solutions
