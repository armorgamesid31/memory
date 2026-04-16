# AgentMemory MCP Setup Guide

This guide describes how to set up and configure the `agentmemory` MCP on a new computer to match the current production environment.

## 1. Prerequisites

- **Node.js**: Version 20 or higher.
- **Git**: To clone the repository.

## 2. Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/armorgamesid31/memory
   cd memory
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Build the project:
   ```bash
   npm run build
   ```

## 3. Configuration

### Environment Variables
Create a `.env` file in the project root or in `~/.agentmemory/.env`:

```env
# Server Configuration
PORT=3113
III_REST_PORT=3111
III_STREAMS_PORT=3112

# Security
AGENTMEMORY_SECRET=82841a370
ALLOWED_ORIGINS=*

# LLM Provider (OpenRouter)
OPENROUTER_API_KEY=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
OPENROUTER_MODEL=google/gemini-2.0-flash-001

# Auto-Compression & Context Injection
AGENTMEMORY_AUTO_COMPRESS=true
AGENTMEMORY_INJECT_CONTEXT=true
```

## 4. MCP Configuration

Add the following to your `mcp_config.json`:

```json
{
  "mcpServers": {
    "agentmemory": {
      "command": "node",
      "args": ["path/to/memory-clean/dist/cli.mjs", "serve"],
      "env": {
        "AGENTMEMORY_SECRET": "82841a370",
        "OPENROUTER_API_KEY": "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"
      }
    },
    "chrome-devtools-mcp": {
      "command": "npx",
      "args": ["-y", "chrome-devtools-mcp"]
    },
    "coolify": {
      "command": "npx",
      "args": ["-y", "coolify-mcp"],
      "env": {
        "COOLIFY_API_KEY": "YOUR_COOLIFY_API_KEY",
        "COOLIFY_URL": "https://app.coolify.io"
      }
    }
  }
}
```

## 5. Deployment (Production)

To redeploy the production service:
1. Push changes to `main`.
2. Use the `coolify` MCP:
   ```bash
   # Or use the tool directly
   mcp_coolify_deploy_application({ id: "lscgk440ccoogossk0wws4co" })
   ```

## 6. Accessing the Viewer

Production: [https://mem.berkai.shop](https://mem.berkai.shop)
Login: `admin` / `82841a370`
