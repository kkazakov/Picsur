FROM node:20 AS builder

RUN npm install -g pnpm

WORKDIR /picsur

COPY pnpm-workspace.yaml package.json pnpm-lock.yaml ./
COPY tsconfig.base.json ./
COPY shared ./shared
COPY backend ./backend
COPY frontend/tsconfig.base.json ./frontend/
COPY frontend/custom-webpack.config.cjs ./frontend/
COPY frontend ./frontend

# Use shamefully-hoist to flatten node_modules for Docker compatibility
RUN pnpm install --frozen-lockfile --shamefully-hoist

RUN pnpm --filter picsur-shared build
RUN pnpm --filter picsur-frontend build
RUN pnpm --filter picsur-backend build

FROM node:20-alpine

RUN apk add --no-cache \
    vips \
    vips-dev \
    python3 \
    make \
    g++

RUN npm install -g pnpm

ENV PICSUR_PRODUCTION=true
ENV SHARP_FORCE_GLOBAL_LIBVIPS=1

WORKDIR /picsur

# Copy all workspace files for pnpm to resolve workspace dependencies
COPY --from=builder /picsur/pnpm-workspace.yaml ./
COPY --from=builder /picsur/package.json ./
COPY --from=builder /picsur/pnpm-lock.yaml ./
COPY --from=builder /picsur/backend/package.json ./backend/
COPY --from=builder /picsur/shared/package.json ./shared/

# Copy built artifacts
COPY --from=builder /picsur/backend/dist ./backend/dist
COPY --from=builder /picsur/shared/dist ./shared/dist
COPY --from=builder /picsur/frontend/dist ./frontend/dist

# Copy node_modules from builder (includes .pnpm store for symlinks)
COPY --from=builder /picsur/node_modules ./node_modules

CMD ["pnpm", "--filter", "picsur-backend", "start:prod"]
