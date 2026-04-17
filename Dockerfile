FROM node:20-slim

WORKDIR /app

# Install dependencies for iii-engine (curl, ca-certificates, etc)
RUN apt-get update && apt-get install -y curl wget ca-certificates && rm -rf /var/lib/apt/lists/*

# Install iii-engine
RUN curl -fsSL https://install.iii.dev/iii/main/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

# Copy package config
COPY package*.json ./

# Install app deps deterministically with higher memory to avoid OOM kills.
RUN NODE_OPTIONS="--max-old-space-size=2048" npm ci --no-audit --no-fund

# Copy source
COPY . .

# Build app with higher memory limit to avoid OOM
RUN NODE_OPTIONS="--max-old-space-size=2048" npm run build

# Expose ports
EXPOSE 3111 3112 3113

# Default start command starts the CLI which boots the engine and the server
CMD ["npm", "start"]
