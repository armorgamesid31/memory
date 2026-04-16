FROM node:20-slim

WORKDIR /app

# Install dependencies for iii-engine (curl, ca-certificates, etc)
RUN apt-get update && apt-get install -y curl ca-certificates && rm -rf /var/lib/apt/lists/*

# Install iii-engine
RUN curl -fsSL https://install.iii.dev/iii/main/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

# Increase Node.js memory limit to 512MB
ENV NODE_OPTIONS="--max-old-space-size=512"

# Copy package config
COPY package*.json ./

# Install app deps
RUN npm install

# Copy source
COPY . .

# Build app
RUN npm run build

# Expose ports
EXPOSE 3111 3112 3113

# Default start command starts the CLI which boots the engine and the server
CMD ["npm", "start"]
