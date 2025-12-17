defmodule YtzWeb.Router do
  use Plug.Router

  plug Plug.Logger
  plug :match
  plug :dispatch

  get "/" do
    YtzWeb.PageController.index(conn, %{})
  end

  get "/ping" do
    YtzWeb.PageController.ping(conn, %{})
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
