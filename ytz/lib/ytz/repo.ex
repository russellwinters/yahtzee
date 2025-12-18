defmodule Ytz.Repo do
  use Ecto.Repo,
    otp_app: :ytz,
    adapter: Ecto.Adapters.Postgres
end
