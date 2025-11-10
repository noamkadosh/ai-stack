# MCP Servers Documentation

Comprehensive guide to all Model Context Protocol (MCP) servers configured for the OpenCode multi-agent system.

**Last Updated**: November 7, 2025  
**Total Servers**: 13 (6 installed + 7 recommended)

---

## Table of Contents

- [Overview](#overview)
- [Server Status Summary](#server-status-summary)
- [Universal Servers](#universal-servers)
- [Tier 1 Servers (Build & Plan)](#tier-1-servers-build--plan)
- [Tier 2 Servers (Domain Specialists)](#tier-2-servers-domain-specialists)
- [Agent-to-Server Mapping](#agent-to-server-mapping)
- [Security Considerations](#security-considerations)
- [Installation Guide](#installation-guide)
- [Quick Reference Tables](#quick-reference-tables)

---

## Overview

This document describes all MCP servers integrated with our OpenCode multi-agent architecture. Servers are categorized by:
- **Universal**: Available to all agents at all times
- **Tier 1**: Primary tools for build and plan agents
- **Tier 2**: Domain-specific tools loaded on-demand

### Architecture Context

- **OpenCode**: Terminal-based AI coding agent platform
- **Docker MCP Gateway**: Orchestrates multiple MCP servers through unified interface
- **Multi-Gateway Setup**: Separate gateway instances for different server groups
- **Agent System**: 10 specialized agents (architect, frontend, backend, test-expert, infrastructure, database, documentation, code-review, debugger, security)

---

## Server Status Summary

| Server | Status | Priority | Security Risk | Cost |
|--------|--------|----------|---------------|------|
| Memory | ⚠️ Recommended | High | Low | Free |
| GitHub | ✅ Installed | High | Medium | Free* |
| Storybook | ⚠️ Recommended | Medium | Low | Free |
| Code Index | ⚠️ Recommended | High | Low | Free |
| Playwright | ✅ Installed | Medium | Low | Free |
| Browser MCP | ⚠️ Recommended | Low | Medium | Free |
| Docker | ✅ Installed | Medium | **High** | Free |
| AWS | ✅ Installed | Medium | **Critical** | Paid |
| Desktop Commander | ⚠️ Recommended | Medium | **Critical** | Free |
| Obsidian | ✅ Installed | Medium | Low | Free |
| Context7 | ✅ Installed | Medium | Low | Paid |
| Ref Tools | ⚠️ Recommended | Medium | Low | Paid |
| Sequential Thinking | ⚠️ Recommended | Low | Low | Free |

*Free but requires GitHub account and API token

---

## Universal Servers

### 1. Memory MCP Server

**Status**: ⚠️ Recommended to Add  
**Package**: `@modelcontextprotocol/server-memory`  
**Repository**: https://github.com/modelcontextprotocol/servers/tree/main/src/memory

#### Purpose
Knowledge graph-based persistent memory system for maintaining context across conversations and sessions. Enables all agents to share knowledge about projects, patterns, and decisions.

#### Resources/Capabilities
- **create_entities**: Create nodes in knowledge graph (people, projects, concepts, patterns)
- **create_relations**: Define directed relationships between entities
- **add_observations**: Store facts and notes about entities
- **delete_entities**: Remove entities from graph
- **delete_observations**: Remove specific facts
- **delete_relations**: Remove relationships
- **read_graph**: Retrieve entire knowledge graph
- **search_nodes**: Search by entity names, types, or observations
- **open_nodes**: Retrieve specific entities by name

#### Storage
- Format: JSONL (JSON Lines)
- Default location: `memory.jsonl` in server directory
- Configurable via `MEMORY_FILE_PATH` environment variable

#### Used By
**Primary**: All agents (shared knowledge base)

**Use Cases**:
- Store architectural decisions across sessions
- Remember coding conventions and patterns
- Track project-specific context
- Maintain user preferences
- Record learned solutions to common problems

#### Configuration
```json
{
  "memory": {
    "type": "local",
    "command": ["npx", "-y", "@modelcontextprotocol/server-memory"],
    "env": {
      "MEMORY_FILE_PATH": "/workspace/.opencode-memory/graph.jsonl"
    },
    "enabled": true
  }
}
```

#### Installation
```bash
# Test standalone
npx -y @modelcontextprotocol/server-memory

# Docker
docker run -i -v claude-memory:/app/dist --rm mcp/memory
```

#### Disclaimers
- ⚠️ Accumulates data over time - recommend periodic cleanup
- ⚠️ No built-in encryption - don't store sensitive credentials
- ⚠️ JSONL format can grow large with heavy use
- ⚠️ Consider per-project vs global strategy (see configuration options)

#### Best Practices
- Use per-project memory files for project-specific context
- Use global memory file for user preferences and general patterns
- Regularly review and prune outdated entities
- Document important entities with clear observation text

---

## Tier 1 Servers (Build & Plan)

### 2. GitHub MCP Server

**Status**: ✅ Already Installed  
**Package**: `@modelcontextprotocol/server-github`  
**Repository**: https://github.com/modelcontextprotocol/servers/tree/main/src/github

#### Purpose
Complete GitHub API integration for repository management, issue tracking, PR workflows, and code review processes.

#### Resources/Capabilities
- **Issues**: Create, update, close, search, comment
- **Pull Requests**: Create, update, merge, request reviews
- **Repositories**: Fork, create, list, search
- **Files**: Read, create, update, delete repository files
- **Branches**: Create, list, compare
- **Comments**: Add PR/issue comments, reviews
- **Labels & Milestones**: Manage project organization
- **Search**: Code search across repositories

#### Used By
**Primary**: build, plan, architect, code-review, documentation  
**Secondary**: All agents (for tracking and collaboration)

**Use Cases**:
- Automated PR creation and updates
- Issue triage and management
- Code review submission
- Release planning and tracking
- Documentation updates via commits

#### Configuration
```json
{
  "github": {
    "type": "local",
    "command": ["npx", "-y", "@modelcontextprotocol/server-github"],
    "env": {
      "GITHUB_TOKEN": "${GITHUB_TOKEN}"
    },
    "enabled": true
  }
}
```

#### Setup
```bash
# Create GitHub Personal Access Token
# Settings → Developer settings → Personal access tokens → Tokens (classic)
# Required scopes: repo, read:org, read:user, workflow

export GITHUB_TOKEN="ghp_your_token_here"
```

#### Installation
```bash
# Test standalone
npx -y @modelcontextprotocol/server-github
```

#### Disclaimers
- ⚠️ Requires GitHub token with appropriate scopes
- ⚠️ Token access = repository access - use minimal required scopes
- ⚠️ Rate limits: 5000 requests/hour (authenticated), 60/hour (unauthenticated)
- ⚠️ Secondary rate limits for file creation/updates (varies)
- ⚠️ Can create/delete branches and files - use with care

#### Best Practices
- Use fine-grained tokens with repository-specific access
- Set token expiration dates for security
- Never commit tokens to repositories
- Review token scopes regularly
- Monitor rate limit headers in responses

---

## Tier 2 Servers (Domain Specialists)

### 3. Storybook MCP Server

**Status**: ⚠️ Recommended to Add  
**Package**: `@storybook/mcp`  
**Repository**: https://github.com/storybookjs/mcp

#### Purpose
Provides AI agents access to Storybook component documentation, props, stories, and metadata for intelligent component-aware development.

#### Resources/Capabilities
- **Component Metadata**: Access props, args, types
- **Story Definitions**: Read story CSF files
- **Component Hierarchy**: Navigate component tree
- **Args Tables**: Access component API documentation
- **Controls**: Read control configurations

#### Used By
**Primary**: frontend  
**Secondary**: test-expert, documentation

**Use Cases**:
- Generate component implementations matching existing patterns
- Create stories for new components based on props
- Update component documentation
- Generate component tests based on story configurations
- Visual regression test planning

#### Configuration
```json
{
  "storybook": {
    "type": "remote",
    "url": "http://localhost:6006/mcp",
    "enabled": false
  }
}
```

#### Setup
```bash
# Install Storybook addon
npm install --save-dev @storybook/addon-mcp

# Add to .storybook/main.js
module.exports = {
  addons: ['@storybook/addon-mcp']
}

# Start Storybook
npm run storybook
```

#### Installation
```bash
# Package installation
pnpm add @storybook/mcp
```

#### Disclaimers
- ⚠️ Requires Storybook dev server running on http://localhost:6006
- ⚠️ Only available when Storybook is active
- ⚠️ Experimental addon - API may change
- ⚠️ Only works with Storybook 7.0+
- ✅ Read-only access - safe to use

#### Best Practices
- Keep Storybook running during frontend development sessions
- Use consistent story naming conventions
- Document component props thoroughly
- Enable when working on component-heavy features

---

### 4. Code Index MCP Server

**Status**: ⚠️ Recommended to Add  
**Package**: `code-index-mcp`  
**Repository**: https://github.com/johnhuang316/code-index-mcp

#### Purpose
Intelligent code indexing and semantic search across codebase using Tree-sitter AST parsing and symbol-level navigation.

#### Resources/Capabilities
- **set_project_path**: Initialize indexing for project directory
- **refresh_index**: Rebuild shallow file index after changes
- **build_deep_index**: Generate full symbol index for deep analysis
- **get_settings_info**: View current project configuration
- **search_code_advanced**: Regex, fuzzy matching, file filtering (paginated)
- **find_files**: Locate files using glob patterns
- **get_file_summary**: Analyze file structure, functions, imports, complexity
- **get_file_watcher_status**: Check file watcher configuration
- **configure_file_watcher**: Enable/disable auto-refresh
- **create_temp_directory**: Set up index storage
- **check_temp_directory**: Verify index location
- **clear_settings**: Reset cached data
- **refresh_search_tools**: Re-detect search tools (ugrep, ripgrep, ag, grep)

#### Supported Languages

**Tree-sitter AST Parsing** (7 languages):
- Python, JavaScript, TypeScript, Java, Go, Objective-C, Zig

**Fallback Strategy** (50+ languages):
- C/C++, Rust, Ruby, PHP, C#, Kotlin, Scala, Swift, Shell, HTML, CSS, SQL, and more

#### Used By
**Primary**: architect, code-review  
**Secondary**: debugger, frontend, backend, test-expert

**Use Cases**:
- Find all usages of a function/class across codebase
- Analyze code structure and dependencies
- Locate symbols for refactoring
- Generate architecture documentation
- Code review preparation
- Debugging complex call chains

#### Configuration
```json
{
  "code-index": {
    "type": "local",
    "command": ["uvx", "code-index-mcp", "--project-path", "${workspaceFolder}"],
    "enabled": false
  }
}
```

#### Setup
```bash
# Install prerequisites
# Python 3.10+ and uv required
curl -LsSf https://astral.sh/uv/install.sh | sh

# Pre-index project (recommended for large codebases)
cd /path/to/project
uvx code-index-mcp --project-path . build_deep_index
```

#### Installation
```bash
# Quick install via uvx
uvx code-index-mcp

# Or install globally
uv tool install code-index-mcp
```

#### Disclaimers
- ⚠️ Large codebases require pre-indexing (1-5 minutes initially)
- ⚠️ Deep indexing needed for symbol-level analysis
- ⚠️ Memory usage scales with codebase size
- ⚠️ File watcher requires watchdog: `pip install watchdog --break-system-packages`
- ✅ Read-only analysis - safe for all agents
- ✅ Persistent caching speeds up subsequent access

#### Best Practices
- Pre-index large projects before first use
- Run deep index when symbol metadata is needed
- Use file watcher for active development
- Configure search tool detection for optimal performance
- Results paginated at 10 per page - use `max_results` and `start_index` parameters

---

### 5. Playwright MCP Server

**Status**: ✅ Already Installed  
**Package**: `@executeautomation/playwright-mcp-server`  
**Repository**: https://github.com/executeautomation/playwright-mcp-server

#### Purpose
Browser automation for end-to-end testing, web scraping, and visual testing using Playwright framework.

#### Resources/Capabilities
- **Browser Control**: Launch Chromium, Firefox, WebKit
- **Navigation**: Go to URLs, click, type, scroll
- **Screenshots**: Capture full page or element screenshots
- **Console**: Execute JavaScript in browser context
- **Network**: Intercept and mock network requests
- **Authentication**: Handle login flows and session management
- **Test Generation**: Record interactions as test code
- **Assertions**: Verify element states and content

#### Supported Browsers
- Chromium (Chrome/Edge)
- Firefox
- WebKit (Safari)

#### Used By
**Primary**: test-expert  
**Secondary**: frontend, debugger

**Use Cases**:
- E2E test automation
- Visual regression testing
- Web scraping
- Form interaction testing
- Multi-browser testing
- Screenshot-based testing

#### Configuration
```json
{
  "playwright": {
    "type": "local",
    "command": ["npx", "-y", "@executeautomation/playwright-mcp-server"],
    "enabled": false
  }
}
```

#### Setup
```bash
# Install Playwright browsers
npx playwright install

# Install specific browser
npx playwright install chromium
```

#### Installation
```bash
# Test standalone
npx -y @executeautomation/playwright-mcp-server
```

#### Disclaimers
- ⚠️ Creates new browser instances (no logged-in state by default)
- ⚠️ Can be detected by anti-bot systems
- ⚠️ Resource intensive (memory/CPU for each browser instance)
- ⚠️ Headless mode default - use headed mode for debugging
- ⚠️ Browser downloads ~100-300MB per browser type
- ✅ Better for automated testing vs manual testing

#### Best Practices
- Use headless mode for CI/CD pipelines
- Use headed mode for test development/debugging
- Reuse browser contexts when possible
- Set reasonable timeouts for flaky tests
- Close browsers properly to free resources
- Use Browser MCP for logged-in session testing

---

### 6. Browser MCP Server

**Status**: ⚠️ Recommended to Add  
**Package**: `@browsermcp/server`  
**Repository**: https://github.com/browsermcp/mcp  
**Website**: https://browsermcp.io

#### Purpose
Automate your actual Chrome browser (with logged-in sessions) via Chrome extension for auth-heavy testing and debugging scenarios.

#### Resources/Capabilities
- **Real Browser Control**: Automate your existing Chrome instance
- **Session Persistence**: Use existing cookies and logged-in state
- **Bot Detection Bypass**: Real browser fingerprint avoids anti-bot systems
- **Element Interaction**: Click, type, navigate
- **Screenshots**: Capture current state
- **Local Execution**: Runs on your machine (no network latency)

#### Used By
**Primary**: test-expert  
**Secondary**: debugger

**Use Cases**:
- Testing with complex authentication (OAuth, 2FA, SSO)
- Debugging production issues with real logged-in state
- Quick manual testing scenarios
- Social media automation (with proper permissions)
- Testing in authenticated contexts

#### Configuration
```json
{
  "browser-mcp": {
    "type": "local",
    "command": ["npx", "-y", "@browsermcp/server"],
    "enabled": false
  }
}
```

#### Setup
```bash
# 1. Install Chrome extension from browsermcp.io
# 2. Pin the extension to toolbar
# 3. Extension connects to MCP server automatically

# Test connection
npx -y @browsermcp/server
```

#### Installation
```bash
# NPX (recommended)
npx -y @browsermcp/server

# Or install globally
npm install -g @browsermcp/server
```

#### Disclaimers
- ⚠️ **Chrome only** - no Firefox/Safari support
- ⚠️ Requires Chrome extension installation (manual step)
- ⚠️ Uses your actual browser - can interfere with your work
- ⚠️ **Security**: Gives AI control of your authenticated browser
- ⚠️ Be careful with automated actions in logged-in contexts
- ⚠️ Not suitable for CI/CD pipelines
- ✅ Complementary to Playwright (use for auth-heavy scenarios)
- ✅ Faster for quick manual tests

#### Best Practices
- Use dedicated Chrome profile for automation
- Enable only when needed for auth-heavy testing
- Don't use on production accounts (use test accounts)
- Close sensitive tabs before enabling
- Disable when not actively testing
- Prefer Playwright for non-authenticated testing

---

### 7. Docker MCP Server

**Status**: ✅ Already Installed  
**Package**: `@modelcontextprotocol/server-docker`  
**Repository**: https://github.com/modelcontextprotocol/servers/tree/main/src/docker

#### Purpose
Docker container and image management for containerized application development and debugging.

#### Resources/Capabilities
- **Containers**: List, start, stop, restart, remove, inspect
- **Images**: List, pull, build, remove, inspect
- **Logs**: View container logs (real-time or historical)
- **Exec**: Execute commands inside running containers
- **Networks**: List, create, remove networks
- **Volumes**: List, create, remove volumes
- **Compose**: Basic docker-compose operations

#### Used By
**Primary**: infrastructure  
**Secondary**: debugger, backend

**Use Cases**:
- Container lifecycle management
- Debugging containerized applications
- Viewing container logs
- Building Docker images
- Network troubleshooting
- Volume management

#### Configuration
```json
{
  "docker": {
    "type": "local",
    "command": ["npx", "-y", "@modelcontextprotocol/server-docker"],
    "enabled": false
  }
}
```

#### Setup
```bash
# Requires Docker installed and running
# Ensure Docker socket is accessible
docker ps  # Test Docker access
```

#### Installation
```bash
# Test standalone
npx -y @modelcontextprotocol/server-docker
```

#### Disclaimers
- ⚠️ **Security Critical**: Can manage all Docker resources on system
- ⚠️ Can start/stop/delete production containers
- ⚠️ Can create containers with host volume mounts
- ⚠️ Recommend limiting to infrastructure agent only
- ⚠️ Consider Docker socket permissions to limit access
- ⚠️ Can consume significant system resources via container creation
- ⚠️ Image pulls can use significant bandwidth

#### Best Practices
- Limit to infrastructure agent only
- Use Docker labels to identify managed containers
- Never expose Docker socket to untrusted networks
- Use read-only operations when possible
- Set resource limits on created containers
- Regular cleanup of unused images/containers
- Monitor Docker disk usage

---

### 8. AWS MCP Server

**Status**: ✅ Already Installed  
**Package**: `@modelcontextprotocol/server-aws`  
**Repository**: https://github.com/modelcontextprotocol/servers/tree/main/src/aws

#### Purpose
AWS cloud resource inspection and management for infrastructure operations and debugging.

#### Resources/Capabilities
- **EC2**: List, start, stop, describe instances
- **S3**: List buckets, upload/download objects
- **Lambda**: List, invoke, view logs
- **CloudWatch**: Query logs, view metrics
- **IAM**: List roles, users, policies (read-only recommended)
- **RDS**: Describe databases, view status
- **ECS/EKS**: Container service management

#### Used By
**Primary**: infrastructure, architect  
**Secondary**: debugger

**Use Cases**:
- Infrastructure deployment and management
- Debugging cloud issues
- Log analysis via CloudWatch
- Resource cost monitoring
- Security group configuration
- Lambda function management

#### Configuration
```json
{
  "aws": {
    "type": "local",
    "command": ["npx", "-y", "@modelcontextprotocol/server-aws"],
    "env": {
      "AWS_REGION": "${AWS_REGION}",
      "AWS_ACCESS_KEY_ID": "${AWS_ACCESS_KEY_ID}",
      "AWS_SECRET_ACCESS_KEY": "${AWS_SECRET_ACCESS_KEY}"
    },
    "enabled": false
  }
}
```

#### Setup
```bash
# Option 1: Environment variables
export AWS_REGION="us-east-1"
export AWS_ACCESS_KEY_ID="AKIA..."
export AWS_SECRET_ACCESS_KEY="..."

# Option 2: AWS CLI profile
aws configure
# MCP server will use default profile

# Option 3: IAM role (EC2/ECS)
# No credentials needed when running on AWS with IAM role
```

#### Installation
```bash
# Test standalone
npx -y @modelcontextprotocol/server-aws
```

#### Disclaimers
- ⚠️ **SECURITY CRITICAL**: AWS credentials = full cloud access
- ⚠️ **COST CRITICAL**: Can create expensive resources (EC2, RDS, etc.)
- ⚠️ Use IAM roles with minimal required permissions
- ⚠️ Recommend read-only IAM policy for non-infrastructure agents
- ⚠️ API calls incur minor costs
- ⚠️ Resource creation/deletion can be costly
- ⚠️ Accidental resource creation can lead to unexpected bills
- ⚠️ Be extremely careful with delete operations

#### Best Practices
- Use separate IAM users for automation vs humans
- Create read-only IAM policy for debugging/viewing
- Use infrastructure-specific IAM user with write access
- Enable CloudTrail for audit logging
- Set up billing alerts for cost control
- Use resource tagging for cost tracking
- Regular review of active resources
- Never commit AWS credentials to repositories
- Rotate credentials regularly
- Use temporary credentials (STS) when possible

#### Recommended IAM Policies

**Read-Only Policy** (for debugger, architect agents):
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "s3:List*",
        "s3:Get*",
        "lambda:List*",
        "lambda:Get*",
        "logs:Describe*",
        "logs:Get*",
        "logs:FilterLogEvents",
        "rds:Describe*",
        "ecs:Describe*",
        "eks:Describe*"
      ],
      "Resource": "*"
    }
  ]
}
```

**Infrastructure Policy** (for infrastructure agent):
Add write permissions as needed per resource type.

---

### 9. Desktop Commander MCP Server

**Status**: ⚠️ Recommended to Add  
**Package**: `@wonderwhy-er/desktop-commander`  
**Repository**: https://github.com/wonderwhy-er/DesktopCommanderMCP

#### Purpose
System-wide terminal control, file operations, and process management beyond git repository scope.

#### Resources/Capabilities
- **Terminal**: Execute shell commands with output streaming
- **Interactive Processes**: Control SSH, databases, REPLs, dev servers
- **File Operations**: Read/write/search beyond repository directories
- **Code Execution**: Run Python, Node.js, R code in memory
- **Process Management**: List, kill system processes
- **Search**: Recursive ripgrep-based code/text search
- **Edit Blocks**: Surgical text replacements with fuzzy matching
- **Configuration**: Get/set server config (directories, commands, shell)

#### Used By
**Primary**: infrastructure  
**Secondary**: debugger

**Use Cases**:
- System-wide automation tasks
- SSH session management
- Database connection debugging
- Process debugging and cleanup
- System log analysis
- Dev server management
- Quick script execution
- Multi-repository operations

#### Configuration
```json
{
  "desktop-commander": {
    "type": "local",
    "command": [
      "npx",
      "-y",
      "@wonderwhy-er/desktop-commander@latest",
      "--no-onboarding"
    ],
    "enabled": false
  }
}
```

#### Setup
```bash
# Install and configure
npx @wonderwhy-er/desktop-commander@latest setup

# Or use automated installer (macOS)
curl -fsSL https://raw.githubusercontent.com/wonderwhy-er/DesktopCommanderMCP/refs/heads/main/install.sh | bash
```

#### Critical Configuration (MUST DO BEFORE USE)
```javascript
// In chat with agent, configure IMMEDIATELY:

// Set allowed directories (whitelist)
set_config_value({
  "key": "allowedDirectories",
  "value": ["/home/noam/projects", "/home/noam/workspace"]
})

// Block dangerous commands
set_config_value({
  "key": "blockedCommands", 
  "value": ["rm -rf /", "mkfs", "dd", "format"]
})

// Set default shell
set_config_value({
  "key": "defaultShell",
  "value": "/bin/bash"
})

// Verify configuration
get_config({})
```

#### Installation
```bash
# Option 1: NPX (recommended)
npx -y @wonderwhy-er/desktop-commander@latest

# Option 2: Global install
npm install -g @wonderwhy-er/desktop-commander@latest

# Option 3: Docker (isolated)
docker run -i --rm \
  -v /path/to/projects:/mnt/projects \
  mcp/desktop-commander:latest
```

#### Docker Installation (Recommended for Security)
```bash
# Automated installer
bash <(curl -fsSL https://raw.githubusercontent.com/wonderwhy-er/DesktopCommanderMCP/refs/heads/main/install-docker.sh)

# Manual docker-compose
docker-compose up -d desktop-commander
```

#### Disclaimers
- ⚠️ **HIGHEST SECURITY RISK**: Full system access capabilities
- ⚠️ **CRITICAL**: Can execute ANY command including destructive ones (`rm -rf`)
- ⚠️ **CRITICAL**: Terminal commands bypass `allowedDirectories` restrictions
- ⚠️ `allowedDirectories` only restricts file read/write, NOT shell commands
- ⚠️ Configure `blockedCommands` immediately to prevent dangerous operations
- ⚠️ Can access files outside allowed directories via terminal
- ⚠️ Audit logging enabled but doesn't prevent actions
- ⚠️ Telemetry enabled by default (can be disabled via config)
- ⚠️ Test thoroughly in isolated environment before production use
- ✅ Docker installation provides complete isolation (recommended)
- ✅ Persistent work environment in Docker mode

#### Security Best Practices
1. **Always configure before first use** - Set allowed directories and blocked commands
2. **Use Docker installation** for complete isolation
3. **Limit to infrastructure agent only**
4. **Enable audit logging** for accountability
5. **Regular log review** of executed commands
6. **Test in VM or container** before using on main system
7. **Never enable for all agents**
8. **Use read-only mode** when analysis-only needed
9. **Set file operation limits** (fileReadLineLimit, fileWriteLineLimit)
10. **Disable telemetry** if privacy concerned

#### Audit Logs
Located at:
- macOS/Linux: `~/.claude-server-commander/claude_tool_call.log`
- Windows: `%USERPROFILE%\.claude-server-commander\claude_tool_call.log`
- Automatic rotation at 10MB

#### Disabling Telemetry
```javascript
// In chat with agent:
set_config_value({"key": "telemetryEnabled", "value": false})
```

---

### 10. Obsidian MCP Server

**Status**: ✅ Already Installed  
**Package**: `mcp-obsidian`  
**Repository**: Community package

#### Purpose
Access to Obsidian vault notes for documentation, architecture decisions, and project knowledge management.

#### Resources/Capabilities
- **Note Reading**: Read individual note contents
- **Vault Search**: Search across all notes
- **Tag Queries**: Find notes by tags
- **Folder Listing**: List notes in specific folders
- **Link Graph**: Access note relationships
- **Metadata**: Read frontmatter and properties

#### Used By
**Primary**: documentation, architect  
**Secondary**: All agents (for context)

**Use Cases**:
- Access Architecture Decision Records (ADRs)
- Read project documentation
- Reference meeting notes
- Access design documents
- Query technical notes
- Project-specific knowledge retrieval

#### Configuration
```json
{
  "obsidian": {
    "type": "local",
    "command": [
      "npx",
      "-y",
      "mcp-obsidian",
      "--vault-path",
      "${OBSIDIAN_VAULT_PATH}"
    ],
    "enabled": false
  }
}
```

#### Setup
```bash
# Set vault path
export OBSIDIAN_VAULT_PATH="~/Documents/Obsidian/Work"

# Or use absolute path in config
# Linux/Mac: /home/user/Documents/Obsidian/Vault
# Windows: C:\Users\user\Documents\Obsidian\Vault
```

#### Installation
```bash
# Test standalone
npx -y mcp-obsidian --vault-path ~/Documents/Obsidian/Vault
```

#### Disclaimers
- ⚠️ Requires Obsidian vault path configuration
- ⚠️ May expose personal notes - use dedicated work vault
- ⚠️ No write operations by default (read-only recommended)
- ⚠️ Can access all notes in vault (consider subfolder restriction)
- ✅ Excellent for structured documentation access
- ✅ Great for ADRs and design docs

#### Best Practices
- Use separate work vault for AI access
- Keep sensitive personal notes in different vault
- Organize with consistent folder structure
- Use tags for better searchability
- Configure read-only if possible
- Document file naming conventions
- Use frontmatter for structured metadata

---

### 11. Context7 MCP Server

**Status**: ✅ Already Installed  
**Service**: context7.com (Remote HTTP)  
**Website**: https://context7.com

#### Purpose
Quick access to up-to-date library and framework documentation for rapid reference lookups.

#### Resources/Capabilities
- **Library Docs**: Access latest documentation for popular libraries
- **Framework References**: React, NextJS, NestJS, Vue, Angular, etc.
- **API Documentation**: Method signatures, parameters, examples
- **Code Examples**: Working code snippets
- **Migration Guides**: Version upgrade documentation
- **Best Practices**: Framework-specific recommendations

#### Supported Libraries/Frameworks
- Frontend: React, NextJS, Vue, Angular, Svelte, Storybook
- Backend: NestJS, Express, Fastify, Node.js
- Database: Postgres, MongoDB, Redis, Prisma
- Testing: Jest, Vitest, Playwright, Cypress
- And many more...

#### Used By
**Primary**: All agents (quick reference)  
**Secondary**: Especially useful for frontend, backend, test-expert

**Use Cases**:
- "What's the API for X in React 18?"
- Quick syntax lookups
- Check latest API changes
- Migration guide references
- Framework best practices

#### Configuration
```json
{
  "context7": {
    "type": "remote",
    "url": "https://mcp.context7.com/mcp",
    "headers": {
      "CONTEXT7_API_KEY": "${CONTEXT7_API_KEY}"
    },
    "enabled": false
  }
}
```

#### Setup
```bash
# 1. Sign up at context7.com
# 2. Get API key from dashboard
# 3. Set environment variable
export CONTEXT7_API_KEY="ctx7_your_key_here"
```

#### Installation
No local installation - remote service.

#### Disclaimers
- ⚠️ Requires API key and subscription
- ⚠️ Usage limits based on plan
- ⚠️ No token optimization - returns full documentation pages
- ⚠️ Remote service requires internet connection
- ⚠️ Response times depend on network latency
- ✅ Best for quick reference lookups
- ✅ Always up-to-date documentation
- ✅ Complementary to Ref Tools (use Context7 for quick lookups, Ref Tools for deep research)

#### Best Practices
- Use for quick "what's the syntax?" questions
- Prefer over searching web for library docs
- Use Ref Tools for deep research instead
- Monitor API usage limits
- Cache frequently accessed docs locally

---

### 12. Ref Tools MCP Server

**Status**: ⚠️ Recommended to Add  
**Service**: ref.tools (Remote HTTP)  
**Repository**: https://github.com/ref-tools/ref-tools-mcp  
**Website**: https://ref.tools

#### Purpose
Token-efficient documentation research with session-aware search and intelligent content optimization for deep research tasks.

#### Resources/Capabilities
- **ref_search_documentation**: Search public and private documentation
- **ref_read_url**: Fetch and convert URLs to markdown with smart truncation
- **Session Awareness**: Never returns repeated results in same session
- **Token Optimization**: Returns 5k most relevant tokens per page
- **Smart Dropout**: Removes less relevant sections based on search history
- **Context Tracking**: Uses search trajectory to improve results

#### Search Coverage
- Public documentation websites
- GitHub repositories and wikis
- Private documentation (with configuration)
- PDF documents
- API references

#### Used By
**Primary**: documentation, architect  
**Secondary**: code-review, frontend, backend

**Use Cases**:
- Deep technical research requiring multiple searches
- Architecture research across multiple sources
- Best practices investigation
- Comparative analysis of approaches
- Learning new technologies in depth
- Documentation authoring research

#### Configuration
```json
{
  "ref-tools": {
    "type": "http",
    "url": "https://api.ref.tools/mcp?apiKey=${REF_API_KEY}",
    "enabled": false
  }
}
```

#### Setup
```bash
# 1. Sign up at ref.tools
# 2. Get API key
# 3. Set environment variable
export REF_API_KEY="ref_your_key_here"
```

#### Installation
```bash
# For local development/testing
npm install ref-tools-mcp@latest

# Run locally
npx ref-tools-mcp@latest
```

#### Disclaimers
- ⚠️ Requires API key from ref.tools
- ⚠️ Usage costs based on API plan
- ⚠️ Remote service requires internet connection
- ⚠️ Private docs require additional configuration
- ✅ Significantly reduces token usage vs raw web scraping
- ✅ Session awareness prevents repeated results
- ✅ Smart truncation keeps context window clean
- ✅ Better for deep research than Context7

#### Best Practices
- Use for multi-step research requiring several searches
- Let session awareness work - refine searches instead of paging
- Use for documentation writing and architecture research
- Prefer over Context7 for deep dives (complement, don't replace)
- Monitor token usage savings vs raw fetch
- Configure private docs for internal documentation access

#### Example Research Flow
```
1. Search: "n8n merge node vs Code node"
   → Read merged results (5k tokens)

2. Search: "n8n Code node multiple inputs best practices"
   → New results only (no repeats from #1)
   
3. Search: "n8n Code node $input access"
   → Refined results based on trajectory

Total: ~15k tokens vs 60k+ with raw fetching
```

---

### 13. Sequential Thinking MCP Server

**Status**: ⚠️ Recommended to Add (Architect Agent Only)  
**Package**: `@modelcontextprotocol/server-sequential-thinking`  
**Repository**: https://github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking

#### Purpose
Meta-cognitive tool for structured, step-by-step problem-solving through dynamic and reflective thinking processes. Designed for complex architectural decisions requiring systematic evaluation of alternatives.

#### Resources/Capabilities
- **sequential_thinking**: Main tool for progressive reasoning
  - Break down complex problems into sequential thoughts
  - Revise and refine thoughts as understanding deepens
  - Branch into alternative reasoning paths
  - Adjust total number of thoughts dynamically
  - Track progress through thinking stages
  - Generate summaries of the reasoning process

#### Thinking Framework Stages
1. **Problem Definition**: Clarify the core problem
2. **Research**: Gather information and options
3. **Analysis**: Evaluate pros/cons of approaches
4. **Synthesis**: Combine insights into coherent understanding
5. **Conclusion**: Make final recommendation with rationale

#### Used By
**Primary**: architect (ONLY)  
**Secondary**: None

**Use Cases**:
- Complex architectural decisions (microservices vs monolith)
- Technology stack evaluations
- System-wide refactoring strategies
- Database schema migration planning
- Cross-cutting concern decisions
- Trade-off analysis for long-term consequences

**NOT recommended for**:
- Simple implementation tasks (use agent instructions instead)
- Day-to-day coding decisions
- Other agents (they have domain-specific reasoning)

#### Configuration
```json
{
  "sequential-thinking": {
    "type": "local",
    "command": ["npx", "-y", "@modelcontextprotocol/server-sequential-thinking"],
    "env": {
      "DISABLE_THOUGHT_LOGGING": "false"
    },
    "enabled": false
  }
}
```

#### Setup
```bash
# Test standalone
npx -y @modelcontextprotocol/server-sequential-thinking

# No additional configuration needed
# Optionally disable logging for production:
export DISABLE_THOUGHT_LOGGING=true
```

#### Installation
```bash
# NPX (recommended)
npx -y @modelcontextprotocol/server-sequential-thinking

# Docker
docker run --rm -i mcp/sequentialthinking
```

#### Disclaimers
- ⚠️ **Token overhead**: Each thought step consumes tokens
- ⚠️ **Architect agent only**: Not recommended for other agents
- ⚠️ **Use sparingly**: For complex decisions only, not routine tasks
- ⚠️ Logging enabled by default - review thought logs to improve prompts
- ✅ Complements (doesn't replace) agent instructions
- ✅ Best for problems requiring systematic evaluation of alternatives
- ✅ Natural fit for branching reasoning paths

#### Best Practices
- **Enable only for architect agent** - other agents use domain-specific reasoning
- **Use for complex decisions only** - not for routine implementation
- **Review thought logs** - learn from reasoning patterns to improve prompts
- **Combine with Ref Tools** - research phase benefits from documentation access
- **Store conclusions in Memory MCP** - preserve architectural decisions
- **Set reasonable thought limits** - don't let it spiral into analysis paralysis
- **Use with ADRs** - document final decisions in Obsidian

#### Example Workflow
```markdown
Architect Agent facing: "Should we migrate from REST to GraphQL?"

1. Enable Sequential Thinking
2. Agent uses tool to structure thinking:
   - Thought 1: Define problem (performance, flexibility, complexity)
   - Thought 2: Research (use Ref Tools for GraphQL best practices)
   - Thought 3: Analyze current REST implementation pain points
   - Thought 4: Evaluate GraphQL benefits vs migration cost
   - Thought 5: Consider team learning curve
   - Thought 6: Alternative: Enhance REST with better caching
   - Thought 7: Synthesis: GraphQL wins for our use case because...
   - Thought 8: Conclusion: Recommend phased migration starting with...
3. Store decision in Memory MCP
4. Create ADR in Obsidian with reasoning
```

#### When NOT to Use
- Simple "should I use X or Y library?" → Use Context7
- Implementation details → Agent instructions sufficient
- Bug fixes → Debugger agent has its own reasoning
- Code review → Code Review agent specializes in analysis
- Testing strategies → Test Expert agent handles this

#### Comparison to Agent Instructions
**Agent Instructions** provide:
- Domain-specific structure
- Action-oriented directives
- Practical checklists

**Sequential Thinking** provides:
- Meta-cognitive framework
- Explicit reasoning traces
- Alternative path exploration

Use **both together** for architect agent: Instructions for daily work, Sequential Thinking for major decisions.

---

## Agent-to-Server Mapping

### Complete Matrix

| Agent | Universal | Primary Tools | Secondary Tools |
|-------|-----------|---------------|-----------------|
| **Architect** | Memory, GitHub | Code Index, Ref Tools, Sequential Thinking | Context7, AWS, Obsidian |
| **Frontend** | Memory, GitHub | Storybook | Code Index, Playwright, Browser MCP, Context7 |
| **Backend** | Memory, GitHub | - | Code Index, Context7, Ref Tools |
| **Test Expert** | Memory, GitHub | Playwright | Browser MCP, Storybook, Code Index |
| **Infrastructure** | Memory, GitHub | Docker, AWS, Desktop Commander | Code Index |
| **Database** | Memory, GitHub | - | Code Index, Desktop Commander |
| **Documentation** | Memory, GitHub | Obsidian, Ref Tools | Context7, Code Index |
| **Code Review** | Memory, GitHub | Code Index | Context7, Ref Tools |
| **Debugger** | Memory, GitHub | Code Index | Docker, Desktop Commander, Browser MCP, AWS |
| **Security** | Memory, GitHub | Code Index | Docker, AWS |

### Detailed Agent Configurations

#### Architect Agent
**Gateway**: Git-based operations + Analysis  
**Servers**: Memory, GitHub, Code Index, Ref Tools, Sequential Thinking, Context7, AWS, Obsidian  
**Rationale**: Needs broad codebase understanding, documentation access, and structured reasoning for architectural decisions with long-term consequences.

#### Frontend Agent
**Gateway**: Component + Testing  
**Servers**: Memory, GitHub, Storybook, Code Index, Playwright, Browser MCP, Context7  
**Rationale**: Component-focused with visual testing capabilities and framework documentation access.

#### Backend Agent
**Gateway**: API Development  
**Servers**: Memory, GitHub, Code Index, Context7, Ref Tools  
**Rationale**: API development with minimal additional tooling; focuses on code quality and documentation.

#### Test Expert Agent
**Gateway**: Testing Tools  
**Servers**: Memory, GitHub, Playwright, Browser MCP, Storybook, Code Index  
**Rationale**: Multiple browser automation options for different testing scenarios (automated vs auth-heavy).

#### Infrastructure Agent
**Gateway**: System + Cloud  
**Servers**: Memory, GitHub, Docker, AWS, Desktop Commander, Code Index  
**Rationale**: Full system access for DevOps tasks.  
**⚠️ CRITICAL**: Highest security risk - Docker + AWS + Desktop Commander combination.

#### Database Agent
**Gateway**: Data Operations  
**Servers**: Memory, GitHub, Code Index, Desktop Commander  
**Rationale**: Minimal tooling for focused database work with system-level access for DB connections.

#### Documentation Agent
**Gateway**: Documentation + Research  
**Servers**: Memory, GitHub, Obsidian, Ref Tools, Context7, Code Index  
**Rationale**: Extensive research and documentation capabilities with code-to-docs generation.

#### Code Review Agent
**Gateway**: Analysis + Standards  
**Servers**: Memory, GitHub, Code Index, Context7, Ref Tools  
**Rationale**: Focuses on code quality, standards compliance, and best practices verification.

#### Debugger Agent
**Gateway**: Debugging Tools  
**Servers**: Memory, GitHub, Code Index, Docker, Desktop Commander, Browser MCP, AWS  
**Rationale**: Diverse debugging tools across all stack layers (code, containers, cloud, UI).

#### Security Agent
**Gateway**: Security Analysis  
**Servers**: Memory, GitHub, Code Index, Docker, AWS  
**Rationale**: Security analysis, vulnerability scanning, and compliance checking.

---

## Security Considerations

### Risk Classification

#### 🔴 CRITICAL RISK (Immediate Attention Required)

**Desktop Commander**
- Full system command execution
- Can delete/modify any file
- Terminal commands bypass directory restrictions
- **Action**: Configure immediately, Docker installation recommended

**AWS MCP**
- Cloud resource creation/deletion
- Potential for significant cost
- Data access across services
- **Action**: Use read-only IAM policies, enable billing alerts

**Docker MCP**
- Container lifecycle control
- Can mount host filesystem
- Access to Docker socket
- **Action**: Limit to infrastructure agent, use labels

#### 🟡 MEDIUM RISK (Configure Carefully)

**GitHub MCP**
- Can create/delete branches
- Can modify repository contents
- Depends on token permissions
- **Action**: Use fine-grained tokens with minimal scopes

**Browser MCP**
- Controls authenticated browser
- Access to logged-in sessions
- **Action**: Use test accounts, dedicated profile

#### 🟢 LOW RISK (Safe with Standard Practices)

**Read-Only Servers**
- Memory MCP (local storage)
- Code Index (read-only analysis)
- Obsidian (read-only recommended)
- Context7 (remote service)
- Ref Tools (remote service)

**Isolated Servers**
- Playwright (sandboxed browsers)
- Storybook (dev server only)

### Security Best Practices by Category

#### Credentials Management
- Store all tokens/keys in environment variables
- Never commit secrets to repositories
- Use `.env` files with `.gitignore`
- Rotate tokens/keys regularly (quarterly minimum)
- Use separate credentials for CI/CD vs development
- Enable credential auditing where available

#### Access Control
- Principle of least privilege for all IAM/tokens
- Agent-specific server restrictions
- Gateway-level isolation
- Regular permission audits
- Review active sessions weekly

#### Monitoring & Auditing
- Enable audit logging (Desktop Commander, AWS CloudTrail)
- Regular log review
- Set up alerts for unusual activity
- Monitor resource usage and costs
- Track API rate limit consumption

#### Testing & Validation
- Test new servers in isolated environment first
- Use VM or container for Desktop Commander testing
- Verify IAM policies before deployment
- Test with read-only permissions first
- Validate configuration before enabling

#### Incident Response
- Document emergency procedures
- Know how to revoke tokens/credentials quickly
- Have backup configurations
- Regular backup of Memory MCP data
- Maintain rollback procedures

---

## Installation Guide

### Prerequisites

**General**:
- Node.js 18+ (for npx-based servers)
- Python 3.10+ (for uvx-based servers)
- Docker (for containerized servers)
- Git (all agents)

**Specific Tools**:
```bash
# Install uv for Python tools
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install Docker
# Follow platform-specific instructions at docker.com

# Verify installations
node --version  # Should be 18+
python --version  # Should be 3.10+
docker --version
uv --version
```

### Quick Start Installation

#### 1. Core Servers (Install First)

```bash
# Memory MCP (recommended)
npx -y @modelcontextprotocol/server-memory

# GitHub MCP (already installed)
# Configure token first
export GITHUB_TOKEN="ghp_your_token"
npx -y @modelcontextprotocol/server-github
```

#### 2. Frontend Development Servers

```bash
# Code Index MCP
uvx code-index-mcp

# Storybook MCP
# Install in your project
npm install --save-dev @storybook/addon-mcp
```

#### 3. Testing Servers

```bash
# Playwright (already installed)
npx playwright install chromium

# Browser MCP
# 1. Install Chrome extension from browsermcp.io
# 2. Install server
npx -y @browsermcp/server
```

#### 4. Infrastructure Servers

```bash
# Docker MCP (already installed)
npx -y @modelcontextprotocol/server-docker

# AWS MCP (already installed)
# Configure credentials first
aws configure
npx -y @modelcontextprotocol/server-aws

# Desktop Commander (with Docker for security)
bash <(curl -fsSL https://raw.githubusercontent.com/wonderwhy-er/DesktopCommanderMCP/refs/heads/main/install-docker.sh)
```

#### 5. Documentation Servers

```bash
# Obsidian MCP (already installed)
export OBSIDIAN_VAULT_PATH="~/Documents/Obsidian/Work"
npx -y mcp-obsidian --vault-path "${OBSIDIAN_VAULT_PATH}"

# Context7 (already installed)
# Sign up at context7.com for API key
export CONTEXT7_API_KEY="ctx7_your_key"

# Ref Tools
# Sign up at ref.tools for API key
export REF_API_KEY="ref_your_key"

# Sequential Thinking (architect agent only)
npx -y @modelcontextprotocol/server-sequential-thinking
# Optional: disable logging
# export DISABLE_THOUGHT_LOGGING="true"
```

### Docker MCP Gateway Setup

Based on your multiple-gateway architecture:

```bash
# Gateway 1: Core + Memory (always active)
docker mcp gateway run --servers git,github,memory

# Gateway 2: Frontend + Testing (on-demand)
docker mcp gateway run --servers storybook,playwright,browser-mcp,code-index

# Gateway 3: Infrastructure + System (on-demand)
docker mcp gateway run --servers docker,aws,desktop-commander

# Gateway 4: Documentation + Research (on-demand)
docker mcp gateway run --servers obsidian,context7,ref-tools

# Gateway 5: Database + Analysis (on-demand)
docker mcp gateway run --servers code-index
```

### Verification

Test each server individually:

```bash
# Memory MCP
npx -y @modelcontextprotocol/server-memory
# Should start without errors

# GitHub MCP
echo $GITHUB_TOKEN  # Should show token
npx -y @modelcontextprotocol/server-github
# Should connect successfully

# Code Index MCP
uvx code-index-mcp --version
# Should show version number

# Check Docker access
docker ps
# Should list containers

# Check AWS access
aws sts get-caller-identity
# Should show your AWS identity
```

---

## Quick Reference Tables

### Server Summary Table

| Server | Package/Service | Type | Port | Cost | Risk |
|--------|----------------|------|------|------|------|
| Memory | `@modelcontextprotocol/server-memory` | Local | stdio | Free | Low |
| GitHub | `@modelcontextprotocol/server-github` | Local | stdio | Free | Medium |
| Storybook | `@storybook/mcp` | Remote | 6006 | Free | Low |
| Code Index | `code-index-mcp` | Local | stdio | Free | Low |
| Playwright | `@executeautomation/playwright-mcp-server` | Local | stdio | Free | Low |
| Browser MCP | `@browsermcp/server` | Local | stdio | Free | Medium |
| Docker | `@modelcontextprotocol/server-docker` | Local | stdio | Free | High |
| AWS | `@modelcontextprotocol/server-aws` | Local | stdio | Paid | Critical |
| Desktop Commander | `@wonderwhy-er/desktop-commander` | Local | stdio | Free | Critical |
| Obsidian | `mcp-obsidian` | Local | stdio | Free | Low |
| Context7 | context7.com | Remote | HTTPS | Paid | Low |
| Ref Tools | ref.tools | Remote | HTTPS | Paid | Low |
| Sequential Thinking | `@modelcontextprotocol/server-sequential-thinking` | Local | stdio | Free | Low |

### Installation Commands Reference

```bash
# Memory
npx -y @modelcontextprotocol/server-memory

# GitHub
npx -y @modelcontextprotocol/server-github

# Storybook (in project)
npm install --save-dev @storybook/addon-mcp

# Code Index
uvx code-index-mcp

# Playwright
npx -y @executeautomation/playwright-mcp-server
npx playwright install chromium

# Browser MCP
npx -y @browsermcp/server

# Docker
npx -y @modelcontextprotocol/server-docker

# AWS
npx -y @modelcontextprotocol/server-aws

# Desktop Commander
npx -y @wonderwhy-er/desktop-commander@latest

# Desktop Commander (Docker)
bash <(curl -fsSL https://raw.githubusercontent.com/wonderwhy-er/DesktopCommanderMCP/refs/heads/main/install-docker.sh)

# Obsidian
npx -y mcp-obsidian --vault-path ~/path/to/vault

# Context7 (remote service - no install)

# Ref Tools (remote service - no install)

# Sequential Thinking
npx -y @modelcontextprotocol/server-sequential-thinking
```

### Environment Variables Checklist

```bash
# Required
export GITHUB_TOKEN="ghp_..."                    # GitHub MCP

# Optional (based on servers used)
export AWS_REGION="us-east-1"                    # AWS MCP
export AWS_ACCESS_KEY_ID="AKIA..."              # AWS MCP
export AWS_SECRET_ACCESS_KEY="..."              # AWS MCP
export OBSIDIAN_VAULT_PATH="~/Documents/..."    # Obsidian MCP
export CONTEXT7_API_KEY="ctx7_..."              # Context7
export REF_API_KEY="ref_..."                    # Ref Tools
export MEMORY_FILE_PATH="/workspace/.memory/graph.jsonl"  # Memory MCP
export DISABLE_THOUGHT_LOGGING="false"          # Sequential Thinking (optional)
```

### Port Usage

| Service | Port | Purpose |
|---------|------|---------|
| Storybook | 6006 | Dev server + MCP endpoint |
| Desktop Commander Dashboard | 24282+ | Web-based logs (auto-increments) |

### Context Window Impact

| Server | Token Usage | When Active |
|--------|-------------|-------------|
| Memory | 200-500 | Always (minimal) |
| GitHub | 500-1000 | Per tool call |
| Storybook | 300-800 | Per component query |
| Code Index | 1500-3000 | Per analysis (can be large) |
| Playwright | 400-800 | Per browser operation |
| Browser MCP | 300-600 | Per browser action |
| Docker | 500-1000 | Per container operation |
| AWS | 800-1500 | Per resource query |
| Desktop Commander | 800-1500 | Many tools available |
| Obsidian | 200-600 | Per note read |
| Context7 | 1000-3000 | Full doc pages |
| Ref Tools | 500-1500 | Optimized chunks |
| Sequential Thinking | 300-800 | Per thought sequence |

**Recommendation**: Enable only needed servers per task to manage context window efficiently. Use on-demand activation pattern.

---

## Maintenance & Updates

### Regular Maintenance Tasks

**Weekly**:
- Review audit logs (Desktop Commander, AWS CloudTrail)
- Check memory usage (Memory MCP file size)
- Verify active server statuses
- Monitor API usage (Context7, Ref Tools)

**Monthly**:
- Update MCP server packages
- Rotate API keys and tokens
- Review and prune Memory MCP data
- Audit agent-to-server permissions
- Review security configurations

**Quarterly**:
- Security audit of all configurations
- Review and update IAM policies
- Cost analysis (AWS, Context7, Ref Tools)
- Performance optimization review
- Documentation updates

### Update Commands

```bash
# Update all npx-based servers (auto-updates on next run)
# No action needed for npx -y packages

# Update global installations
npm update -g code-index-mcp
npm update -g @wonderwhy-er/desktop-commander

# Update Storybook addon
npm update @storybook/addon-mcp

# Update uv-based tools
uv tool upgrade code-index-mcp

# Update Docker images
docker pull mcp/desktop-commander:latest
docker pull mcp/memory:latest
docker pull mcp/filesystem:latest
```

### Troubleshooting

**Common Issues**:

1. **MCP Server Won't Start**
   ```bash
   # Check if package exists
   npx -y @package/name --version
   
   # Check environment variables
   env | grep -E "(GITHUB|AWS|OBSIDIAN|CONTEXT7|REF)"
   
   # Test server manually
   npx -y @package/name
   ```

2. **High Context Usage**
   ```bash
   # Check which servers are enabled
   # Disable unused servers in opencode.json
   # Monitor per-agent server usage
   ```

3. **Authentication Errors**
   ```bash
   # GitHub
   curl -H "Authorization: token $GITHUB_TOKEN" \
     https://api.github.com/user
   
   # AWS
   aws sts get-caller-identity
   
   # Docker
   docker ps
   ```

4. **Desktop Commander Security**
   ```bash
   # Check configuration
   get_config({})
   
   # Review audit logs
   tail -f ~/.claude-server-commander/claude_tool_call.log
   ```

---

## Appendix

### Glossary

- **MCP**: Model Context Protocol - Standard for AI agent tool integration
- **stdio**: Standard Input/Output - Communication method between processes
- **Tree-sitter**: Parser generator tool for syntax analysis
- **AST**: Abstract Syntax Tree - Code structure representation
- **Knowledge Graph**: Network of entities and relationships
- **Gateway**: MCP server orchestrator (Docker MCP Gateway)

### Related Documentation

- [OpenCode Documentation](https://opencode.ai/docs/)
- [Docker MCP Gateway](https://docs.docker.com/ai/mcp-catalog-and-toolkit/mcp-gateway/)
- [MCP Specification](https://modelcontextprotocol.io/)
- [Agent Instructions](./agents/) - Individual agent configuration files

### Support & Resources

- OpenCode GitHub: https://github.com/sst/opencode
- OpenCode Discord: Community support channel
- MCP Servers Repository: https://github.com/modelcontextprotocol/servers
- Docker MCP Gateway Docs: https://docs.docker.com/ai/

### Version History

- **2025-11-07**: Updated documentation
  - Added Sequential Thinking MCP server (architect agent only)
  - 13 servers total
  - Enhanced architect agent capabilities for complex decisions
  
- **2025-11-07**: Initial documentation
  - 12 servers documented
  - Security guidelines established
  - Agent mapping defined

---

**Document Status**: Living document - update as servers are added/removed or configurations change.
