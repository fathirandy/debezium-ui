####
# This Dockerfile is used to build a production container image for Debezium UI.
###
FROM registry.access.redhat.com/ubi9/nodejs-20:1-24 as builder

WORKDIR /app
COPY --chown=1001 package*.json ./

RUN npm install

COPY --chown=1001 . .

ENV NODE_ENV=production

# Build the React application
RUN npm run build


FROM nginxinc/nginx-unprivileged:1.26

ENV KAFKA_CONNECT_CLUSTERS=http://localhost:8083/

RUN chmod 777 /etc/nginx/conf.d/default.conf && chmod -R 777 /usr/share/nginx/html
COPY --from=builder /app/dist /usr/share/nginx/html
COPY config.json /app/config.json
COPY deployment/image/create-dbzui-config.sh /docker-entrypoint.d/
