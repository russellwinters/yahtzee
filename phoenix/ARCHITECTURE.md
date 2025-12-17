# Phoenix Yahtzee Architecture

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Browser                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │              Phoenix LiveView                       │    │
│  │  • Automatic DOM updates                            │    │
│  │  • WebSocket connection                             │    │
│  │  • Event handling                                   │    │
│  └────────────────────────────────────────────────────┘    │
└───────────────────────────┬─────────────────────────────────┘
                            │ WebSocket
                            │
┌───────────────────────────▼─────────────────────────────────┐
│                    Phoenix Server (Elixir)                   │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              PhoenixWeb.Endpoint                     │   │
│  │  • HTTP request handling                             │   │
│  │  • WebSocket upgrades                                │   │
│  │  • Static file serving                               │   │
│  └──────────────────────┬───────────────────────────────┘   │
│                         │                                     │
│  ┌──────────────────────▼───────────────────────────────┐   │
│  │              PhoenixWeb.Router                       │   │
│  │  • Route matching                                    │   │
│  │  • Pipeline execution                                │   │
│  └──────────────────────┬───────────────────────────────┘   │
│                         │                                     │
│  ┌──────────────────────▼───────────────────────────────┐   │
│  │           PhoenixWeb.HomeLive                        │   │
│  │  • Mount: Initialize state                           │   │
│  │  • Handle events: Process user actions               │   │
│  │  • Render: Generate HTML                             │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Phoenix.PubSub                          │   │
│  │  • Message broadcasting                              │   │
│  │  • Process communication                             │   │
│  └──────────────────────────────────────────────────────┘   │
└───────────────────────────────────────────────────────────────┘
```

## Component Interaction Flow

### Initial Page Load

```
Browser                 Endpoint              Router              HomeLive
   │                       │                     │                   │
   │──GET /──────────────▶│                     │                   │
   │                       │                     │                   │
   │                       │──Route lookup──────▶│                   │
   │                       │                     │                   │
   │                       │                     │──Mount──────────▶│
   │                       │                     │                   │
   │                       │                     │◀─Initial state───│
   │                       │                     │                   │
   │◀──HTML + LiveView────│                     │                   │
   │   connection info     │                     │                   │
   │                       │                     │                   │
   │──WebSocket upgrade───▶│                     │                   │
   │                       │                     │                   │
   │◀──Connected───────────│                     │                   │
```

### Button Click (Ping/Pong)

```
Browser                 Endpoint              HomeLive
   │                       │                     │
   │──Click "Ping"────────▶│                     │
   │   (phx-click event)   │                     │
   │                       │                     │
   │                       │──handle_event──────▶│
   │                       │   ("ping", ...)     │
   │                       │                     │
   │                       │                     │ Update state:
   │                       │                     │ pong_message = "pong"
   │                       │                     │
   │                       │◀─Updated state──────│
   │                       │   (socket assigns)  │
   │                       │                     │
   │◀──DOM diff───────────│                     │
   │   (minimal changes)   │                     │
   │                       │                     │
   │   [Updates UI with    │                     │
   │    "Response: pong"]  │                     │
```

## Data Flow

### LiveView State Management

```
┌────────────────────────────────────────────────────┐
│               Socket Assigns                        │
│  (Server-side state per connection)                 │
│                                                      │
│  %{                                                  │
│    pong_message: nil | "pong"                       │
│  }                                                   │
└────────────────────────────────────────────────────┘
                    │
                    ▼
┌────────────────────────────────────────────────────┐
│               Template Rendering                    │
│                                                      │
│  <%= if @pong_message do %>                         │
│    <p>Response: <%= @pong_message %></p>            │
│  <% end %>                                           │
└────────────────────────────────────────────────────┘
                    │
                    ▼
┌────────────────────────────────────────────────────┐
│                HTML + Diffs                         │
│  Only changed parts sent to browser                 │
└────────────────────────────────────────────────────┘
```

## Request Pipeline

### Browser Pipeline (for HTML requests)

```
Request
  │
  ▼
:accepts ["html"]
  │
  ▼
:fetch_session
  │
  ▼
:fetch_live_flash
  │
  ▼
:put_root_layout
  │
  ▼
:protect_from_forgery (CSRF)
  │
  ▼
:put_secure_browser_headers
  │
  ▼
Route Handler (HomeLive)
```

## Process Architecture

```
┌─────────────────────────────────────────────────────┐
│         Phoenix.Supervisor (main supervisor)        │
└─────────────────────────────────────────────────────┘
                       │
        ┌──────────────┴──────────────┐
        │                             │
        ▼                             ▼
┌───────────────┐           ┌─────────────────┐
│ Phoenix.PubSub│           │ PhoenixWeb      │
│               │           │ .Endpoint       │
│ • Distributed │           │                 │
│ • Fault-tol.  │           │ • HTTP listener │
└───────────────┘           │ • WebSocket     │
                            └─────────────────┘
                                     │
                            ┌────────┴────────┐
                            │                 │
                            ▼                 ▼
                    ┌──────────┐      ┌──────────┐
                    │ LiveView │      │ LiveView │
                    │ Process  │      │ Process  │
                    │ (User 1) │      │ (User 2) │
                    └──────────┘      └──────────┘
```

Each connected user gets their own LiveView process:
- **Isolated**: State is separate per connection
- **Supervised**: Automatically restarted on crashes
- **Concurrent**: Multiple users handled simultaneously

## File Organization

```
lib/
├── phoenix/                    # Core application
│   └── application.ex          # Supervision tree
│
└── phoenix_web/                # Web interface
    ├── endpoint.ex             # HTTP/WebSocket entry point
    ├── router.ex               # URL routing
    │
    ├── live/                   # LiveView modules
    │   └── home_live.ex        # Homepage logic
    │
    ├── templates/              # Reusable templates
    │   └── layout/
    │       ├── root.html.heex  # HTML document shell
    │       └── app.html.heex   # App container
    │
    └── views/                  # View helpers
        ├── error_helpers.ex    # Form error helpers
        ├── error_view.ex       # Error page rendering
        └── layout_view.ex      # Layout helpers
```

## Configuration Layers

```
config/config.exs
  │
  ├─▶ config/dev.exs      (Development)
  │     • Port 4000
  │     • Live reload
  │     • Debug mode
  │
  ├─▶ config/test.exs     (Test)
  │     • Port 4002
  │     • No server
  │     • Minimal logging
  │
  └─▶ config/prod.exs     (Production)
        • Domain config
        • Asset caching
        • Minimal logging
```

## Future Architecture (Game Features)

When game logic is added, the architecture will expand:

```
┌─────────────────────────────────────────────────────┐
│                   Frontend (LiveView)                │
│  • GameLive: Main game interface                     │
│  • LobbyLive: Multiplayer lobby                      │
│  • ScoreboardLive: Live scoring                      │
└─────────────────────┬───────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────┐
│                  Game Context                        │
│  • Game.Server: GenServer for game state             │
│  • Game.Rules: Yahtzee rule validation               │
│  • Game.Scoring: Score calculation                   │
│  • Game.Dice: Dice rolling logic                     │
└─────────────────────┬───────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────┐
│                Phoenix.PubSub                        │
│  • Broadcast game updates to all players             │
│  • Real-time score changes                           │
│  • Turn notifications                                │
└──────────────────────────────────────────────────────┘
```

## Key Design Patterns

### 1. LiveView Pattern
- **Server-rendered**: HTML generated on server
- **Stateful**: Each connection maintains state
- **Event-driven**: User interactions trigger server events

### 2. Supervision Tree
- **Fault-tolerant**: Crashed processes automatically restart
- **Hierarchical**: Parent supervises children
- **Let it crash**: Don't defensive program, restart on errors

### 3. Pub/Sub Pattern
- **Decoupled**: Components don't need direct references
- **Scalable**: Works across multiple servers
- **Real-time**: Instant updates to all subscribers

### 4. Pipeline Pattern
- **Composable**: Plug functions compose together
- **Reusable**: Same pipeline for many routes
- **Transparent**: Easy to see what happens to requests

## Security Architecture

```
Request
  │
  ▼
┌─────────────────────┐
│ Firewall/WAF        │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ TLS Termination     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Phoenix Endpoint    │
│ • Request ID        │
│ • Rate limiting     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ CSRF Protection     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Session Validation  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Authorization       │
└──────────┬──────────┘
           │
           ▼
      Application
```

## Performance Characteristics

### LiveView Advantages

1. **Minimal Payload**: Only sends HTML diffs, not full pages
2. **Server-rendered**: No client-side framework overhead
3. **Stateful**: No need for client-side state management
4. **Real-time**: WebSocket connection for instant updates

### Scalability

- **Vertical**: More CPUs = more concurrent connections
- **Horizontal**: Add servers, PubSub spans them
- **Session**: Each LiveView ~50KB memory
- **Throughput**: Thousands of concurrent users per server

## Monitoring Points

Future monitoring should track:

```
┌──────────────────────────────────────┐
│        Application Metrics           │
├──────────────────────────────────────┤
│ • LiveView mount time                │
│ • Event handling latency             │
│ • Active connections                 │
│ • Memory per connection              │
│ • PubSub message rate                │
└──────────────────────────────────────┘
```

## Technology Stack Summary

- **Language**: Elixir (functional, concurrent)
- **Runtime**: BEAM VM (Erlang)
- **Web Framework**: Phoenix
- **Real-time**: Phoenix LiveView
- **HTTP Server**: Cowboy
- **Session Store**: Signed cookies
- **JSON**: Jason
- **HTML**: HEEx templates

This architecture provides:
✅ Real-time interactivity without JavaScript frameworks
✅ Fault tolerance through OTP supervision
✅ Horizontal scalability through PubSub
✅ Developer productivity through Elixir/Phoenix
