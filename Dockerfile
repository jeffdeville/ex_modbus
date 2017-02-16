FROM msaraiva/elixir-dev:1.3.4
MAINTAINER Jeff Deville

RUN apk --update add alpine-sdk

ENV REFRESHED_AT 2017-02-16

RUN mkdir /app
WORKDIR /app

ADD mix.* ./
RUN mix local.hex --force
RUN mix deps.get

ADD . .
RUN MIX_ENV=test mix compile
