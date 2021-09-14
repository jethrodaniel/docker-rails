# docker-rails

Dockerize Rails.

## TLDR;

For existing Rails apps
```
curl https://raw.githubusercontent.com/jethrodaniel/docker-rails/master/install.sh | bash
```

## what it do

- single Dockerfile (choose prod/dev with targets)
- single docker-compose.yml (choose prod/dev with env vars)
- everything configurable in .env files

**Note**:

- Postgres DB is expected (otherwise the compose file needs to change)
- Webpack usage is assumed (we actually ship a dev config to allow hot-reload
  for views as well as the default JS)

## setup

Install docker and docker compose.

**Note**: you need a recent docker/compose to use Buildkit features this setup
relies on.

## usage

To bring up the entire dev application
```
. .env
docker-compose build
docker-compose run web ./bin/rails db:{drop,create,migrate,seed}
docker-compose up -d
```

Using Buildkit allows us to include all environments in a single Dockerfile
as separate targets - buildkit will take care of only building the minimal
stages/images.

In addition to this, we've pulled out as much config-related things as possible
into environment variables (in `.env` files), which allows `docker` and
`docker-compose` to be called without specifying any config-type arguments - all
you need to do is to load the right variables first.

```
. .env        # setup dev environment
. .env.prod   # setup production environment (create this file first)

# docker-compose run/build/up
#
# docker build --target dev -t app .
# docker run --rm -it -p 3000:3000 -v $(pwd):/home/deploy app
```

### Targets

There are 2 targets:

- `dev` - this is only for `development` and `test`
- `prod` - for any other `RAILS_ENV`

You can specify everything else (`RAILS_ENV`, etc) in `.env` files.

In `dev`, your code is mounted in the app (for live changes), and your DB is
using an ephemeral volume for it's `PG_DATA` directory.

**Note**: the production target assumes an _external_volume for your Postgres
data directory, create it like so
```
docker volume create pg_data  # the name shoule be specified in .env files
```

### Deployments

First, pick your target
```
. .env.prod # for example
```

If deploying with compose, specify where
```
export DOCKER_HOST="ssh://user@cloud" # add to .env/etc
docker-compose up --build -d
```

Using docker
```
# Todo: manual docker commands needed
```

### Debugging

Assuming you want to run `pry-byebug` in your app, here's an easy way

```
docker-compose up -d
docker-compose stop web
docker-compose run --service-ports web  # ensures ports are mapped
```

At which point the repl should work as expected. We also load up the `.pryrc` in
this repo as well.

### Tips

Alias `docker` and `docker-compose`
```
alias dc=docker-compose; alias d=docker
```
