# AI Development Infrastructure

Portable multi-agent AI development setup using Docker MCP Gateway with dynamic tool loading. Works with OpenCode and other MCP-compatible clients.

## What's Inside

- **11 MCP Servers** - Curated set of tools for development (GitHub, Memory, Code Search, AWS, Playwright, etc.)
- **Dynamic Loading** - Servers spin up/down on-demand to minimize resource usage
- **Client Configs** - Pre-configured OpenCode setup with agent definitions
- **Custom Servers** - Local build of Code Index MCP for semantic code search
- **Stow Deployment** - Clean symlink-based configuration management

## Architecture

```
┌─────────────────────────────────────┐
│   AI Client (OpenCode)              │
│   ~/.config/opencode/               │
└──────────────┬──────────────────────┘
               │
               ↓
┌─────────────────────────────────────┐
│   Docker MCP Gateway                │
│   (Dynamic Tool Loading)            │
└──────────────┬──────────────────────┘
               │
               ↓
┌─────────────────────────────────────┐
│   MCP Servers (11 total)            │
│   • Code Index (local build)        │
│   • Memory, Context7, GitHub        │
│   • Playwright, Docker, AWS         │
│   • Obsidian, Sequential Thinking   │
│   • Next.js DevTools                │
└─────────────────────────────────────┘
```

**Key Feature**: Dynamic tool loading means all agents have access to all tools, but containers only run when needed—optimizing both capabilities and resource usage.

## Prerequisites

- **Docker Desktop** with MCP Toolkit enabled
- **Docker MCP CLI** plugin (`docker mcp --version`)
- **GNU Stow** (`brew install stow` or `apt install stow`)
- **Git** with submodule support
- **Node.js 18+** (optional, for testing servers)

## Quick Start

### 1. Clone Repository

```bash
# As dotfiles submodule (recommended)
cd ~/dotfiles
git submodule add <repo-url> ai
cd ai
git submodule update --init --recursive

# Or standalone
git clone --recursive <repo-url> ~/ai-stack
cd ~/ai-stack
```

### 2. Build Custom MCP Servers

```bash
# Build code-index-mcp Docker image
cd mcp/servers/code-index-mcp
docker build -t local/code-index-mcp:latest .
cd ../../..
```

Verify the image:
```bash
docker images | grep code-index-mcp
# Should show: local/code-index-mcp   latest   ...
```

### 3. Set Up MCP Catalog

```bash
# Create the catalog
docker mcp catalog create mcp-servers

# Import server definitions
docker mcp catalog import ./mcp/docker/servers-catalog.yaml

# Verify catalog
docker mcp catalog show mcp-servers
```

This creates the `mcp-servers` catalog with all 11 servers and ensures the custom code-index server is properly registered.

### 4. Enable Dynamic Tool Loading

```bash
# Enable dynamic tools feature
docker mcp feature enable dynamic-tools

# Verify it's enabled
docker mcp feature ls
```

**What this does**: Allows the gateway to start/stop MCP server containers on-demand rather than running all servers constantly.

### 5. Deploy OpenCode Configuration

```bash
# From repository root
cd clients
stow -t ~/.config/opencode opencode

# Verify deployment
ls -la ~/.config/opencode/
# Should show: opencode.json, agent/, command/, docs/
```

**What this does**: Creates symlinks from `clients/opencode/` to `~/.config/opencode/`, enabling version-controlled configuration.

### 6. Configure Secrets

Some MCP servers require API keys or credentials. Configure these via Docker secrets or environment variables:

**GitHub** (required):
```bash
# Create GitHub Personal Access Token at:
# https://github.com/settings/tokens/new
# Scopes needed: repo, read:org, read:user, workflow

# Set via Docker secret (recommended)
echo "ghp_your_token" | docker secret create github.personal_access_token -
```

**Context7** (optional - for library docs):
```bash
# Sign up at context7.com, get API key
echo "ctx7_your_key" | docker secret create context7.api_key -
```

**Obsidian** (optional - for notes):
```bash
# Install Obsidian REST API plugin in your vault
# Get API key from plugin settings
echo "your_obsidian_key" | docker secret create obsidian.api_key -
```

**AWS** (optional - for cloud operations):
```bash
# Configure via environment variables or IAM role
export AWS_REGION="us-east-1"
export AWS_ACCESS_KEY_ID="AKIA..."
export AWS_SECRET_ACCESS_KEY="..."
```

### 7. Verify Setup

Test the gateway manually:
```bash
docker mcp gateway run --catalog mcp-servers
# Should start without errors and listen for connections
# Press Ctrl+C to stop
```

**Note**: OpenCode will automatically start the gateway when needed via the config in `opencode.json`.

### 8. Launch OpenCode

```bash
opencode
```

The gateway will start automatically and tools will load on-demand!

## Repository Structure

```
ai/
├── clients/
│   └── opencode/              # → stow to ~/.config/opencode/
│       ├── opencode.json      # MCP gateway configuration
│       ├── agent/             # 10 specialized agent definitions
│       ├── command/           # 8 custom slash commands
│       └── docs/              # Code standards, security guidelines
│
├── mcp/
│   ├── docker/
│   │   ├── servers-catalog.yaml    # Main catalog (11 servers)
│   └── servers/
│       └── code-index-mcp/         # Submodule - local build
│
├── docs/
│   ├── MCP_SERVERS.md         # Server reference documentation
│   ├── code-standards.md      # TypeScript/React/NestJS standards
│   └── security-guidelines.md # Security best practices
│
└── README.md                  # This file
```

## Available MCP Servers

| Server | Purpose | Type | Security |
|--------|---------|------|----------|
| **code-index** | Semantic code search & analysis | Local Build | Low |
| **memory** | Knowledge graph for persistent context | Docker Hub | Low |
| **github-official** | GitHub API integration | Docker Hub | Medium |
| **context7** | Library documentation lookups | Docker Hub | Low |
| **playwright** | Browser automation & testing | Docker Hub | Low |
| **docker** | Container management | Docker Hub | **High** |
| **obsidian** | Obsidian vault access | Docker Hub | Low |
| **sequentialthinking** | Structured problem-solving | Docker Hub | Low |
| **aws-core-mcp-server** | AWS expert guidance | Docker Hub | Low |
| **aws-documentation** | AWS docs search | Docker Hub | Low |
| **next-devtools-mcp** | Next.js development tools | Docker Hub | Low |

See [MCP_SERVERS.md](docs/MCP_SERVERS.md) for detailed documentation of each server.

## Usage

### Basic Workflow

```bash
# Start OpenCode
opencode

# Tools load dynamically as agents use them
# No need to manually start/stop servers
```

### Agent System

OpenCode is configured with 10 specialized agents (see `clients/opencode/agent/`):
- **architect** - System design and architecture decisions
- **frontend** - React/Next.js component development
- **backend** - NestJS/Node.js API development
- **test-expert** - Testing strategies and automation
- **infrastructure** - Docker/AWS deployment
- **database** - PostgreSQL schema and queries
- **documentation** - Technical documentation
- **code-review** - Code quality and standards
- **debugger** - Troubleshooting and diagnosis
- **security** - Security analysis and audits

Each agent has access to all MCP tools via the shared gateway.

### Custom Commands

Eight slash commands are available (see `clients/opencode/command/`):
- `/component` - Generate React components
- `/endpoint` - Create API endpoints
- `/hook` - Build custom React hooks
- `/test` - Write test suites
- `/e2e` - E2E test scenarios
- `/debug` - Debug assistance
- `/review` - Code review
- `/performance` - Performance analysis

## Updating

### Update MCP Servers
```bash
# Pull latest images from Docker Hub
docker pull mcp/memory:latest
docker pull mcp/github-official:latest
docker pull mcp/playwright:latest
# ... etc

# Reimport catalog to pick up changes
docker mcp catalog import ./mcp/docker/servers-catalog.yaml
```

### Update Code Index MCP
```bash
cd mcp/servers/code-index-mcp
git pull origin main
docker build -t local/code-index-mcp:latest .
```

### Update OpenCode Configuration
```bash
# Edit files in clients/opencode/
# Changes are immediately reflected (symlinked via stow)
vim clients/opencode/opencode.json

# If you add new files, re-stow
cd clients
stow -R -t ~/.config/opencode opencode
```

### Update This Repository
```bash
# As dotfiles submodule
cd ~/dotfiles/ai
git pull origin main
git submodule update --remote --recursive

# Standalone
cd ~/ai-stack
git pull origin main
git submodule update --remote --recursive
```

## Troubleshooting

### Gateway Won't Start
```bash
# Check Docker MCP plugin
docker mcp --version

# Check catalog exists
docker mcp catalog ls
# Should show: mcp-servers

# If catalog missing, recreate
docker mcp catalog create mcp-servers
docker mcp catalog import ./mcp/docker/servers-catalog.yaml

# Check feature is enabled
docker mcp feature ls | grep dynamic-tools

# Try manual start to see errors
docker mcp gateway run --catalog mcp-servers
```

### Code Index Image Not Found
```bash
# Verify image exists
docker images | grep code-index-mcp

# Rebuild if missing
cd mcp/servers/code-index-mcp
docker build -t local/code-index-mcp:latest .
```

### Stow Conflicts
```bash
# Remove existing config first
rm -rf ~/.config/opencode

# Then stow
cd clients
stow -t ~/.config/opencode opencode

# Or force overwrite
stow -t ~/.config/opencode --adopt opencode
```

### MCP Server Authentication Errors
```bash
# Check Docker secrets
docker secret ls

# Recreate secret if needed
docker secret rm github.personal_access_token
echo "ghp_new_token" | docker secret create github.personal_access_token -
```

### Check Server Logs
```bash
# List running MCP containers
docker ps | grep mcp

# View logs for specific server
docker logs <container-id>

# Follow logs in real-time
docker logs -f <container-id>
```

## Security Notes

- **Secrets Management**: Use Docker secrets for API keys, not environment variables
- **Docker Access**: The `docker` MCP server has full Docker socket access—use carefully
- **AWS Credentials**: Use read-only IAM policies for non-infrastructure work
- **GitHub Tokens**: Use fine-grained tokens with minimum required scopes
- **Network Access**: MCP servers run in isolated containers with controlled network access

See [docs/security-guidelines.md](docs/security-guidelines.md) for comprehensive security practices.

## Advanced Configuration

### Custom MCP Servers

To add your own MCP server:

1. Add to `mcp/docker/servers-catalog.yaml`:
```yaml
registry:
  my-server:
    description: My custom server
    title: My Server
    type: server
    image: local/my-server:latest
    tools: []
```

2. Build the image:
```bash
docker build -t local/my-server:latest /path/to/server
```

3. Reimport catalog:
```bash
docker mcp catalog import ./mcp/docker/servers-catalog.yaml
```

### Per-Project Configuration

OpenCode can use project-specific configs:

```bash
# In project root
mkdir -p .opencode
ln -s ~/.config/opencode/opencode.json .opencode/opencode.json

# Override specific settings
cat > .opencode/opencode.json <<EOF
{
  "instructions": ["PROJECT_RULES.md"]
}
EOF
```

## Philosophy

- **Dynamic over Static**: Tools load on-demand, not all at once
- **Security First**: Minimal permissions, isolated containers
- **Developer Experience**: One gateway, all tools, zero friction
- **Portability**: Works across machines via stow + git
- **Upstream First**: Use official Docker images when possible

## Resources

- [OpenCode Documentation](https://opencode.ai/docs/)
- [Docker MCP Gateway](https://docs.docker.com/ai/mcp-catalog-and-toolkit/mcp-gateway/)
- [MCP Specification](https://modelcontextprotocol.io/)
- [Code Index MCP](https://github.com/johnhuang316/code-index-mcp)
