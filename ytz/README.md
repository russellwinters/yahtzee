# Ytz - Yahtzee in Elixir

A Yahtzee application built with Elixir using Phoenix-style architecture powered by Plug and Cowboy.

## Architecture

This application follows Phoenix conventions and patterns:
- **Router**: `YtzWeb.Router` - Handles HTTP routing using `Plug.Router`
- **Controller**: `YtzWeb.PageController` - Manages request/response logic
- **Application**: `Ytz.Application` - Supervises the web server using `Plug.Cowboy`

The application uses Plug and Cowboy for the web server infrastructure, providing a lightweight yet familiar Phoenix-style development experience.

## Getting Started

To install dependencies and start the server:

```bash
mix deps.get

mix compile

mix run --no-halt
```

The application will be available at `http://localhost:4000`

## Features

- **Homepage**: Displays "Hello World" welcome message with an interactive Ping button
- **Ping/Pong**: Health check endpoint at `/ping` that returns "pong"
- **Phoenix-style architecture**: Router, Controller, and Application supervision tree

## Endpoints

- `GET /` - Homepage with Hello World and interactive Ping button
- `GET /ping` - Health check endpoint (returns "pong")

## Dependencies

- **Plug & Cowboy**: Web server and HTTP request handling
- **Jason**: JSON encoding/decoding (available for future use)

## Requirements

- Elixir 1.14 or higher
- Erlang/OTP 25 or higher
