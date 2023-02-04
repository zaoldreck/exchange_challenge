defmodule ExchangeChallenge.Repo do
  use Ecto.Repo,
    otp_app: :exchange_challenge,
    adapter: Ecto.Adapters.Postgres
end
