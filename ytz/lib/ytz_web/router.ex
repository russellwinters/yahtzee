defmodule YtzWeb.Router do
  def handle(%{method: "GET", path: "/"}) do
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
    
    http_response(200, "text/html", html)
  end

  def handle(%{method: "GET", path: "/ping"}) do
    http_response(200, "text/plain", "pong")
  end

  def handle(_request) do
    http_response(404, "text/plain", "Not found")
  end

  defp http_response(status_code, content_type, body) do
    status_text = case status_code do
      200 -> "OK"
      404 -> "Not Found"
      _ -> "Unknown"
    end
    
    """
    HTTP/1.1 #{status_code} #{status_text}\r
    Content-Type: #{content_type}\r
    Content-Length: #{byte_size(body)}\r
    Connection: close\r
    \r
    #{body}
    """
  end
end
