# Build stage
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Upgrade npm
RUN npm install -g npm@9

# Copy package manifests and turbo config
COPY package*.json turbo.json ./

# Copy workspaces and project files
COPY . .

# Install dependencies and build
RUN npm install
RUN npm run build

# Production stage
FROM node:18-alpine AS runner

WORKDIR /app

# Upgrade npm
RUN npm install -g npm@9

# Copy package manifests and disable husky install in production
COPY package*.json turbo.json ./
ENV HUSKY_SKIP_INSTALL=1

# Install only production dependencies, ignore lifecycle scripts
RUN npm install --omit=dev --ignore-scripts

# Copy built artifacts from builder
COPY --from=builder /app/packages/evershop/dist ./packages/evershop/dist

# Expose port and start application
EXPOSE 80
CMD ["node", "packages/evershop/dist/bin/start/index.js"]
