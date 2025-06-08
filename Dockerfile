# Use a lightweight Node.js image
FROM node:18-alpine

# Install npm v9 and netcat for health checks
RUN npm install -g npm@9 && \
    apk add --no-cache netcat-openbsd

# Create app directory
WORKDIR /app

# Copy package definitions and install dependencies
COPY package*.json ./
COPY . .
RUN npm install

# Run EverShop setup to generate default config and folders
RUN npx evershop install

# Copy custom assets (themes, extensions, media, public) if any
# If you don't have these folders locally, evershop install already creates defaults
# COPY themes ./themes
# COPY extensions ./extensions
# COPY config ./config
# COPY media ./media
# COPY public ./public
# COPY translations ./translations
# COPY .evershop .evershop

# Copy entrypoint script and make it executable
# COPY entrypoint.sh /usr/local/bin/entrypoint.sh
# RUN chmod +x /usr/local/bin/entrypoint.sh

# Build production assets
RUN npm run build

# Expose application port
EXPOSE 3000

# Use entrypoint to wait for DB then start
# ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["npm", "run", "start"]