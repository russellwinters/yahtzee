#!/bin/bash
# Setup script for Ytz (Yahtzee) project

echo "Setting up Ytz (Yahtzee)..."

# Check if Elixir is installed
if ! command -v elixir &> /dev/null; then
    echo "Error: Elixir is not installed. Please install Elixir first."
    exit 1
fi

echo "Elixir version:"
elixir --version

# Check if Mix is available
if ! command -v mix &> /dev/null; then
    echo "Error: Mix is not available. Please install Elixir/Mix first."
    exit 1
fi

echo ""
echo "Installing Hex package manager..."
mix local.hex --force

echo ""
echo "Installing Phoenix archive..."
mix archive.install hex phx_new --force

echo ""
echo "Getting dependencies..."
mix deps.get

echo ""
echo "Setup complete! You can now run the server with:"
echo "  mix phx.server"
echo ""
echo "Then visit http://localhost:4000 in your browser"
