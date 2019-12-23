defmodule Phoenixproject.Repo do
    use Ecto.Repo,
    otp_app: :phoenixproject,
    adapter: Ecto.Adapters.Postgres
end
