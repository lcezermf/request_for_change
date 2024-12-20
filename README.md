### App

A CRAQ form validation

- Supports multiple choice questions with required comment, confirmations
- Supports free text questions
- Supports terminal questions to finish the flow

App is deployed and running on Gigalixir https://craqvalidator.gigalixirapp.com/request_for_change

### Stack

The solution was built using:

- Elixir 1.14
- Erlang 25.0
- Phoenix 1.7.10
- LiveView 0.20.1
- PostgreSQL

### Installation & Setup

It requires you to have the same stack installed. If you are using `bash` you need ro run:

```bash
touch .bash_env

# use your credentials
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_HOST=localhost

source .bash_env
```

If you are using `fish` like me, you need to run:

```bash
touce .fish_env

# use your credentials
set -x POSTGRES_USER postgres
set -x POSTGRES_PASSWORD postgres
set -x POSTGRES_HOST localhost

source .fish_env
```

Both commands will set the env variables for POSTGRES_USER, POSTGRES_PASSWORD and POSTGRES_HOST to later be used on test and dev env.

Once env variables are set is possible to setup the DB for both envs.

```bash
mix deps.get
mix compile
mix ecto.create; mix ecto.migrate
MIX_ENV=test mix ecto.create; mix ecto.migrate
```

### Running the app

First needs to load the data from from `seeds.exs`:

```bash
mix run priv/repo/seeds.exs
```

Once the data is loaded the app can run by:

```bash
iex -S mix phx.server
```

It will run the app and also open the iex console. If you do not wanna the iex console just run `mix phx.server`

Server must be available on http://localhost:4000/request_for_change

### Running test

Tests were developed using the default ExUnit framework and can be used by running:

```
mix test
```

### Formating and code styles


```bash
mix credo; mix format; mix dialyzer;
```
