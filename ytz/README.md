# Ytz (Yahtzee)

A Yahtzee game implementation using Phoenix LiveView. The core game logic will occur on the backend, while the UI is built with Phoenix LiveView.

## Features

- Basic homepage with "Hello World" message
- Health check ping/pong button for testing LiveView interactions

## Prerequisites

- Elixir 1.14 or later
- Erlang/OTP 25 or later

## Getting Started

⚠️ **IMPORTANT**: You must install dependencies before running the server!

### Quick Start

1. **Navigate to the ytz directory**:
   ```bash
   cd ytz
   ```

2. **Install dependencies** (requires internet access to hex.pm):
   ```bash
   mix deps.get
   ```
   
   This downloads and compiles Phoenix and all required dependencies. It may take a few minutes.

3. **Start the Phoenix server**:
   ```bash
   mix phx.server
   ```

4. **Visit the application**:
   
   Open your browser to [`localhost:4000`](http://localhost:4000)

### Troubleshooting

If you see errors like "module Phoenix.View is not loaded", you need to run `mix deps.get` first!

See [QUICKSTART.md](QUICKSTART.md) for detailed instructions.

## Current Status

The project structure has been initialized with:
- Basic Phoenix application skeleton
- LiveView-based homepage with "Hello World" message
- Health check button implementing ping/pong functionality
- All necessary configuration files
- Basic styling for a clean UI

**Note:** The project requires Phoenix and its dependencies to be installed. To make this functional:

1. Run `mix deps.get` to install dependencies
2. Start the server with `mix phx.server`

⚠️ **Security Note:** Before deploying to production, ensure you generate proper secret keys and use environment variables. The current configuration includes placeholder secrets that should be changed.

## Development

The application is structured as follows:

- `lib/ytz/` - Core application files
- `lib/ytz_web/` - Web-related modules (controllers, views, LiveViews)
- `lib/ytz_web/live/` - LiveView modules
- `lib/ytz_web/templates/` - HTML templates
- `config/` - Configuration files

## Testing

Run tests with:

```bash
mix test
```

## Future Development

This project will be expanded to include:
- Full Yahtzee game logic on the backend
- Interactive game UI using LiveView
- Scoring system
- Multiple players support
