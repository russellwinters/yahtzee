defmodule YtzWeb.PageController do
  import Plug.Conn

  def index(conn, _params) do
    html = """
    <!DOCTYPE html>
    <html>
    <head>
      <title>Yahtzee - Ytz</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          max-width: 800px;
          margin: 50px auto;
          padding: 20px;
          text-align: center;
        }
        h1 {
          color: #4A5568;
        }
        button {
          background-color: #4299E1;
          color: white;
          padding: 10px 20px;
          border: none;
          border-radius: 5px;
          cursor: pointer;
          font-size: 16px;
          margin-top: 20px;
        }
        button:hover {
          background-color: #3182CE;
        }
        #response {
          margin-top: 20px;
          padding: 10px;
          border-radius: 5px;
          min-height: 30px;
        }
        .success {
          background-color: #C6F6D5;
          color: #22543D;
        }
      </style>
    </head>
    <body>
      <h1>Hello World</h1>
      <p>Welcome to Yahtzee - Ytz Edition (Elixir)</p>
      <button onclick="ping()">Ping</button>
      <div id="response"></div>
      
      <script>
        async function ping() {
          try {
            const response = await fetch('/ping');
            const data = await response.text();
            const responseDiv = document.getElementById('response');
            responseDiv.textContent = data;
            responseDiv.className = 'success';
          } catch (error) {
            const responseDiv = document.getElementById('response');
            responseDiv.textContent = 'Error: ' + error.message;
            responseDiv.className = '';
          }
        }
      </script>
    </body>
    </html>
    """

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html)
  end

  def ping(conn, _params) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "pong")
  end
end
