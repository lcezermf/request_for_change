### App

A CRAQ form validation

- Supports multiple choice questions with required comment, confirmations
- Supports free text questions
- Supports terminal questions to finish the flow

App is deployed and running on Gigalixir https://craqvalidator.gigalixirapp.com/request_for_change

### Stack

The solution was built using:

- Elixir 1.14
- Erlang 24.0
- Phoenix 1.7.10
- LiveView 0.20.1
- PostgreSQL

### Installation & Setup

It requires you to have the same stack installed.

If you are using `bash` you need ro run:

```bash
source .bash_env
```

If you are using `fish` as me, you need to run:

```bash
source .fish_env
```

Both commands will set the env variables for POSTGRES_USER, POSTGRES_PASSWORD and POSTGRES_HOST to later be used on test and dev env.

Once env variables are set is possible to setup the DB for both envs

```bash
mix ecto.create; mix ecto.migrate
```

```bash
MIX_ENV=test mix ecto.create; mix ecto.migrate
```

### Running the app

First needs to load the data from from `seeds.exs`:

```bash
mix run priv/repo/seeds.exs
```

The data will be loaded in batchs of 50, is possible to change this value by editing `priv/repo/seeds.exs` file.

Once the data is loaded the app can run by:

```bash
iex -S mix phx.server
```

It will run the app and also open the iex console. If you do not wanna the iex console just run `iex -S mix phx.server`

### Running test

Tests were developed using the default ExUnit framework and can be used by running:

```
mix test
```

### Formating and code styles

Is it possible to use credo, format and also Dialyzer to static code check by running.

```bash
mix credo; mix format; mix dialyzer;
```
