# syntax=docker/dockerfile:1

FROM ruby:3.0.2-alpine3.14 AS base
RUN apk add --no-cache \
  postgresql-dev=13.4-r0 \
  tzdata=2021a-r0 \
  imagemagick=7.0.11.13-r0
# RUN apk add --no-cache sqlite-dev=3.35.5-r0
# RUN apk add --no-cache mariadb-dev (10.5.12-r0)

#--

# less is needed to avoid a bug in pry-byebug's pager: https://github.com/pry/pry/issues/1248
#
FROM base AS builder
RUN apk add --no-cache \
  build-base=0.5-r2 \
  nodejs=14.17.6-r0 \
  yarn=1.22.10-r0 \
  less=581-r1
WORKDIR /app
COPY Gemfile Gemfile.lock package.json yarn.lock ./

#--

FROM builder AS builder-prod
WORKDIR /app

RUN yarn install --frozen-lockfile --production --non-interactive --no-color
RUN bundle config set without 'development test' \
  && bundle install --jobs=4 --retry=3

COPY . /app/

RUN RAILS_ENV=production SECRET_KEY_BASE=assets \
  bundle exec rake assets:precompile \
    && rm -rf /app/node_modules \
              /app/tmp \
    && mkdir /app/tmp

#--

FROM builder AS builder-dev
WORKDIR /app

RUN yarn install --frozen-lockfile --non-interactive --no-color
RUN bundle install --jobs=4 --retry=3

# TODO: get .pryrc loaded

#--

FROM base AS entry
COPY docker-entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/docker-entrypoint.sh

#--

FROM base AS prod
RUN adduser -D deploy
USER deploy
WORKDIR /home/deploy/app

COPY --from=builder-prod /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder-prod --chown=deploy /app/ .
COPY --from=entry --chown=deploy /usr/bin/docker-entrypoint.sh /usr/bin/

EXPOSE 3000

# Save timestamp of image building
RUN date -u > BUILD_TIME

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]

#--

FROM builder-dev AS dev
RUN adduser -D deploy
USER deploy
WORKDIR /home/deploy/app

COPY --from=entry --chown=deploy /usr/bin/docker-entrypoint.sh .
COPY --chown=deploy .pryrc /home/deploy/

EXPOSE 3000

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
