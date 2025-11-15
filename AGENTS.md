# Agent Guidelines - AI Config Repository

This is a **configuration-only repository** for OpenCode/MCP setup. No build/test commands exist for this repo itself.

## ⚠️ CRITICAL: Never Work on Main Branch

**BEFORE ANY WORK:**
1. Check current branch: `git branch --show-current`
2. If on `main`:
   - Create new branch: `git checkout -b feature/descriptive-name` OR
   - Checkout existing branch: `git checkout branch-name`
3. **NEVER commit directly to main**

**Branch naming**: `feature/`, `fix/`, `docs/`, `chore/`

## Key Commands

```bash
# Deploy OpenCode config (from clients/)
stow -t ~/.config/opencode opencode

# MCP Catalog management
docker mcp catalog import ./mcp/docker/servers-catalog.yaml
docker mcp catalog show mcp-servers

# Build custom MCP server (code-index-mcp)
cd mcp/servers/code-index-mcp && docker build -t local/code-index-mcp:latest .
```

## File Structure

- `clients/opencode/` - OpenCode config (stowed to `~/.config/opencode/`)
  - `opencode.json` - Main config with MCP gateway settings
  - `agent/*.md` - 10 specialized agent definitions
  - `command/*.md` - 8 custom slash commands
- `mcp/docker/servers-catalog.yaml` - MCP server definitions (11 servers)
- `docs/` - CODE_STANDARDS.md, SECURITY_GUIDELINES.md, MCP_SERVERS.md
- `mcp/servers/` - Custom MCP servers (**DO NOT EDIT** - submodules)

## Code Standards (for projects using this config)

**TypeScript**: Strict mode, explicit types, no `any`, prefer `type` over `interface`, string enums only  
**React**: Server components default, `'use client'` for interactivity, components <120 lines, Props interface above component  
**NestJS**: Controllers (thin), Services (business logic), DTOs (class-validator), parameterized queries only  
**Testing**: Jest/Vitest (unit), Playwright (e2e), `*.test.ts` in `__tests__/`  
**Imports**: Named exports only (no default), order: external → internal → relative  
**Naming**: PascalCase (components/types), camelCase (functions/vars), UPPER_SNAKE_CASE (constants)  
**Security**: No hardcoded secrets, validate all input, parameterized SQL only, HTTPS everywhere

## Git Workflow

```bash
# Branch naming: feature/*, fix/*, docs/*, chore/*
git checkout -b docs/update-mcp-catalog

# Commit format: type: subject
git commit -m "docs: update MCP server catalog with new tools"
```

**Types**: feat, fix, docs, chore, refactor

## Important Notes

- This repo has **no code to test/build** - only YAML/JSON/Markdown configs
- `mcp/servers/*` are git submodules - **DO NOT** edit or analyze them
- Changes to `clients/opencode/*` are immediately reflected via stow symlinks
- See `docs/CODE_STANDARDS.md` for comprehensive coding standards (for projects using this config)
- See `docs/SECURITY_GUIDELINES.md` for security best practices
- See `docs/MCP_SERVERS.md` for MCP server reference documentation
