defmodule CraqValidator.Repo do
  use Ecto.Repo,
    otp_app: :craq_validator,
    adapter: Ecto.Adapters.Postgres
end
