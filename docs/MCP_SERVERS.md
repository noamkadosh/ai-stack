# MCP Servers Reference

Documentation for the 11 MCP servers configured in this repository's catalog (`mcp/docker/servers-catalog.yaml`).

**Last Updated**: November 14, 2025  
**Gateway**: Single gateway with dynamic tool loading  
**Total Servers**: 11

---

## Table of Contents

- [How Agents Use MCP Servers](#how-agents-use-mcp-servers)
- [Overview](#overview)
- [Server List](#server-list)
- [Detailed Documentation](#detailed-documentation)
  - [Code Index](#1-code-index-mcp)
  - [Memory](#2-memory)
  - [GitHub Official](#3-github-official)
  - [Context7](#4-context7)
  - [Playwright](#5-playwright)
  - [Docker](#6-docker)
  - [Obsidian](#7-obsidian)
  - [Sequential Thinking](#8-sequential-thinking)
  - [AWS Core](#9-aws-core-mcp-server)
  - [AWS Documentation](#10-aws-documentation)
  - [Next.js DevTools](#11-nextjs-devtools-mcp)
- [Security Considerations](#security-considerations)
- [Quick Reference](#quick-reference)

---

## How Agents Use MCP Servers

### Direct Tool Invocation

**You already have access to all MCP tools!** OpenCode automatically runs the MCP Gateway in the background, making all server tools available without manual setup.

**To use an MCP server tool:**
1. Simply call the tool using the `MCP_DOCKER_mcp-exec` function
2. The Gateway automatically starts the server container if needed
3. The tool executes and returns results

**Example - Using GitHub MCP Server:**
```typescript
// List pull requests
await MCP_DOCKER_mcp-exec({
  name: "list_pull_requests",
  arguments: {
    owner: "docker",
    repo: "docs",
    state: "open"
  }
});

// Create a pull request
await MCP_DOCKER_mcp-exec({
  name: "create_pull_request",
  arguments: {
    owner: "myuser",
    repo: "myrepo",
    title: "Add feature X",
    head: "feature-branch",
    base: "main",
    body: "Description of changes"
  }
});
```

**Example - Using Memory MCP Server:**
```typescript
// Store knowledge
await MCP_DOCKER_mcp-exec({
  name: "create_entities",
  arguments: {
    entities: [{
      name: "coding_pattern_authentication",
      entityType: "code_pattern",
      observations: [
        "Always use bcrypt for password hashing",
        "JWT tokens expire in 24h",
        "Implemented in src/auth/auth.service.ts"
      ]
    }]
  }
});

// Search knowledge
await MCP_DOCKER_mcp-exec({
  name: "search_nodes",
  arguments: {
    query: "authentication",
    searchType: "type"
  }
});
```

### Server Lifecycle (Automatic)

The MCP Gateway handles everything:
1. **First tool call**: Gateway starts the server container
2. **Subsequent calls**: Reuses running container (fast!)
3. **Idle timeout**: Container stops automatically after 10 minutes of inactivity
4. **Dynamic loading**: Only active servers consume resources

### Available CLI Commands

**Check server status:**
```bash
docker mcp server list
```

**Enable/disable servers:**
```bash
# Enable a server
docker mcp server enable github-official

# Disable a server
docker mcp server disable github-official
```

**View available tools:**
```bash
# List all tools from all servers
docker mcp tool ls

# List tools from specific server
docker mcp tool ls github-official
```

**Gateway management:**
```bash
# Start gateway
docker mcp gateway run --catalog mcp-servers

# Check gateway status
docker ps | grep mcp-gateway
```

### Troubleshooting

**"Tool not found" error:**
1. Check if server is enabled: `docker mcp server list`
2. Enable if needed: `docker mcp server enable <server-name>`
3. Verify tool exists: `docker mcp tool ls <server-name>`

**Server not responding:**
1. Check logs: `docker logs <container-name>`
2. Restart Gateway: OpenCode will restart it automatically
3. Check secrets configured: `docker secret ls`

---

## Overview

This repository uses Docker MCP Gateway with **dynamic tool loading** enabled. All MCP servers are available to all agents, but containers only run when tools are actively being used.

### Architecture

- **Gateway**: Single instance serving all agents via Docker MCP CLI
- **Transport**: Managed by OpenCode via `docker mcp gateway run --catalog mcp-servers`
- **Dynamic Loading**: Servers spin up/down automatically based on tool usage
- **Configuration**: Defined in `mcp/docker/servers-catalog.yaml`
- **Tool Access**: Use `MCP_DOCKER_mcp-exec` to invoke any tool from any enabled server

### Key Benefits

- **Resource Efficient**: Servers only run when needed (10-minute idle timeout)
- **Full Capability**: All agents can access all tools from all enabled servers
- **Zero Management**: No manual server start/stop required (fully automatic)
- **Isolated Execution**: Each server runs in its own container with resource limits
- **Automatic Authentication**: Gateway injects credentials from Docker secrets

### How the Gateway Works

```
┌─────────────┐          ┌──────────────────┐          ┌─────────────────┐
│   Agent     │          │   MCP Gateway    │          │   MCP Servers   │
│  (OpenCode) │───────>  │   (Proxy)        │───────>  │  (Containers)   │
└─────────────┘          └──────────────────┘          └─────────────────┘
                              │                              │
                              │  1. Tool request             │
                              │  2. Start container (if off)  │
                              │  3. Inject secrets            │
                              │  4. Forward request           │
                              │  5. Return result             │
                              │  6. Log call trace            │
```

**Request Flow:**
1. Agent calls tool using `MCP_DOCKER_mcp-exec`
2. Gateway identifies which server provides that tool
3. Gateway starts server container if not running (< 1 second)
4. Gateway injects required credentials from Docker secrets
5. Gateway forwards tool request to server
6. Server executes tool and returns result
7. Gateway logs activity and returns result to agent

---

## Server List

| Server | Type | Purpose | Security Risk |
|--------|------|---------|---------------|
| **code-index** | Local Build | Semantic code search & analysis | Low |
| **memory** | Docker Hub | Knowledge graph for persistent context | Low |
| **github-official** | Docker Hub | GitHub API integration | Medium |
| **context7** | Docker Hub | Library documentation lookups | Low |
| **playwright** | Docker Hub | Browser automation & testing | Low |
| **docker** | Docker Hub (POCI) | Docker CLI access | **High** |
| **obsidian** | Docker Hub | Obsidian vault access | Low |
| **sequentialthinking** | Docker Hub | Structured problem-solving framework | Low |
| **aws-core-mcp-server** | Docker Hub | AWS expert guidance & prompts | Low |
| **aws-documentation** | Docker Hub | AWS documentation search | Low |
| **next-devtools-mcp** | Docker Hub | Next.js development tools | Low |

---

## Detailed Documentation

### 1. Code Index MCP

**Image**: `local/code-index-mcp:latest`  
**Type**: Local build from submodule  
**Repository**: https://github.com/johnhuang316/code-index-mcp

#### Purpose
Intelligent code indexing and semantic search across your codebase using Tree-sitter AST parsing. Provides symbol-level navigation and deep code analysis.

#### Key Tools
- `set_project_path` - Initialize indexing for project
- `search_code_advanced` - Regex, fuzzy search with pagination
- `find_files` - Glob pattern file search
- `get_file_summary` - File structure analysis
- `build_deep_index` - Full symbol-level indexing
- `refresh_index` - Update file index
- `configure_file_watcher` - Auto-refresh on changes

#### Supported Languages
**Tree-sitter AST Parsing**: Python, JavaScript, TypeScript, Java, Go, Objective-C, Zig  
**Fallback Strategy**: 50+ languages including C/C++, Rust, Ruby, PHP, C#, Kotlin, Scala, Swift

#### Environment Variables
- `CODEBASE_PATH=/workspace` - Project path to index

#### Use Cases
- Find all function/class usages
- Code structure analysis
- Symbol-level refactoring
- Architecture documentation
- Call chain debugging

#### Building
```bash
cd mcp/servers/code-index-mcp
docker build -t local/code-index-mcp:latest .
```

#### Notes
- Large codebases benefit from pre-indexing with `build_deep_index`
- File watcher requires watchdog library
- Read-only analysis - safe for all agents
- Results paginated (10 per page by default)

---

### 2. Memory

**Image**: `mcp/memory@sha256:db0c2db...`  
**Type**: Official MCP Server  
**Repository**: https://github.com/modelcontextprotocol/servers

#### Purpose
Knowledge graph-based persistent memory system. Enables agents to store and retrieve context, patterns, and decisions across sessions.

#### Key Tools
- `create_entities` - Create nodes (people, projects, concepts)
- `create_relations` - Define relationships between entities
- `add_observations` - Store facts about entities
- `read_graph` - Retrieve entire knowledge graph
- `search_nodes` - Query by name, type, or content
- `delete_entities` / `delete_observations` / `delete_relations` - Cleanup operations

#### Storage
- **Format**: JSONL (JSON Lines)
- **Location**: `/app/dist` in container (persisted via Docker volume `claude-memory`)
- **Volume**: `claude-memory:/app/dist`

#### Use Cases
- Store architectural decisions across sessions
- Remember coding conventions and patterns
- Track project-specific context
- Maintain user preferences
- Record solutions to common problems

#### Notes
- Accumulates data over time - periodic cleanup recommended
- No built-in encryption - don't store credentials
- Shared knowledge base across all agents
- JSONL format can grow large with heavy use

---

### 3. GitHub Official

**Image**: `ghcr.io/github/github-mcp-server@sha256:2f9c6e9...`  
**Type**: Official GitHub MCP Server  
**Repository**: https://github.com/github/github-mcp-server

#### Purpose
Complete GitHub API integration for repository management, issue tracking, PR workflows, and code review.

#### Key Tools
**Issues & PRs**:
- `issue_read` / `issue_write` - Issue management
- `pull_request_read` / `pull_request_review_write` - PR workflows
- `list_issues` / `list_pull_requests` - Query operations
- `search_code` / `search_issues` / `search_pull_requests` - GitHub search

**Repository Operations**:
- `create_repository` / `fork_repository` - Repo creation
- `create_branch` / `list_branches` - Branch management
- `get_file_contents` / `create_or_update_file` / `delete_file` - File operations
- `push_files` - Batch file commits
- `get_commit` / `list_commits` - Commit history

**Advanced**:
- `assign_copilot_to_issue` - GitHub Copilot integration
- `request_copilot_review` - Automated code review
- `sub_issue_write` - Sub-issue management
- `get_teams` / `get_team_members` - Team operations

#### Authentication
**Required**: GitHub Personal Access Token  
**Scopes**: `repo`, `read:org`, `read:user`, `workflow`

**Setup via Docker Secret**:
```bash
echo "ghp_your_token" | docker secret create github.personal_access_token -
```

**OAuth Support**: Available via Docker MCP OAuth provider

#### Allowed Hosts
- `api.github.com:443`
- `github.com:443`
- `raw.githubusercontent.com:443`

#### Use Cases
- Automated PR creation and updates
- Issue triage and management
- Code review submission
- Release planning
- Documentation updates

#### Security Notes
- Token = repository access - use minimal scopes
- Rate limits: 5000 req/hour (authenticated)
- Can create/delete branches and files
- Use fine-grained tokens when possible

---

### 4. Context7

**Image**: `mcp/context7@sha256:1174e6a...`  
**Type**: Remote service integration  
**Website**: https://context7.com

#### Purpose
Quick access to up-to-date library and framework documentation for rapid reference lookups.

#### Key Tools
- `resolve-library-id` - Find library identifier from name
- `get-library-docs` - Fetch documentation for library

#### Supported Libraries
- **Frontend**: React, Next.js, Vue, Angular, Svelte, Storybook
- **Backend**: NestJS, Express, Fastify, Node.js
- **Database**: PostgreSQL, MongoDB, Redis, Prisma
- **Testing**: Jest, Vitest, Playwright, Cypress
- And many more...

#### Environment Variables
- `MCP_TRANSPORT=streaming` - Set transport mode

#### Use Cases
- "What's the API for X in React 18?"
- Quick syntax lookups
- Check latest API changes
- Migration guide references
- Framework best practices

#### Notes
- Requires Context7 API subscription
- No token optimization - returns full pages
- Best for quick reference lookups
- Always up-to-date documentation
- Remote service requires internet

---

### 5. Playwright

**Image**: `mcp/playwright@sha256:e4b2d56...`  
**Type**: Official Playwright MCP Server  
**Repository**: https://github.com/microsoft/playwright-mcp

#### Purpose
Browser automation for end-to-end testing, web scraping, and visual testing using Playwright framework.

#### Key Tools
**Browser Control**:
- `browser_navigate` / `browser_navigate_back` - Navigation
- `browser_click` / `browser_type` / `browser_fill_form` - Interaction
- `browser_snapshot` / `browser_take_screenshot` - Capture state
- `browser_evaluate` - Execute JavaScript
- `browser_wait_for` - Wait for conditions

**Advanced**:
- `browser_tabs` - Tab management
- `browser_console_messages` - Console log access
- `browser_network_requests` - Network inspection
- `browser_handle_dialog` - Alert/confirm handling
- `browser_install` - Install browser binaries

#### Supported Browsers
- Chromium (Chrome/Edge)
- Firefox
- WebKit (Safari)

#### Configuration
- **Long-lived**: `true` - Container stays running
- Downloads ~100-300MB per browser type

#### Use Cases
- E2E test automation
- Visual regression testing
- Web scraping
- Form interaction testing
- Multi-browser testing
- Screenshot-based testing

#### Notes
- Creates new browser instances (no logged-in state)
- Headless mode by default
- Resource intensive (memory/CPU per instance)
- Better for automated testing vs manual

---

### 6. Docker

**Image**: `docker:cli@sha256:625d943...`  
**Type**: POCI (Packaged OCI)  
**Repository**: Official Docker CLI

#### Purpose
Access to Docker CLI for container and image management.

#### Key Tools
- `docker` - Execute any Docker CLI command

#### Container Configuration
- **Volume**: `/var/run/docker.sock:/var/run/docker.sock` - Docker socket access
- **Command**: Takes args directly (e.g., `["ps", "-a"]`)

#### Use Cases
- Container lifecycle management
- Image builds and pulls
- Network management
- Volume operations
- Debugging containerized apps

#### Security Warning
- **CRITICAL RISK**: Full Docker socket access
- Can manage all containers on system
- Can mount host filesystem
- Recommend limiting to infrastructure agent only

#### Notes
- Runs Docker commands inside container
- Has same permissions as Docker daemon
- Use with extreme caution
- Consider Docker socket permissions

---

### 7. Obsidian

**Image**: `mcp/obsidian@sha256:0eba4c0...`  
**Type**: Community MCP Server  
**Repository**: https://github.com/MarkusPfundstein/mcp-obsidian

#### Purpose
Access Obsidian vault notes for documentation, architecture decisions, and knowledge management via the Obsidian REST API plugin.

#### Key Tools
**File Operations**:
- `obsidian_get_file_contents` - Read notes
- `obsidian_batch_get_file_contents` - Read multiple notes
- `obsidian_append_content` - Add to notes
- `obsidian_patch_content` - Update sections
- `obsidian_delete_file` - Remove files

**Navigation**:
- `obsidian_list_files_in_vault` / `obsidian_list_files_in_dir` - Browse vault
- `obsidian_simple_search` / `obsidian_complex_search` - Find notes

**Periodic Notes**:
- `obsidian_get_periodic_note` - Get daily/weekly/monthly notes
- `obsidian_get_recent_periodic_notes` - Recent periodic notes
- `obsidian_get_recent_changes` - Recently modified files

#### Authentication
**Required**: Obsidian REST API plugin + API key

**Setup via Docker Secret**:
```bash
echo "your_api_key" | docker secret create obsidian.api_key -
```

#### Environment Variables
- `OBSIDIAN_HOST=host.docker.internal` - Obsidian instance address

#### Use Cases
- Access Architecture Decision Records (ADRs)
- Read project documentation
- Reference meeting notes
- Query technical notes
- Project-specific knowledge retrieval

#### Prerequisites
1. Install [Obsidian REST API plugin](https://github.com/coddingtonbear/obsidian-local-rest-api)
2. Enable plugin in Obsidian
3. Get API key from plugin settings
4. Configure Docker secret

#### Notes
- Requires Obsidian running with REST API plugin
- May expose personal notes - use dedicated work vault
- Can access all notes in vault
- Excellent for structured documentation

---

### 8. Sequential Thinking

**Image**: `mcp/sequentialthinking@sha256:cd3174b...`  
**Type**: Official MCP Server  
**Repository**: https://github.com/modelcontextprotocol/servers

#### Purpose
Meta-cognitive tool for structured, step-by-step problem-solving through dynamic and reflective thinking processes.

#### Key Tools
- `sequentialthinking` - Main tool for progressive reasoning
  - Break down complex problems into sequential thoughts
  - Revise and refine thoughts as understanding deepens
  - Branch into alternative reasoning paths
  - Track progress through stages
  - Generate reasoning summaries

#### Thinking Framework
1. **Problem Definition** - Clarify the core problem
2. **Research** - Gather information and options
3. **Analysis** - Evaluate pros/cons
4. **Synthesis** - Combine insights
5. **Conclusion** - Make recommendation with rationale

#### Use Cases
- Complex architectural decisions
- Technology stack evaluations
- System-wide refactoring strategies
- Database schema migration planning
- Cross-cutting concern decisions
- Trade-off analysis

#### Not Recommended For
- Simple implementation tasks
- Day-to-day coding decisions
- Routine bug fixes

#### Notes
- Token overhead per thought step
- Best for complex decisions requiring systematic evaluation
- Complements (doesn't replace) agent instructions
- Works well with Memory MCP for storing conclusions

---

### 9. AWS Core MCP Server

**Image**: `mcp/aws-core-mcp-server@sha256:efa21b3...`  
**Type**: Official AWS Labs MCP Server  
**Repository**: https://github.com/awslabs/mcp

#### Purpose
Starting point for AWS MCP servers. Provides AWS expert guidance and prompt understanding.

#### Key Tools
- `prompt_understanding` - Translate user queries into AWS expert advice

#### Use Cases
- AWS architecture guidance
- Best practices recommendations
- Service selection advice
- Initial AWS consulting

#### Notes
- Foundational AWS MCP server
- Focuses on guidance rather than operations
- Complements AWS Documentation server
- No AWS credentials required

---

### 10. AWS Documentation

**Image**: `mcp/aws-documentation@sha256:10fb93a...`  
**Type**: Official AWS Labs MCP Server  
**Repository**: https://github.com/awslabs/mcp

#### Purpose
Access AWS documentation with search, content retrieval, and recommendations.

#### Key Tools
- `search_documentation` - Search AWS docs by phrase
- `read_documentation` - Fetch and convert AWS doc pages to markdown
- `recommend` - Get related documentation recommendations

#### Search Tips
- Use specific technical terms
- Include service names (e.g., "S3 bucket versioning")
- Use quotes for exact phrases
- Include abbreviations and alternatives

#### Recommendation Types
1. **Highly Rated** - Popular pages within service
2. **New** - Recently added pages (find new features)
3. **Similar** - Pages on similar topics
4. **Journey** - Pages commonly viewed next

#### Use Cases
- Quick AWS API lookups
- Find service documentation
- Discover new AWS features
- Migration guides
- Best practices references

#### Notes
- No AWS credentials required
- Remote service (requires internet)
- Returns markdown-formatted content
- Supports chunked reading for long docs

---

### 11. Next.js DevTools MCP

**Image**: `mcp/next-devtools-mcp@sha256:3064e34...`  
**Type**: Community MCP Server  
**Repository**: https://github.com/kgprs/next-devtools-mcp

#### Purpose
Next.js development tools and utilities for AI coding assistants. Includes Next.js 16 upgrade helpers and Cache Components support.

#### Key Tools
- `nextjs_runtime` - Interact with Next.js dev server MCP endpoint
- `nextjs_docs` - Search Next.js official documentation
- `upgrade_nextjs_16` - Guide through Next.js 16 upgrade
- `enable_cache_components` - Enable and verify Cache Components
- `browser_eval` - Browser automation (Playwright-based)

#### Runtime Tool Features
**Actions**:
- `discover_servers` - Find running Next.js dev servers
- `list_tools` - Show available MCP tools from Next.js runtime
- `call_tool` - Invoke Next.js runtime tools

**When to Use**:
- Before implementing changes (check current state)
- Diagnostic questions ("What's happening?")
- Runtime investigation ("What routes are available?")
- Error analysis and debugging

#### Documentation Search
**Categories**:
- All (default)
- Getting Started
- Guides
- API Reference
- Architecture
- Community

#### Upgrade Tool
**Covers**:
- Next.js version upgrade to 16
- Async API changes (params, searchParams, cookies)
- Config migration
- React 19 compatibility
- Runs official codemod first, then manual fixes

#### Cache Components Tool
**Handles**:
- Configuration updates
- Dev server startup with MCP
- Error detection via browser automation
- Automated fixing (Suspense, "use cache", cacheLife)
- Verification with zero errors

#### Requirements
- Next.js 16+ for runtime features
- Clean git state for upgrade tool
- Browser automation for Cache Components

#### Use Cases
- Next.js 16 migration
- Cache Components setup
- Runtime diagnostics
- Documentation lookups
- Dev server integration

#### Notes
- Runtime features require Next.js dev server running
- MCP endpoint available at `/_next/mcp`
- Browser automation included (no separate Playwright needed)
- Comprehensive Next.js 16 knowledge base

---

## Security Considerations

### Risk Levels

**🔴 High Risk** (Critical Attention Required):
- **docker** - Full Docker socket access, can manage all containers

**🟡 Medium Risk** (Configure Carefully):
- **github-official** - Can create/delete branches and files based on token scopes

**🟢 Low Risk** (Safe with Standard Practices):
- **code-index**, **memory**, **obsidian**, **context7**, **aws-documentation**, **playwright**, **sequentialthinking**, **aws-core-mcp-server**, **next-devtools-mcp** - Read-only or isolated operations

### Best Practices

#### Secrets Management
```bash
# Use Docker secrets for API keys
echo "your_secret" | docker secret create service.api_key -

# List configured secrets
docker secret ls

# Never commit secrets to git
# Use environment variable references in configs
```

#### Access Control
- **Principle of Least Privilege**: Use minimal required scopes for tokens
- **Token Rotation**: Rotate API keys quarterly
- **Fine-Grained Tokens**: Use GitHub fine-grained tokens when possible
- **Read-Only Policies**: Use read-only IAM for AWS when possible

#### Container Security
- All servers run in isolated containers
- Network access controlled via `allowHosts` in catalog
- Volume mounts limited to necessary paths only
- Resource limits enforced by Docker

#### Monitoring
```bash
# Check running MCP containers
docker ps | grep mcp

# View server logs
docker logs <container-id>

# Monitor resource usage
docker stats
```

---

## Quick Reference

### Docker MCP CLI Commands (For Agents)

**Server Management:**
```bash
# List all configured servers
docker mcp server list

# Enable/disable servers
docker mcp server enable <server-name>
docker mcp server disable <server-name>

# Show server details
docker mcp server show <server-name>
```

**Tool Discovery:**
```bash
# List all available tools
docker mcp tool ls

# List tools from specific server
docker mcp tool ls <server-name>

# Show tool details
docker mcp tool show <tool-name>
```

**Gateway Management:**
```bash
# Run gateway (OpenCode does this automatically)
docker mcp gateway run --catalog mcp-servers

# Check gateway status
docker ps | grep mcp-gateway

# View gateway logs
docker logs mcp-gateway
```

**Secrets Management:**
```bash
# List configured secrets
docker secret ls

# Create new secret
echo "your_secret" | docker secret create service.api_key -

# Delete secret
docker secret rm service.api_key
```

**Container Monitoring:**
```bash
# View running MCP containers
docker ps | grep mcp

# View server logs
docker logs <container-id>

# Monitor resource usage
docker stats $(docker ps -q --filter "label=com.docker.mcp.server")
```

### Server Images

```bash
# Local build
local/code-index-mcp:latest

# Docker Hub (official MCP)
mcp/memory@sha256:db0c2db...
mcp/sequentialthinking@sha256:cd3174b...
mcp/context7@sha256:1174e6a...
mcp/obsidian@sha256:0eba4c0...
mcp/playwright@sha256:e4b2d56...
mcp/aws-core-mcp-server@sha256:efa21b3...
mcp/aws-documentation@sha256:10fb93a...
mcp/next-devtools-mcp@sha256:3064e34...

# Docker Hub (official GitHub)
ghcr.io/github/github-mcp-server@sha256:2f9c6e9...

# Docker CLI (POCI)
docker:cli@sha256:625d943...
```

### Required Secrets

```bash
# GitHub (required for github-official)
docker secret create github.personal_access_token -

# Obsidian (optional)
docker secret create obsidian.api_key -

# Context7 (optional)
docker secret create context7.api_key -
```

### Environment Variables

```bash
# Code Index
CODEBASE_PATH=/workspace

# Obsidian
OBSIDIAN_HOST=host.docker.internal

# Context7
MCP_TRANSPORT=streaming
```

### Testing Individual Servers

```bash
# Test memory
docker run --rm -i mcp/memory

# Test code-index
docker run --rm -i -e CODEBASE_PATH=/workspace local/code-index-mcp

# Test playwright (long-lived)
docker run --rm -i mcp/playwright

# Test github (needs secret)
docker run --rm -i \
  --secret github.personal_access_token \
  ghcr.io/github/github-mcp-server
```

### Catalog Management Commands

```bash
# Create catalog
docker mcp catalog create mcp-servers

# Import server definitions
docker mcp catalog import ./mcp/docker/servers-catalog.yaml

# Show catalog contents
docker mcp catalog show mcp-servers

# Export catalog
docker mcp catalog export mcp-servers > servers-backup.yaml
```

### Feature Flags

```bash
# Enable dynamic tool loading (recommended)
docker mcp feature enable dynamic-tools

# Check which features are enabled
docker mcp feature ls

# Disable dynamic tools
docker mcp feature disable dynamic-tools
```

### Practical Tool Invocation Examples

**Using MCP tools from agents:**

```typescript
// GitHub: Create PR
MCP_DOCKER_mcp-exec({
  name: "create_pull_request",
  arguments: {
    owner: "myuser",
    repo: "myrepo",
    title: "Fix: bug in authentication",
    head: "fix/auth-bug",
    base: "main",
    body: "Fixed authentication bug by..."
  }
})

// Memory: Store pattern
MCP_DOCKER_mcp-exec({
  name: "create_entities",
  arguments: {
    entities: [{
      name: "api_rate_limiting_pattern",
      entityType: "code_pattern",
      observations: [
        "Use @Throttle(10, 60) decorator",
        "10 requests per 60 seconds",
        "Implemented in all login endpoints"
      ]
    }]
  }
})

// Code Index: Search code
MCP_DOCKER_mcp-exec({
  name: "search_code_advanced",
  arguments: {
    query: "function.*login",
    searchType: "regex",
    filePattern: "*.ts"
  }
})

// Obsidian: Read ADR
MCP_DOCKER_mcp-exec({
  name: "obsidian_get_file_contents",
  arguments: {
    path: "ADRs/001-authentication-strategy.md"
  }
})

// Playwright: E2E test
MCP_DOCKER_mcp-exec({
  name: "browser_navigate",
  arguments: {
    url: "http://localhost:3000/login"
  }
})
```

---

## Additional Resources

- [Model Context Protocol Specification](https://modelcontextprotocol.io/)
- [Docker MCP Gateway Documentation](https://docs.docker.com/ai/mcp-catalog-and-toolkit/mcp-gateway/)
- [OpenCode Documentation](https://opencode.ai/docs/)
- [MCP Servers Repository](https://github.com/modelcontextprotocol/servers)
- [AWS MCP Servers](https://github.com/awslabs/mcp)
- [GitHub MCP Server](https://github.com/github/github-mcp-server)
- [Playwright MCP](https://github.com/microsoft/playwright-mcp)
- [Code Index MCP](https://github.com/johnhuang316/code-index-mcp)
- [Next.js DevTools MCP](https://github.com/kgprs/next-devtools-mcp)

---

**Document Status**: Reference documentation for production catalog  
**Last Verified**: November 12, 2025
