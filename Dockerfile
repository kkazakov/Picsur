FROM node:20 AS builder

RUN npm install -g pnpm

WORKDIR /picsur

COPY pnpm-workspace.yaml package.json pnpm-lock.yaml ./
COPY tsconfig.base.json ./
COPY shared ./shared
COPY backend ./backend
COPY branding ./branding
COPY frontend/tsconfig.base.json ./frontend/
COPY frontend/custom-webpack.config.cjs ./frontend/
COPY frontend ./frontend

# Use shamefully-hoist to flatten node_modules for Docker compatibility
RUN pnpm install --frozen-lockfile --shamefully-hoist

RUN pnpm --filter picsur-shared build
RUN pnpm --filter picsur-frontend build
RUN pnpm --filter picsur-backend build

FROM node:20-alpine

# sharp's prebuilt musl binaries require only these runtime libs.
# Do NOT install system vips here - sharp ships its own libvips and using
# SHARP_FORCE_GLOBAL_LIBVIPS with a mismatched Alpine vips version causes SIGABRT.
RUN apk add --no-cache \
    python3 \
    make \
    g++

RUN npm install -g pnpm

ENV PICSUR_PRODUCTION=true

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

# Install production dependencies inside Alpine so native addons (sharp, posix.js)
# are downloaded/compiled for linux-musl, not copied from the glibc builder stage.
RUN pnpm install --frozen-lockfile --shamefully-hoist --prod

CMD ["pnpm", "--filter", "picsur-backend", "start:prod"]
