# Phoenix Yahtzee

A Yahtzee game implementation using Phoenix LiveView. The core game logic will occur on the backend, while the UI is built with Phoenix LiveView.

## Features

- Basic homepage with "Hello World" message
- Health check ping/pong button for testing LiveView interactions

## Prerequisites

- Elixir 1.14 or later
- Erlang/OTP 25 or later

## Getting Started

To start your Phoenix server:

1. Install dependencies (requires internet access to hex.pm):
   ```bash
   cd phoenix
   mix deps.get
   ```

2. Start the Phoenix endpoint:
   ```bash
   mix phx.server
   ```

3. Visit [`localhost:4000`](http://localhost:4000) in your browser

## Current Status

The project structure has been initialized with:
- Basic Phoenix application skeleton
- LiveView-based homepage with "Hello World" message
- Health check button implementing ping/pong functionality
- All necessary configuration files
- Basic styling for a clean UI

**Note:** The project requires Phoenix and its dependencies to be installed. Due to the current environment's network restrictions, dependencies are listed but commented out in `mix.exs`. To make this functional:

1. Uncomment the dependencies in `mix.exs`
2. Run `mix deps.get` to install them
3. Start the server with `mix phx.server`

## Development

The application is structured as follows:

- `lib/phoenix/` - Core application files
- `lib/phoenix_web/` - Web-related modules (controllers, views, LiveViews)
- `lib/phoenix_web/live/` - LiveView modules
- `lib/phoenix_web/templates/` - HTML templates
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
