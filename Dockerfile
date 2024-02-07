# syntax=docker/dockerfile:1
# read the doc: https://huggingface.co/docs/hub/spaces-sdks-docker
# you will also find guides on how best to write your Dockerfile
FROM node:20 as builder-production

ARG MONGODB_URL

WORKDIR /app

COPY --link --chown=1000 package-lock.json package.json ./
RUN npm set cache /app/.npm && \
        npm ci --omit=dev

FROM builder-production as builder

RUN npm set cache /app/.npm && \
        npm ci

COPY --link --chown=1000 . .

RUN npm run build

FROM node:20-slim

RUN npm install -g pm2

COPY --from=builder-production /app/node_modules /app/node_modules
COPY --link --chown=1000 package.json /app/package.json
COPY --from=builder /app/build /app/build

RUN ls

CMD npm run preview
