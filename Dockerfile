# This is a multi-stage Dockerfile

ARG elixir_version=1.14.1
ARG otp_version=25.1.1
ARG debian_version=bullseye-20220801-slim

ARG builder_image="hexpm/elixir:${elixir_version}-erlang-${otp_version}-debian-${debian_version}"
ARG runner_image="debian:${debian_version}"

################################################################################
# == Base
# Elixir base image for running development server and tools
FROM ${builder_image} AS base

RUN apt-get update && apt-get install -y inotify-tools build-essential apt-utils

RUN mkdir -p /opt/mix/build /opt/mix/deps

WORKDIR /opt/app

RUN mix do local.hex --force, local.rebar --force

EXPOSE 8000

CMD ["mix", "phx.server"]


################################################################################
# == Base image for including source files we'd need to compile the app
FROM base AS builder

ENV MIX_ENV=prod

COPY mix.exs mix.lock ./

RUN mix deps.get --only ${MIX_ENV}
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY lib lib
COPY priv priv
COPY assets assets

RUN mix assets.deploy
RUN mix compile

COPY config/runtime.exs config/
COPY rel rel
RUN mix release


################################################################################
# == Production runnable image
#
# Final production-ready image. Only contains the app binaries and static assets
FROM ${runner_image}

RUN apt-get update -y && apt-get install -y libstdc++6 openssl libncurses5 locales \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

 # Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV MIX_ENV=prod \
    PORT=4000 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

EXPOSE 4000

WORKDIR /opt/app

RUN chown nobody /opt/app

COPY --from=builder --chown=nobody:root /opt/app/_build/${MIX_ENV}/rel/myflightmap ./

USER nobody

HEALTHCHECK CMD wget -q -O /dev/null http://localhost:4000/system/alive || exit 1

CMD ["/opt/app/bin/server"]
