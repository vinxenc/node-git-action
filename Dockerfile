FROM --platform=$BUILDPLATFORM node:20.10.0-slim As build
ARG TARGETPLATFORM
ARG BUILDPLATFORM

# Create app directory
WORKDIR /usr/src/app
COPY . .
RUN yarn install
RUN yarn run build
# Set NODE_ENV environment variable
ENV NODE_ENV production
RUN yarn install --production
RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM" > /log

FROM node:20.10.0-slim As production

COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/package.json ./package.json
COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /log ./dist/log

RUN npm cache clean --force && \
  yarn cache clean && \
  rm -rf /var/lib/apt/lists/* && \
  apt-get clean --dry-run

EXPOSE 1337

CMD [ "node", "--max-old-space-size=150", "dist/main.js" ]