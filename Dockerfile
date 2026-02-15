# --- Stage 1: Build ---
FROM node:20-alpine AS build

RUN apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

WORKDIR /opt/app

COPY package.json package-lock.json ./

RUN npm ci

COPY . .

RUN npm run build

# --- Stage 2: Production ---
FROM node:20-alpine AS production

RUN apk add --no-cache vips-dev

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

WORKDIR /opt/app

COPY --from=build /opt/app/dist ./dist
COPY --from=build /opt/app/node_modules ./node_modules
COPY --from=build /opt/app/package.json ./
COPY --from=build /opt/app/public ./public
COPY --from=build /opt/app/favicon.png ./
COPY --from=build /opt/app/scripts ./scripts
COPY --from=build /opt/app/dist/config ./config

RUN chown -R node:node /opt/app

USER node

EXPOSE 1337

CMD ["npm", "run", "start"]
