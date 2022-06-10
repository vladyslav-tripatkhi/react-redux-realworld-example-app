FROM node:lts-slim as builder

WORKDIR /opt/server
COPY . .

RUN npm ci && npm run build 

FROM nginx:alpine 

COPY --from=builder /opt/server/build usr/share/nginx/html
