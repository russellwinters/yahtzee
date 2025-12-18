defmodule YtzWeb.PageController do
  use YtzWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
