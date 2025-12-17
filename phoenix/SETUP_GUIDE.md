# Phoenix Yahtzee Setup Guide

This guide will help you get the Phoenix Yahtzee application up and running.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Erlang/OTP 25+**: Download from [erlang.org](https://www.erlang.org/downloads) or use your package manager
- **Elixir 1.14+**: Download from [elixir-lang.org](https://elixir-lang.org/install.html)
- **Node.js (optional)**: Required if you plan to add JavaScript assets

### Verifying Installation

```bash
elixir --version
# Should show Elixir 1.14+ and Erlang/OTP 25+
```

## Quick Start

### Option 1: Using the setup script

```bash
cd phoenix
./setup.sh
```

This will:
1. Install Hex package manager
2. Install Phoenix archive
3. Get all dependencies

### Option 2: Manual setup

1. **Install Hex** (Elixir package manager):
   ```bash
   mix local.hex --force
   ```

2. **Uncomment dependencies in mix.exs**:
   Edit `mix.exs` and uncomment the dependencies in the `deps/0` function:
   ```elixir
   defp deps do
     [
       {:phoenix, "~> 1.7.0"},
       {:phoenix_html, "~> 3.0"},
       {:phoenix_live_reload, "~> 1.2", only: :dev},
       {:phoenix_live_view, "~> 0.20.0"},
       {:plug_cowboy, "~> 2.0"},
       {:jason, "~> 1.2"}
     ]
   end
   ```

3. **Get dependencies**:
   ```bash
   mix deps.get
   ```

4. **Start the server**:
   ```bash
   mix phx.server
   ```

5. **Visit the application**:
   Open your browser to [http://localhost:4000](http://localhost:4000)

## What You'll See

The homepage displays:
- A welcome message: "Welcome to Yahtzee!"
- "Hello, World!" greeting
- A health check section with a "Ping" button
- When you click "Ping", it will respond with "pong" demonstrating LiveView's real-time capabilities

## Project Structure

```
phoenix/
├── config/              # Application configuration
│   ├── config.exs      # General configuration
│   ├── dev.exs         # Development environment config
│   ├── prod.exs        # Production environment config
│   └── test.exs        # Test environment config
├── lib/
│   ├── phoenix/        # Core application code
│   │   └── application.ex
│   ├── phoenix_web/    # Web interface code
│   │   ├── live/       # LiveView modules
│   │   │   └── home_live.ex  # Homepage LiveView
│   │   ├── templates/  # HTML templates
│   │   │   └── layout/ # Layout templates
│   │   ├── views/      # View modules
│   │   ├── endpoint.ex # HTTP endpoint configuration
│   │   └── router.ex   # Route definitions
│   └── phoenix_web.ex  # Web module definitions
├── priv/               # Static assets and resources
├── test/               # Test files
├── mix.exs             # Project configuration and dependencies
└── README.md           # Project documentation
```

## Development

### Running Tests

```bash
mix test
```

### Code Formatting

```bash
mix format
```

### Interactive Shell

```bash
iex -S mix phx.server
```

This starts the server with an interactive Elixir shell.

## Troubleshooting

### Port Already in Use

If port 4000 is already in use:

```bash
# Kill the process using the port (macOS/Linux)
lsof -ti:4000 | xargs kill -9

# Or specify a different port in config/dev.exs
# Change the port in the http: configuration
```

### Dependencies Won't Install

Ensure you have internet access and can reach hex.pm:

```bash
ping repo.hex.pm
```

If behind a proxy, configure Mix:

```bash
export HTTP_PROXY=http://your-proxy:port
export HTTPS_PROXY=http://your-proxy:port
```

### Module Compilation Errors

If you encounter compilation errors related to Phoenix modules, ensure all dependencies are properly installed:

```bash
mix deps.clean --all
mix deps.get
mix compile
```

## Next Steps

This is the initial scaffolding. Future development will include:

1. **Game Logic**: Implementing Yahtzee game rules on the backend
2. **Dice Rolling**: Interactive dice rolling with LiveView
3. **Score Keeping**: Real-time score updates
4. **Multiple Players**: Support for multiple players in a game
5. **Game State Management**: Persistent game state

## Resources

- [Phoenix Framework Documentation](https://hexdocs.pm/phoenix/)
- [Phoenix LiveView Documentation](https://hexdocs.pm/phoenix_live_view/)
- [Elixir Documentation](https://elixir-lang.org/docs.html)
- [Learn Elixir](https://elixir-lang.org/learning.html)
