FROM node:18-alpine AS builder
WORKDIR /app

# Disable Husky and Turbo telemetry
ENV HUSKY_SKIP_INSTALL=1 \
    TURBO_TELEMETRY_DISABLED=1

# Install npm
RUN npm install -g npm@9

# Copy package manifests and install dependencies
COPY package*.json turbo.json ./
RUN npm ci

# Copy all project files
COPY . .

# Run initial setup script (creates config, admin user, etc.)
RUN npm run setup -- --yes

# Build application assets
RUN npm run build

# --- Runner Stage ---
FROM node:18-alpine AS runner
WORKDIR /app

# Disable Husky and Turbo telemetry
ENV HUSKY_SKIP_INSTALL=1 \
    TURBO_TELEMETRY_DISABLED=1

# Install production dependencies only
COPY package*.json turbo.json ./
RUN npm ci --omit=dev --ignore-scripts

# Copy built artifacts and necessary folders
COPY --from=builder /app/packages/evershop/dist ./packages/evershop/dist
COPY --from=builder /app/public ./public
COPY --from=builder /app/media ./media
COPY --from=builder /app/config ./config
COPY --from=builder /app/translations ./translations

# Ensure folder permissions
RUN chmod -R 755 public .evershop .log media

# Expose port and start application
EXPOSE 80
CMD ["npm", "run", "start"]