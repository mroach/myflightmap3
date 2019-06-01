# This is a multi-stage Dockerfile

################################################################################
# == Base
# Elixir base image for running development server and tools
FROM elixir:1.8-alpine AS phoenix_base

# Need inotify for watchers to work
# Need build-base to build native extensions (bcrypt requires it)
RUN apk --no-cache add inotify-tools build-base

WORKDIR /app

RUN mix do local.hex --force, local.rebar --force

EXPOSE 8000

CMD ["mix", "phx.server"]


################################################################################
# == Base image for including source files we'd need to compile the app
FROM phoenix_base AS builder

ENV MIX_ENV prod

COPY mix.exs mix.lock ./

RUN mix do deps.get, deps.compile

COPY config/ ./config
COPY lib/ ./lib
COPY priv/ ./priv
COPY test/ ./test
COPY rel/ ./rel


################################################################################
# == Production release builder
#
# This will use distillery to create a tarball of binaries and static files
# needed to run the app. Then we only need those files in a container for
# the app to run. We don't need Elixir, Erlang, anything else.
FROM builder as release_builder

RUN mix do release --env=${MIX_ENV}


################################################################################
# == Production runnable image
#
# Final production-ready image. Only contains the app binaries and static assets
FROM alpine:latest AS myflightmap_prod

ENV MIX_ENV prod
ENV PORT 4000

EXPOSE 4000

# bash and openssl are required to run the release
RUN apk add --no-cache bash openssl

WORKDIR /app

COPY --from=release_builder /app/_build/prod/rel/myflightmap/ .

HEALTHCHECK CMD wget -q -O /dev/null http://localhost:4000/system/alive || exit 1

CMD ["bin/myflightmap", "foreground"]
