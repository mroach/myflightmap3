# Myflightmap

## Running with Docker

This app is Dockerized so getting up and running should be easy.

*First time:*

```shell
docker-compose build

# fetch dependencies and prepare the database
docker-compose run app mix do deps.get, ecto.create, ecto.migrate

# seed the database for development (airports, aircraft)
docker-compose run --rm app mix run priv/repo/seeds.exs
```

*Start dev server:*

```shell
docker-compose up
```

*Run test watcher*

With this running, every time you modify a file in the app, the tests will run. Similar to how Guard works with Ruby apps.

```shell
docker-compose run --rm app mix test.watch
```

*Get an IEx shell*

```shell
docker-compose run --rm app iex -S mix
```
