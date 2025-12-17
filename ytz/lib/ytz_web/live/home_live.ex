defmodule YtzWeb.HomeLive do
  use YtzWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, pong_message: nil)}
  end

  @impl true
  def handle_event("ping", _params, socket) do
    {:noreply, assign(socket, pong_message: "pong")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container">
      <h1>Welcome to Yahtzee!</h1>
      <p>Hello, World! This is a Phoenix LiveView application.</p>
      
      <div class="health-check">
        <h2>Health Check</h2>
        <button phx-click="ping">Ping</button>
        <%= if @pong_message do %>
          <p class="response">Response: <%= @pong_message %></p>
        <% end %>
      </div>
    </div>
    """
  end
end
