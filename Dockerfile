# This is a multi-stage Dockerfile

ARG elixir_ver=1.14

################################################################################
# == Base
# Elixir base image for running development server and tools
FROM elixir:${elixir_ver} AS phoenix_base

ARG node_ver=16.x

RUN apt-get update && apt-get install -y inotify-tools build-essential apt-utils

RUN (curl -SsL https://deb.nodesource.com/setup_${node_ver} | bash) \
	&& apt-get install -y nodejs

RUN mkdir -p /opt/mix/build /opt/mix/deps

WORKDIR /opt/app

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
# debian:stable is what the `elixir:{ver}` images are based on.
FROM debian:stable AS myflightmap_prod

ENV MIX_ENV prod
ENV PORT 4000

EXPOSE 4000

WORKDIR /opt/app

COPY --from=release_builder /opt/app/_build/prod/rel/myflightmap/ .

HEALTHCHECK CMD wget -q -O /dev/null http://localhost:4000/system/alive || exit 1

CMD ["bin/myflightmap", "foreground"]
