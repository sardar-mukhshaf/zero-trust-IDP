# syntax=docker/dockerfile:1

# Stage 1: Build
FROM node:18-bookworm-slim AS build

WORKDIR /app

COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn
COPY packages/backend/package.json packages/backend/
COPY packages/app/package.json packages/app/

RUN yarn install --frozen-lockfile

COPY . .

RUN yarn tsc
RUN yarn build:backend

# Stage 2: Production dependencies
FROM node:18-bookworm-slim AS deps

WORKDIR /app

COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn
COPY packages/backend/package.json packages/backend/

RUN yarn install --frozen-lockfile --production

# Stage 3: Distroless final
FROM gcr.io/distroless/nodejs18-debian12:nonroot AS production

WORKDIR /app

ENV NODE_ENV=production
ENV APP_CONFIG_app_baseUrl=https://portal.idp.example.com
ENV APP_CONFIG_backend_baseUrl=https://portal.idp.example.com

COPY --from=build --chown=nonroot:nonroot /app/packages/backend/dist /app/packages/backend/dist
COPY --from=deps --chown=nonroot:nonroot /app/node_modules /app/node_modules
COPY --from=deps --chown=nonroot:nonroot /app/packages/backend/node_modules /app/packages/backend/node_modules
COPY --from=build --chown=nonroot:nonroot /app/packages/backend/package.json /app/packages/backend/package.json

USER nonroot:nonroot

EXPOSE 7007

CMD ["packages/backend/dist/index.cjs.js"]
