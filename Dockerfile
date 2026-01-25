FROM node:22-bookworm

# Install system dependencies
RUN apt-get update && apt-get install -y socat curl && rm -rf /var/lib/apt/lists/*

# Install Bun (required for build scripts)
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

# Example binary 1: Gmail CLI (gog)
RUN curl -L https://github.com/steipete/gog/releases/latest/download/gog_Linux_x86_64.tar.gz \
  | tar -xz -C /usr/local/bin && chmod +x /usr/local/bin/gog || true

# Example binary 2: Google Places CLI (goplaces)
RUN curl -L https://github.com/steipete/goplaces/releases/latest/download/goplaces_Linux_x86_64.tar.gz \
  | tar -xz -C /usr/local/bin && chmod +x /usr/local/bin/goplaces || true

# Example binary 3: WhatsApp CLI (wacli)
RUN curl -L https://github.com/steipete/wacli/releases/latest/download/wacli_Linux_x86_64.tar.gz \
  | tar -xz -C /usr/local/bin && chmod +x /usr/local/bin/wacli || true

# Add more binaries below using the same pattern
# Uncomment and modify as needed:
# RUN curl -L <BINARY_URL> | tar -xz -C /usr/local/bin && chmod +x /usr/local/bin/<BINARY_NAME> || true

WORKDIR /app

# Enable corepack for pnpm
RUN corepack enable

# Cache dependencies unless package metadata changes
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml .npmrc ./
COPY ui/package.json ./ui/package.json
COPY scripts ./scripts

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy source code
COPY . .

# Build the application
RUN pnpm build

# Install and build UI
RUN pnpm ui:install
RUN pnpm ui:build

ENV NODE_ENV=production

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["node","dist/index.js"]
