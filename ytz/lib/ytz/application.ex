defmodule Ytz.Application do
  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    port = Application.get_env(:ytz, :port, 4000)

    children = [
      {Plug.Cowboy, scheme: :http, plug: YtzWeb.Router, options: [port: port]}
    ]

    Logger.info("Server started on http://localhost:#{port}")
    
    opts = [strategy: :one_for_one, name: Ytz.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
