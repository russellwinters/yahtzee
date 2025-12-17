# Quick Start Guide

## Prerequisites

- Elixir 1.14+ installed
- Erlang/OTP 25+ installed

Verify with:
```bash
elixir --version
```

## Installation Steps

**Important:** You must install dependencies before running the server.

### 1. Navigate to the project directory
```bash
cd ytz
```

### 2. Install Hex (if not already installed)
```bash
mix local.hex --force
```

### 3. Install dependencies
```bash
mix deps.get
```

This will download and compile all Phoenix dependencies. This may take a few minutes the first time.

### 4. Start the Phoenix server
```bash
mix phx.server
```

Or start it inside IEx (Interactive Elixir):
```bash
iex -S mix phx.server
```

### 5. Visit the application

Open your browser to: http://localhost:4000

You should see:
- Welcome message: "Welcome to Yahtzee!"
- A "Ping" button for the health check

## Troubleshooting

### Error: "module Phoenix.View is not loaded"

This means you haven't installed the dependencies yet. Run:
```bash
mix deps.get
```

### Error: "Could not compile dependency :phoenix"

Make sure you have Elixir 1.14+ and Erlang/OTP 25+. Check with:
```bash
elixir --version
```

### Port 4000 already in use

Kill the existing process or change the port in `config/dev.exs`.

## What's Included

- **Homepage**: LiveView-based page at `/` with ping/pong health check
- **Real-time updates**: Click the "Ping" button to see instant response
- **Clean UI**: Styled with inline CSS for immediate usability

## Next Steps

After verifying the setup works:
1. Explore `lib/ytz_web/live/home_live.ex` for the LiveView implementation
2. Check `lib/ytz_web/router.ex` for routing configuration
3. Review `config/` files for environment-specific settings

For detailed documentation, see `SETUP_GUIDE.md`.
