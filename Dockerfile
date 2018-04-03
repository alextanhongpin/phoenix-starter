FROM elixir:1.6.1 as asset-builder-mix-getter

ENV HOME=/opt/app

RUN mix do local.hex --force, local.rebar --force
# Cache elixir deps
COPY config/ $HOME/config/
COPY mix.exs mix.lock $HOME/
COPY mix.exs $HOME/apps/phoenix_starter/
COPY config/ $HOME/apps/phoenix_starter/config/

WORKDIR $HOME/apps/phoenix_starter
RUN mix deps.get

########################################################################
FROM node:9.10.1 as asset-builder

ENV HOME=/opt/app
WORKDIR $HOME

COPY --from=asset-builder-mix-getter $HOME/apps/phoenix_starter/deps $HOME/apps/phoenix_starter/deps

WORKDIR $HOME/apps/phoenix_starter/assets
COPY /assets/ ./
RUN yarn install
RUN ./node_modules/.bin/brunch build --production

########################################################################
FROM bitwalker/alpine-elixir:1.6.4 as releaser

ENV HOME=/opt/app

ARG ERLANG_COOKIE
ENV ERLANG_COOKIE $ERLANG_COOKIE

# dependencies for comeonin
RUN apk --update upgrade && apk add --no-cache build-base cmake

# Install Hex + Rebar
RUN mix do local.hex --force, local.rebar --force

# Cache elixir deps
COPY config/ $HOME/config/
COPY mix.exs mix.lock $HOME/

# Copy umbrella app config + mix.exs files
COPY mix.exs $HOME/apps/phoenix_starter/
COPY config/ $HOME/apps/phoenix_starter/config/

# COPY apps/phoenix_starter/mix.exs $HOME/apps/phoenix_starter/
# COPY apps/phoenix_starter/config/ $HOME/apps/phoenix_starter/config/

ENV MIX_ENV=prod
RUN mix deps.update --all
RUN mix do deps.get --only $MIX_ENV, deps.compile

COPY . $HOME/

# Digest precompiled assets
COPY --from=asset-builder $HOME/apps/phoenix_starter/priv/static/ $HOME/apps/phoenix_starter/priv/static/

WORKDIR $HOME/apps/phoenix_starter
ENV MIX_ENV=prod
RUN mix deps.update --all
RUN mix phx.digest

# Release
WORKDIR $HOME
RUN mix release 

########################################################################
FROM alpine:3.6

ENV LANG=en_US.UTF-8 \
    HOME=/opt/app/ \
    TERM=xterm

ENV MYPROJECT_VERSION=0.0.1

RUN apk --update upgrade && apk add --no-cache ncurses-libs openssl bash

EXPOSE 4000
ENV PORT=4000 \
    MIX_ENV=prod \
    REPLACE_OS_VARS=true \
    SHELL=/bin/sh

COPY --from=releaser $HOME/_build/prod/rel/phoenix_starter/releases/$MYPROJECT_VERSION/phoenix_starter.tar.gz $HOME
WORKDIR $HOME
RUN tar -xzf phoenix_starter.tar.gz

ENTRYPOINT ["/opt/app/bin/phoenix_starter"]
CMD ["foreground"]


## ERROR: /app/erts-9.2/bin/erlexec: 1: /app/erts-9.2/bin/erlexec: Syntax error: "(" unexpected
## Error will be thrown if you are trying to run the compiled version from macos on linux.
## Currently cross-compilation does not work

# FROM ubuntu
# RUN apt-get update && \
#     apt-get install -y libssl1.0.0 && \
#     apt-get autoclean
# RUN mkdir -p /app
# ARG VERSION=0.0.1
# COPY _build/prod/rel/phoenix_starter/releases/${VERSION}/phoenix_starter.tar.gz /app/phoenix_starter.tar.gz
# WORKDIR /app
# RUN tar xvzf phoenix_starter.tar.gz
# # RUN locale-gen en_US.UTF-8
# # ENV LANG en_US.UTF-8
# # ENV LANGUAGE en_US.UTF-8
# # ENV LC_ALL en_US.UTF-8
# ENV PORT 8888
# CMD ["/app/bin/phoenix_starter", "foreground"]