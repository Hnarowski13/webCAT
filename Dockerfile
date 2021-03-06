#=================================
# Build Stage
#=================================
FROM elixir:1.7-alpine as build

# Install yarn
RUN apk add --no-cache yarn git --fresh

#Copy the source folder into the Docker image
COPY . .

#Install dependencies
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get --only prod 


# Build assets and release
RUN cd ./assets && \
    yarn && \
    yarn run build

# Build release
RUN MIX_ENV=prod mix phx.digest && \
    MIX_ENV=prod mix release



#Extract Release archive to /rel for copying in next stage
RUN APP_NAME="webcat" && \
    RELEASE_DIR=`ls -d _build/prod/rel/$APP_NAME/releases/*/` && \
    mkdir /export && \
    tar -xf "$RELEASE_DIR/$APP_NAME.tar.gz" -C /export

#=================================
# Runtime Stage
#=================================
FROM alpine:3.7

#Install Dependencies for Erlang
RUN apk add --no-cache \
    ncurses-libs \
    zlib \
    openssl \
    ca-certificates && \
    update-ca-certificates --fresh

RUN apk add --no-cache bash && \
    apk --no-cache upgrade

WORKDIR /srv/webcat

# Set environment variables and expose port
EXPOSE 8080
ENV REPLACE_OS_VARS=true \
    PORT=8080

# Copy and extract .tar.gz Release file from the previous stage
COPY --from=build /export/ .

# Set default entrypoint and command
ENTRYPOINT ["/srv/webcat/bin/webcat"]
CMD ["foreground"]