defmodule YtzWeb.Server do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    port = Keyword.get(opts, :port, 4000)
    
    {:ok, listen_socket} = :gen_tcp.listen(port, [
      :binary,
      packet: :raw,
      active: false,
      reuseaddr: true
    ])
    
    Logger.info("Server started on http://localhost:#{port}")
    
    # Start accepting connections
    spawn_link(fn -> accept_loop(listen_socket) end)
    
    {:ok, %{listen_socket: listen_socket, port: port}}
  end

  defp accept_loop(listen_socket) do
    case :gen_tcp.accept(listen_socket) do
      {:ok, client_socket} ->
        # Spawn a new process to handle the request
        spawn(fn -> handle_client(client_socket) end)
        
        # Continue accepting connections
        accept_loop(listen_socket)
      
      {:error, reason} ->
        Logger.error("Failed to accept connection: #{inspect(reason)}")
        accept_loop(listen_socket)
    end
  end

  defp handle_client(socket) do
    case :gen_tcp.recv(socket, 0, 5000) do
      {:ok, data} ->
        request = parse_request(data)
        response = YtzWeb.Router.handle(request)
        :gen_tcp.send(socket, response)
        :gen_tcp.close(socket)
      
      {:error, _} ->
        :gen_tcp.close(socket)
    end
  end

  defp parse_request(data) do
    case String.split(data, "\r\n") do
      [request_line | _] when request_line != "" ->
        case String.split(request_line, " ") do
          [method, path, _version] ->
            %{method: method, path: path}
          
          _ ->
            %{method: "GET", path: "/"}
        end
      
      _ ->
        %{method: "GET", path: "/"}
    end
  end
end
