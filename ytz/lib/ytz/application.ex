defmodule Ytz.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {YtzWeb.Server, port: 4000}
    ]

    opts = [strategy: :one_for_one, name: Ytz.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
