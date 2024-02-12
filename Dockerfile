FROM node:14
WORKDIR /opt/node_app

COPY package.json yarn.lock ./
RUN rm -rf node_modules
RUN rm -f package-lock.json

# Install dependencies ... run good
RUN yarn --ignore-optional --network-timeout 600000 && \
    yarn install && \
    yarn global add cross-env

COPY . .
#FAIL
RUN yarn build:app:docker

# Clean up unnecessary files
RUN rm -rf node_modules && \
    yarn install --production && \
    yarn cache clean

FROM nginx:1.21-alpine

COPY --from=build /opt/node_app/build /usr/share/nginx/html

# Health check
HEALTHCHECK CMD wget -q -O /dev/null http://localhost || exit 1
