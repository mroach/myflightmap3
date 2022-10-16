# Myflightmap

## Running with Docker

This app is Dockerized so getting up and running should be easy.

*First time:*

```shell
docker-compose build

# fetch dependencies and prepare the database
docker-compose run --rm app mix setup
```

*Start dev server:*

```shell
docker-compose up
```

*Run test watcher*

With this running, every time you modify a file in the app, the tests will run.

```shell
docker-compose exec app mix test.watch
```

*Get an IEx shell*

```shell
docker-compose exec app iex -S mix
```
