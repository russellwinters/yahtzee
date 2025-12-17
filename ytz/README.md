# Ytz - Yahtzee in Elixir

A minimal Yahtzee application built with Elixir and Phoenix.

## Getting Started

To start the server:

```bash
mix compile
mix run --no-halt
```

The application will be available at `http://localhost:4000`

Note: This project has no external dependencies and uses only Elixir/Erlang built-in libraries.

## Features

- **Homepage**: Displays "Hello World" welcome message
- **Ping/Pong**: Health check endpoint at `/ping` that returns "pong"

## Endpoints

- `GET /` - Homepage with Hello World
- `GET /ping` - Health check endpoint (returns "pong")

## Requirements

- Elixir 1.14 or higher
- Erlang/OTP 25 or higher
