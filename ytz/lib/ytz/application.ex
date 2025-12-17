defmodule Ytz.Application do
  use Application

  @impl true
  def start(_type, _args) do
    port = Application.get_env(:ytz, :port, 4000)
    
    children = [
      {YtzWeb.Server, port: port}
    ]

    opts = [strategy: :one_for_one, name: Ytz.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
