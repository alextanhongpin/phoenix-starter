# PhoenixStarter

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix

## Start Postgres

```bash
$ docker-compose up -d
```

## Install Distillery

Create production release:

```bash
$ MIX_ENV=prod mix release
```

Run:

```bash
$ PORT=4000 _build/prod/rel/phoenix_starter/bin/phoenix_starter foreground
```

## Multi-stage docker build

```bash
$ make docker
```

Output:

```bash
$ docker images | grep phoenix
alextanhongpin/phoenix                          latest              fff8456b5d82        53 seconds ago      77.2MB
```

## Set PORT

At `config/prod.exs`, set the following:

```
config :phoenix_starter, PhoenixStarterWeb.Endpoint,
  # load_from_system_env: true,
  # This is the port you want to connect to
  # http: [port: {:system, "PORT"}],
  http: [port: 4000], 
  url: [host: "example.com", port: 80],
  # Must be true in production
  server: true,
  cache_static_manifest: "priv/static/cache_manifest.json"
```