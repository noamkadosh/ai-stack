# AI Stack

Portable multi-agent AI development infrastructure with Docker MCP Gateway orchestration.

## Overview

Production-ready MCP (Model Context Protocol) infrastructure supporting multiple AI clients with:

- **Agent isolation** - Separate tool catalogs per agent domain
- **Docker-based** - Containerized MCP servers with security controls
- **Multi-client** - Works with OpenCode, Claude Code, Cursor, etc.
- **Stow-managed** - Declarative config deployment via GNU Stow

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  AI Client (OpenCode, etc.)              │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ↓
┌─────────────────────────────────────────────────────────┐
│              10 Gateway Instances (8000-8009)            │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐  │
│  │Supervisor│ │ Frontend │ │ Backend  │ │   Test   │  │
│  │   :8000  │ │   :8001  │ │   :8002  │ │   :8003  │  │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘  │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐  │
│  │  Infra   │ │ Database │ │   Docs   │ │  Review  │  │
│  │   :8004  │ │   :8005  │ │   :8006  │ │   :8007  │  │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘  │
│  ┌──────────┐ ┌──────────┐                             │
│  │ Debugger │ │ Security │                             │
│  │   :8008  │ │   :8009  │                             │
│  └──────────┘ └──────────┘                             │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ↓
┌─────────────────────────────────────────────────────────┐
│           MCP Servers (Docker Containers)                │
│  • GitHub Official    • Playwright    • Docker          │
│  • Memory MCP        • AWS           • Context7        │
│  • Code Index MCP    • Obsidian      • Sequential      │
│  • Desktop Commander • Ref Tools                        │
└─────────────────────────────────────────────────────────┘
```

## Repository Structure

```
ai-stack/
├── clients/                    # Client-specific configs
│   ├── opencode/              # → ~/.config/opencode/ (via stow)
│   │   ├── agent/             # 10 specialized agents
│   │   ├── command/           # 8 custom commands
│   │   ├── opencode.json      # MCP gateway connections
│   │   ├── AGENTS.md          # Tech stack & standards
│   │   └── docs/
│   └── claude-code/           # → ~/.claude/ (future)
│
├── mcp/                       # Portable MCP infrastructure
│   ├── docker/                # Custom MCP servers
│   │   └── code-index-mcp/    # Submodule
│   ├── catalogs/              # 10 agent-specific catalogs
│   │   ├── supervisor-catalog.yaml
│   │   ├── frontend-catalog.yaml
│   │   ├── backend-catalog.yaml
│   │   ├── test-catalog.yaml
│   │   ├── infra-catalog.yaml
│   │   ├── database-catalog.yaml
│   │   ├── docs-catalog.yaml
│   │   ├── review-catalog.yaml
│   │   ├── debugger-catalog.yaml
│   │   └── security-catalog.yaml
│   ├── scripts/               # Gateway management
│   │   ├── start-gateways.sh
│   │   ├── stop-gateways.sh
│   │   ├── gateway-status.sh
│   │   └── test-gateway.sh
│   └── logs/                  # Runtime logs (gitignored)
│
├── README.md                  # This file
├── SETUP.md                   # Detailed setup guide
└── .gitignore
```

## Features

### 🎯 Agent Specialization

- Each agent sees only relevant tools (optimized context windows)
- 10 domain-specific catalogs: supervisor, frontend, backend, test, infra, database, docs, review, debugger, security
- Prevents tool proliferation and context pollution

### 🐳 Docker MCP Gateway

- Isolated containers with security restrictions (1 CPU, 2GB RAM)
- Streaming transport for multi-client support (ports 8000-8009)
- Centralized secrets management
- Built-in logging and call tracing

### 🔧 Custom MCP Servers

- **Code Index MCP** - Code indexing and search across 7 agent domains
- Easily extensible with additional custom servers

### 📦 Client Agnostic

- Portable `mcp/` infrastructure works with any MCP client
- Client configs in `clients/` directory (OpenCode, Claude Code, etc.)
- Stow-based deployment for clean symlink management

## Quick Start

### Prerequisites

```bash
# Required
docker --version          # Docker Desktop with MCP Toolkit enabled
docker mcp --version      # Docker MCP CLI plugin
npm install -g supergateway  # MCP transport adapter

# Optional (per client)
opencode --version        # For OpenCode
claude --version          # For Claude Code
```

### Installation

```bash
# Clone as dotfiles submodule
cd ~/dotfiles
git submodule add <repo-url> ai-stack
cd ai-stack
git submodule update --init --recursive

# Build custom MCP servers
cd mcp/docker/code-index-mcp
docker build -t local/code-index-mcp:latest .

# Import catalogs
cd ../catalogs
for catalog in *.yaml; do
  docker mcp catalog import "$catalog"
done

# Install OpenCode config
cd ~/dotfiles/ai/clients
stow -t ~/.config/opencode opencode
```

See [SETUP.md](SETUP.md) for detailed phase-by-phase instructions.

## Usage

### Gateway Management

```bash
cd ~/dotfiles/ai-stack/mcp/scripts

# Start all gateways
./start-gateways.sh

# Check status
./gateway-status.sh

# Stop all gateways
./stop-gateways.sh

# Test individual gateway
./test-gateway.sh 8000
```

### Client Configuration

**OpenCode** connects via `supergateway` (stdio → streaming):

```json
{
  "mcp": {
    "frontend-gateway": {
      "command": "npx",
      "args": [
        "-y",
        "supergateway",
        "--streamableHttp",
        "http://localhost:8001/mcp",
        "--outputTransport",
        "stdio"
      ]
    }
  }
}
```

**Claude Code** (future) uses same pattern in `~/.claude/.mcp.json`

### Updating

```bash
# Update code-index-mcp
cd ~/dotfiles/ai-stack/mcp/docker/code-index-mcp
git pull origin main
docker build -t local/code-index-mcp:latest .

# Update catalog
cd ../../catalogs
vim frontend-catalog.yaml
docker mcp catalog import frontend-catalog.yaml

# Restart affected gateways
cd ../scripts
./stop-gateways.sh
./start-gateways.sh

# Commit changes
cd ~/dotfiles/ai-stack
git add .
git commit -m "Update frontend catalog"
git push
```

## Agent-Catalog Mapping

| Agent          | Port | Catalog            | MCP Servers                           |
| -------------- | ---- | ------------------ | ------------------------------------- |
| Supervisor     | 8000 | supervisor-catalog | Memory, Context7, Sequential Thinking |
| Frontend       | 8001 | frontend-catalog   | Playwright, Code Index, Browser       |
| Backend        | 8002 | backend-catalog    | Docker, Code Index, GitHub            |
| Test Expert    | 8003 | test-catalog       | Playwright, Code Index                |
| Infrastructure | 8004 | infra-catalog      | Docker, AWS, Desktop Commander        |
| Database       | 8005 | database-catalog   | Code Index, GitHub                    |
| Documentation  | 8006 | docs-catalog       | Obsidian, Code Index                  |
| Code Reviewer  | 8007 | review-catalog     | GitHub, Code Index                    |
| Debugger       | 8008 | debugger-catalog   | Code Index, Desktop Commander, GitHub |
| Security       | 8009 | security-catalog   | GitHub, Code Index                    |

## Customization

### Add New Agent Domain

```bash
# 1. Create catalog
cd ~/dotfiles/ai-stack/mcp/catalogs
cat > my-agent-catalog.yaml << 'EOF'
version: 2
name: my-agent-catalog
displayName: My Agent Catalog
registry:
  # Add MCP servers here
EOF

# 2. Import catalog
docker mcp catalog import my-agent-catalog.yaml

# 3. Add to start-gateways.sh
vim ../scripts/start-gateways.sh
# Add: ["my-agent-catalog"]=8010

# 4. Configure client to use port 8010
```

### Add Custom MCP Server

```bash
# 1. Add as submodule
cd ~/dotfiles/ai-stack/mcp/docker
git submodule add <repo-url> my-mcp-server

# 2. Build
cd my-mcp-server
docker build -t local/my-mcp-server:latest .

# 3. Add to catalog
cd ../../catalogs
vim my-agent-catalog.yaml
# Add server with image: local/my-mcp-server:latest

# 4. Reimport
docker mcp catalog import my-agent-catalog.yaml
```

## Troubleshooting

**Gateway won't start:**

```bash
lsof -i :8000  # Check port availability
cat ~/dotfiles/ai-stack/mcp/logs/supervisor-catalog.log  # Check logs
docker mcp catalog show supervisor-catalog  # Verify catalog
```

**Client can't connect:**

```bash
npx -y supergateway --version  # Verify installed
curl http://localhost:8000/mcp  # Test gateway
ps aux | grep "docker mcp gateway.*8000"  # Verify running
```

**Custom image not found:**

```bash
docker images | grep local/  # List local images
cd ~/dotfiles/ai-stack/mcp/docker/code-index-mcp
docker build -t local/code-index-mcp:latest .  # Rebuild
```

## Performance

- **Streaming transport latency:** ~5-10ms (negligible vs LLM inference)
- **Gateway overhead:** <100MB RAM per instance
- **Container startup:** ~2-3 seconds per MCP server
- **Concurrent agents:** All 10 can run simultaneously

## Security

- ✅ Isolated Docker containers per MCP server
- ✅ Granular permission controls (CPU/memory limits)
- ✅ Secrets managed via Docker Desktop (not in env vars)
- ✅ No browser session access (Browser MCP removed)
- ✅ Local execution (no remote MCP servers)
- ✅ Streaming transport (no HTTP endpoint exposure with stdio)

## Submodules

- `mcp/docker/code-index-mcp` - [johnhuang316/code-index-mcp](https://github.com/johnhuang316/code-index-mcp)

**Initialize after cloning:**

```bash
git submodule update --init --recursive
```

## Philosophy

**Project-agnostic** - No project-specific MCP servers (e.g., Storybook)  
**Security-first** - No access to logged-in browser sessions  
**Performance-optimized** - Minimal tool sets per agent  
**Maintainable** - Upstream Dockerfiles, clear separation of concerns  
**Portable** - Works across clients and machines

## Credits

Built on:

- [Docker MCP Gateway](https://github.com/docker/mcp-gateway)
- [Model Context Protocol](https://modelcontextprotocol.io)
- [OpenCode](https://opencode.ai) (primary client)

## License

MIT - Use freely, modify as needed.

---

**See [SETUP.md](SETUP.md) for detailed installation instructions.**
