FROM node:18-alpine

WORKDIR /app

ENV HUSKY_SKIP_INSTALL=1 \
    TURBO_TELEMETRY_DISABLED=1 \
    TURBO_TELEMETRY=0

RUN npm install -g npm@9 \
    && npm ci --omit=dev --ignore-scripts

COPY . .
RUN npm run build

EXPOSE 80
CMD ["node", "packages/evershop/dist/bin/start/index.js"]