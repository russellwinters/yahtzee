# Phoenix Yahtzee Implementation Plan

This document provides a comprehensive technical plan for implementing Yahtzee in Elixir using the Phoenix framework with LiveView.

## 1. Overview

### Project Description

The `ytz` project is an Elixir/Phoenix implementation of the classic Yahtzee dice game. This implementation will feature a backend built with Elixir that handles all core game logic, state management, and business rules, while leveraging Phoenix LiveView for real-time, interactive frontend experiences. The game follows traditional Yahtzee rules: players roll 5 dice up to 3 times per turn across 13 turns, strategically choosing scoring categories to maximize their total score.

### Technology Stack

- **Language:** Elixir ~> 1.15
- **Web Framework:** Phoenix ~> 1.8.3
- **Real-time:** Phoenix LiveView ~> 1.1.0
- **Database:** PostgreSQL (via Ecto ~> 3.13)
- **ORM:** Ecto SQL ~> 3.13
- **HTTP Server:** Bandit ~> 1.5
- **Frontend:** Phoenix LiveView with TailwindCSS & Heroicons
- **Testing:** ExUnit (built-in), ExUnitProperties (for property-based testing)

### Key Features to Implement

1. **Core Gameplay**
   - Roll 5 dice with up to 3 rolls per turn
   - Freeze/unfreeze individual dice between rolls
   - Score selection across 13 categories
   - Turn progression and game state management

2. **Scoring System**
   - Upper section: Ones through Sixes (sum matching dice)
   - Upper section bonus: 35 points when upper section >= 63
   - Lower section: 3-of-a-kind, 4-of-a-kind, Full House, Small Straight, Large Straight, Yahtzee, Chance
   - Real-time score calculation and validation

3. **User Interface**
   - Interactive dice display with visual freeze indicators
   - Live-updating scorecard showing available and filled categories
   - Real-time game state updates via WebSockets
   - Responsive design for desktop and mobile

4. **Optional Features** (Phase 5)
   - Multiplayer support (turn-based)
   - Game history and replay
   - Statistics tracking
   - Leaderboards

---

## 2. Architecture

### Overall System Architecture

The Yahtzee implementation follows a layered architecture pattern optimized for Phoenix and OTP:

```
┌─────────────────────────────────────────────────────────────┐
│                    Phoenix LiveView Layer                    │
│  (YtzWeb.GameLive - WebSocket-based real-time UI updates)  │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ Events: roll_dice, freeze_die, 
                         │         score_category, new_game
                         ↓
┌─────────────────────────────────────────────────────────────┐
│                     Game Context Layer                       │
│         (Ytz.Game - Business Logic & Orchestration)         │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ Dice Module  │  │   Scorecard  │  │  Turn Module │     │
│  │  (rolling,   │  │   (scoring,  │  │(progression, │     │
│  │   freezing)  │  │  validation) │  │  rules)      │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ Persistence (optional)
                         ↓
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer (Ecto)                       │
│           PostgreSQL: games, players, history                │
└─────────────────────────────────────────────────────────────┘
```

**Alternative REST API Architecture** (see Section 5, Option B):
```
┌──────────────────────┐
│   Frontend (React/   │
│   Vue/vanilla JS)    │
└──────────┬───────────┘
           │ HTTP/JSON
           ↓
┌──────────────────────┐
│   Phoenix REST API   │
│   (YtzWeb.GameAPI)   │
└──────────┬───────────┘
           │
           ↓
┌──────────────────────┐
│   Game Context       │
│   (same as above)    │
└──────────────────────┘
```

### Backend Responsibilities

The Elixir/Phoenix backend is the source of truth for all game logic:

1. **Game State Management**
   - Maintain current game state (dice values, turn number, rolls remaining)
   - Validate all state transitions
   - Prevent invalid moves (e.g., rolling more than 3 times, scoring filled categories)

2. **Core Game Logic**
   - Dice rolling with cryptographically secure randomness
   - Dice freeze/unfreeze mechanics
   - Scoring calculation for all 13 categories
   - Turn progression rules
   - Win condition detection

3. **Data Persistence** (optional but recommended)
   - Save/load game state
   - Track game history
   - Store player statistics

4. **API Provision**
   - LiveView: Push real-time updates to connected clients
   - REST (alternative): Provide stateless JSON endpoints

### Frontend Responsibilities

The frontend (Phoenix LiveView or separate SPA) handles:

1. **User Interface**
   - Display dice with current values and frozen states
   - Render scorecard with scores and available categories
   - Show game status (turn number, rolls remaining, total score)

2. **User Interactions**
   - Click dice to freeze/unfreeze
   - Click scorecard categories to score
   - New game button
   - Visual feedback for actions

3. **Real-Time Updates**
   - Receive and render state changes from backend
   - Display animations for dice rolls
   - Update scorecard as categories are scored

### Communication Layer

**Option A: Phoenix LiveView (Recommended)**
- **Protocol:** WebSockets (Phoenix Channels)
- **State:** Server-maintained, pushed to clients
- **Benefits:** Simplified state management, built-in Phoenix integration, less JavaScript
- **Events:** `roll_dice`, `freeze_die`, `unfreeze_die`, `score_category`, `new_game`

**Option B: REST API**
- **Protocol:** HTTP/JSON
- **State:** Client-maintained or session-based
- **Benefits:** Frontend flexibility, easier mobile app support, simpler testing
- **Endpoints:** See Section 5, Option B for full spec

---

## 3. Core Modules Design

### Game Context (`Ytz.Game`)

The `Game` module serves as the primary orchestrator for gameplay, encapsulating all game state and coordinating between the Dice, Scorecard, and Turn modules.

**Struct Definition:**
```elixir
defmodule Ytz.Game do
  defstruct [
    :id,                    # UUID for game identification
    :dice,                  # %Ytz.Game.Dice{}
    :scorecard,             # %Ytz.Game.Scorecard{}
    :turn,                  # Integer: 1-13
    :rolls_remaining,       # Integer: 0-3
    :game_over,             # Boolean
    :created_at,            # DateTime
    :updated_at             # DateTime
  ]
end
```

**Key Functions:**
- `new/0` - Initialize a new game
- `roll_dice/1` - Roll unfrozen dice (decrements rolls_remaining)
- `freeze_die/2` - Freeze a die by index (0-4)
- `unfreeze_die/2` - Unfreeze a die by index
- `score_category/3` - Score a category and advance turn
- `get_available_categories/1` - List categories that can still be scored
- `game_over?/1` - Check if game is complete

### Dice Module (`Ytz.Game.Dice`)

The `Dice` module manages the collection of 5 dice, their values, and frozen states.

**Struct Definition:**
```elixir
defmodule Ytz.Game.Dice do
  defstruct [
    dice: [
      %{value: 1, frozen: false},
      %{value: 1, frozen: false},
      %{value: 1, frozen: false},
      %{value: 1, frozen: false},
      %{value: 1, frozen: false}
    ]
  ]
  
  @type die :: %{value: 1..6, frozen: boolean()}
  @type t :: %__MODULE__{dice: [die()]}
end
```

**Key Functions:**
- `new/0` - Create new dice collection with random initial values
- `roll/1` - Roll all unfrozen dice, return updated struct
- `freeze/2` - Freeze die at index (0-4)
- `unfreeze/2` - Unfreeze die at index
- `unfreeze_all/1` - Unfreeze all dice (called at turn start)
- `values/1` - Get list of current die values [1..6]
- `get_die/2` - Get specific die by index
- `all_frozen?/1` - Check if all dice are frozen

### Scorecard Module (`Ytz.Game.Scorecard`)

The `Scorecard` module tracks scores for all 13 categories and calculates totals.

**Struct Definition:**
```elixir
defmodule Ytz.Game.Scorecard do
  defstruct [
    # Upper Section
    ones: nil,
    twos: nil,
    threes: nil,
    fours: nil,
    fives: nil,
    sixes: nil,
    upper_bonus: 0,
    
    # Lower Section
    three_of_a_kind: nil,
    four_of_a_kind: nil,
    full_house: nil,
    small_straight: nil,
    large_straight: nil,
    yahtzee: nil,
    chance: nil
  ]
  
  @type t :: %__MODULE__{
    ones: nil | non_neg_integer(),
    twos: nil | non_neg_integer(),
    # ... (all categories)
  }
end
```

**Key Functions:**
- `new/0` - Create empty scorecard
- `score_category/3` - Record score for category with dice values
- `calculate_score/2` - Calculate potential score for category given dice
- `available_categories/1` - List unfilled categories
- `category_filled?/2` - Check if category has been scored
- `upper_section_total/1` - Sum of upper section scores
- `upper_bonus/1` - Calculate upper bonus (35 if upper >= 63)
- `lower_section_total/1` - Sum of lower section scores
- `total_score/1` - Calculate final score including bonuses

### Turn Module (`Ytz.Game.Turn`)

The `Turn` module encapsulates turn-specific logic and validation rules.

**Functions:**
- `can_roll?/1` - Validate if rolling is allowed (rolls_remaining > 0)
- `can_score?/1` - Validate if scoring is allowed (must have rolled at least once)
- `advance/1` - Advance to next turn, reset rolls_remaining
- `is_final_turn?/1` - Check if current turn is #13

---

## 4. Game Rules Implementation

### Rolling Dice

**Rules:**
- Maximum 3 rolls per turn
- Frozen dice keep their values
- At least one roll required before scoring
- Cannot roll after scoring current turn

**Implementation Approach:**
```elixir
def roll_dice(%Game{} = game) do
  cond do
    game.game_over ->
      {:error, "Game is over"}
      
    game.rolls_remaining == 0 ->
      {:error, "No rolls remaining this turn"}
      
    true ->
      new_dice = Dice.roll(game.dice)
      updated_game = %{game | 
        dice: new_dice,
        rolls_remaining: game.rolls_remaining - 1,
        updated_at: DateTime.utc_now()
      }
      {:ok, updated_game}
  end
end
```

### Freezing/Unfreezing Individual Dice

**Rules:**
- Can freeze/unfreeze any die after first roll
- Cannot freeze dice before rolling in a turn
- Frozen dice remain unchanged during subsequent rolls

**Implementation Approach:**
```elixir
def freeze_die(%Game{} = game, die_index) when die_index in 0..4 do
  if game.rolls_remaining == 3 do
    {:error, "Must roll before freezing dice"}
  else
    case Dice.freeze(game.dice, die_index) do
      {:ok, new_dice} ->
        {:ok, %{game | dice: new_dice, updated_at: DateTime.utc_now()}}
      {:error, reason} ->
        {:error, reason}
    end
  end
end
```

### Scoring Categories

#### Upper Section

**Rules:** Sum of all matching die face values.

| Category | Scoring Rule | Example |
|----------|-------------|---------|
| Ones | Sum of all 1s | [1,1,3,4,5] = 2 points |
| Twos | Sum of all 2s | [2,2,2,4,5] = 6 points |
| Threes | Sum of all 3s | [3,3,3,3,1] = 12 points |
| Fours | Sum of all 4s | [4,4,5,6,1] = 8 points |
| Fives | Sum of all 5s | [5,5,5,2,3] = 15 points |
| Sixes | Sum of all 6s | [6,6,6,6,6] = 30 points |

**Upper Section Bonus:** If upper section total >= 63, add 35 bonus points.

**Implementation:**
```elixir
defp score_upper_section(dice_values, target_value) do
  dice_values
  |> Enum.filter(&(&1 == target_value))
  |> Enum.sum()
end

def calculate_upper_bonus(scorecard) do
  upper_total = upper_section_total(scorecard)
  if upper_total >= 63, do: 35, else: 0
end
```

#### Lower Section

**Three-of-a-Kind:**
- **Rule:** At least 3 dice with same value → sum of ALL dice
- **Example:** [4,4,4,2,5] = 19 points
- **Example:** [2,2,3,4,5] = 0 points (no three-of-a-kind)

**Four-of-a-Kind:**
- **Rule:** At least 4 dice with same value → sum of ALL dice
- **Example:** [6,6,6,6,2] = 26 points
- **Example:** [3,3,3,4,5] = 0 points (no four-of-a-kind)

**Full House:**
- **Rule:** 3 of one value + 2 of another → 25 points
- **Example:** [3,3,3,5,5] = 25 points
- **Example:** [2,2,2,2,4] = 0 points (not a full house)

**Small Straight:**
- **Rule:** Sequence of 4 consecutive dice → 30 points
- **Valid sequences:** 1-2-3-4, 2-3-4-5, 3-4-5-6
- **Example:** [1,2,3,4,6] = 30 points
- **Example:** [1,3,4,5,6] = 30 points (contains 3-4-5-6)

**Large Straight:**
- **Rule:** Sequence of 5 consecutive dice → 40 points
- **Valid sequences:** 1-2-3-4-5, 2-3-4-5-6
- **Example:** [1,2,3,4,5] = 40 points
- **Example:** [1,2,3,4,6] = 0 points (not large straight)

**Yahtzee:**
- **Rule:** All 5 dice same value → 50 points
- **Example:** [4,4,4,4,4] = 50 points

**Chance:**
- **Rule:** Any combination → sum of ALL dice
- **Example:** [1,2,3,4,5] = 15 points

**Implementation Examples:**
```elixir
defmodule Ytz.Game.Scoring do
  @full_house_score 25
  @small_straight_score 30
  @large_straight_score 40
  @yahtzee_score 50
  
  def calculate_three_of_a_kind(dice_values) do
    if has_n_of_kind?(dice_values, 3) do
      Enum.sum(dice_values)
    else
      0
    end
  end
  
  def calculate_full_house(dice_values) do
    frequencies = Enum.frequencies(dice_values)
    counts = Map.values(frequencies) |> Enum.sort()
    
    if counts == [2, 3] do
      @full_house_score
    else
      0
    end
  end
  
  def calculate_small_straight(dice_values) do
    unique_sorted = dice_values |> Enum.uniq() |> Enum.sort()
    
    sequences = [
      [1, 2, 3, 4],
      [2, 3, 4, 5],
      [3, 4, 5, 6]
    ]
    
    if Enum.any?(sequences, &sequence_present?(unique_sorted, &1)) do
      @small_straight_score
    else
      0
    end
  end
  
  defp sequence_present?(dice, sequence) do
    Enum.all?(sequence, &(&1 in dice))
  end
  
  def calculate_yahtzee(dice_values) do
    if Enum.uniq(dice_values) |> length() == 1 do
      @yahtzee_score
    else
      0
    end
  end
end
```

### Turn Progression

**Rules:**
1. Each turn begins with 3 available rolls
2. All dice are unfrozen at turn start
3. Player must score or scratch a category to end turn
4. Turn counter advances (1 → 2 → ... → 13)
5. Game ends after turn 13 is scored

**Implementation:**
```elixir
def score_category(%Game{} = game, category, score_value) do
  cond do
    game.game_over ->
      {:error, "Game is over"}
      
    game.rolls_remaining == 3 ->
      {:error, "Must roll at least once before scoring"}
      
    Scorecard.category_filled?(game.scorecard, category) ->
      {:error, "Category already scored"}
      
    true ->
      # Record score
      {:ok, new_scorecard} = Scorecard.score_category(
        game.scorecard, 
        category, 
        score_value
      )
      
      # Advance turn
      next_turn = game.turn + 1
      game_over = next_turn > 13
      
      updated_game = %{game |
        scorecard: new_scorecard,
        turn: next_turn,
        rolls_remaining: 3,
        dice: Dice.unfreeze_all(game.dice),
        game_over: game_over,
        updated_at: DateTime.utc_now()
      }
      
      {:ok, updated_game}
  end
end
```

### Game Completion

**Condition:** Game ends when all 13 categories have been scored (turn > 13).

**Final Score Calculation:**
1. Sum all upper section scores
2. Add upper section bonus (if applicable)
3. Sum all lower section scores
4. Total = upper + upper_bonus + lower

---

## 5. API Design - Two Options

### Option A: Phoenix LiveView (Recommended)

Phoenix LiveView provides a real-time, server-rendered approach that minimizes JavaScript while delivering reactive user experiences.

#### Architecture

**LiveView Module:** `YtzWeb.GameLive`

- **Mount:** Initialize game state or load existing game
- **Handle Events:** Process user interactions (roll, freeze, score)
- **Handle Info:** Process async updates (if using PubSub)
- **Render:** Server-side templates with live bindings

#### LiveView Implementation Sketch

```elixir
defmodule YtzWeb.GameLive do
  use YtzWeb, :live_view
  alias Ytz.Game
  
  @impl true
  def mount(_params, _session, socket) do
    game = Game.new()
    {:ok, assign(socket, game: game, error: nil)}
  end
  
  @impl true
  def handle_event("roll_dice", _params, socket) do
    case Game.roll_dice(socket.assigns.game) do
      {:ok, updated_game} ->
        {:noreply, assign(socket, game: updated_game, error: nil)}
      {:error, reason} ->
        {:noreply, assign(socket, error: reason)}
    end
  end
  
  @impl true
  def handle_event("freeze_die", %{"index" => index}, socket) do
    index = String.to_integer(index)
    case Game.freeze_die(socket.assigns.game, index) do
      {:ok, updated_game} ->
        {:noreply, assign(socket, game: updated_game, error: nil)}
      {:error, reason} ->
        {:noreply, assign(socket, error: reason)}
    end
  end
  
  @impl true
  def handle_event("score_category", %{"category" => category}, socket) do
    game = socket.assigns.game
    score_value = Game.calculate_score_for_category(game, category)
    
    case Game.score_category(game, category, score_value) do
      {:ok, updated_game} ->
        {:noreply, assign(socket, game: updated_game, error: nil)}
      {:error, reason} ->
        {:noreply, assign(socket, error: reason)}
    end
  end
  
  @impl true
  def handle_event("new_game", _params, socket) do
    game = Game.new()
    {:noreply, assign(socket, game: game, error: nil)}
  end
  
  @impl true
  def render(assigns) do
    ~H"""
    <div class="game-container">
      <.dice_display dice={@game.dice} />
      <.game_controls 
        game={@game} 
        on_roll={JS.push("roll_dice")} 
      />
      <.scorecard 
        scorecard={@game.scorecard} 
        dice={@game.dice}
        on_score={&JS.push("score_category", value: %{category: &1})}
      />
      <.error_message :if={@error} message={@error} />
    </div>
    """
  end
end
```

#### Events

| Event | Parameters | Description |
|-------|-----------|-------------|
| `roll_dice` | (none) | Rolls all unfrozen dice |
| `freeze_die` | `%{index: 0..4}` | Freezes die at index |
| `unfreeze_die` | `%{index: 0..4}` | Unfreezes die at index |
| `score_category` | `%{category: string}` | Scores the selected category |
| `new_game` | (none) | Starts a new game |

#### Benefits of LiveView

- **Less JavaScript:** Most interactivity handled server-side
- **Real-time Updates:** WebSocket-based, instant UI updates
- **Simplified State Management:** Server maintains single source of truth
- **Built-in Security:** CSRF protection, secure WebSocket connections
- **SEO Friendly:** Server-rendered HTML
- **Developer Experience:** Write Elixir instead of JavaScript

#### State Management with LiveView

State is maintained in the LiveView process:
- **Ephemeral:** Game state lives in process memory
- **Per-connection:** Each browser tab has its own game instance
- **Optional Persistence:** Can periodically save to database
- **Session Recovery:** Can restore from DB on reconnect

### Option B: REST API

A traditional REST API provides maximum flexibility for frontend implementation and supports non-web clients.

#### Endpoint Specifications

**Base Path:** `/api/games`

##### 1. Create New Game
```
POST /api/games
Response: 201 Created
{
  "id": "uuid",
  "dice": [
    {"value": 3, "frozen": false},
    {"value": 1, "frozen": false},
    {"value": 6, "frozen": false},
    {"value": 2, "frozen": false},
    {"value": 4, "frozen": false}
  ],
  "turn": 1,
  "rolls_remaining": 3,
  "game_over": false,
  "scorecard": {
    "ones": null,
    "twos": null,
    // ... all categories
  },
  "total_score": 0,
  "created_at": "2025-12-18T10:30:00Z"
}
```

##### 2. Get Game State
```
GET /api/games/:id
Response: 200 OK
{
  // Same structure as POST /api/games
}
```

##### 3. Roll Dice
```
POST /api/games/:id/roll
Response: 200 OK
{
  "dice": [
    {"value": 5, "frozen": false},
    {"value": 5, "frozen": false},
    {"value": 2, "frozen": false},
    {"value": 6, "frozen": false},
    {"value": 1, "frozen": false}
  ],
  "rolls_remaining": 2
}
```

##### 4. Freeze Die
```
PUT /api/games/:id/dice/:index/freeze
Response: 200 OK
{
  "dice": [
    {"value": 5, "frozen": true},  // index 0 frozen
    {"value": 5, "frozen": false},
    // ...
  ]
}
```

##### 5. Unfreeze Die
```
PUT /api/games/:id/dice/:index/unfreeze
Response: 200 OK
```

##### 6. Score Category
```
POST /api/games/:id/score
Body: {"category": "three_of_a_kind"}
Response: 200 OK
{
  "scorecard": {
    "three_of_a_kind": 19,
    // ... other categories
  },
  "turn": 2,
  "rolls_remaining": 3,
  "total_score": 19
}
```

#### Controller Implementation Sketch

```elixir
defmodule YtzWeb.GameController do
  use YtzWeb, :controller
  alias Ytz.Game
  alias Ytz.GameServer  # GenServer for state management
  
  def create(conn, _params) do
    game = Game.new()
    {:ok, _pid} = GameServer.start_game(game)
    
    conn
    |> put_status(:created)
    |> json(game_to_json(game))
  end
  
  def show(conn, %{"id" => id}) do
    case GameServer.get_game(id) do
      {:ok, game} ->
        json(conn, game_to_json(game))
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Game not found"})
    end
  end
  
  def roll(conn, %{"id" => id}) do
    with {:ok, game} <- GameServer.get_game(id),
         {:ok, updated_game} <- Game.roll_dice(game),
         :ok <- GameServer.update_game(id, updated_game) do
      json(conn, %{
        dice: updated_game.dice,
        rolls_remaining: updated_game.rolls_remaining
      })
    else
      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: reason})
    end
  end
  
  # ... other actions
end
```

#### Benefits of REST API

- **Frontend Flexibility:** Use any frontend framework (React, Vue, Angular)
- **Mobile App Support:** Same API for web and mobile clients
- **Easier Testing:** Straightforward HTTP request/response testing
- **Caching:** Can leverage HTTP caching mechanisms
- **Stateless:** Easier horizontal scaling (with session store)

#### State Management with REST

Since HTTP is stateless, game state must be stored:

**Option 1: Database (PostgreSQL via Ecto)**
- Persist every game state change
- Query by game ID
- Pros: Durable, survives server restarts
- Cons: Higher latency, database load

**Option 2: In-Memory (ETS or GenServer)**
- Store game state in ETS table or GenServer registry
- Fast reads/writes
- Pros: Low latency, high performance
- Cons: Lost on server restart (unless periodically persisted)

**Recommended Hybrid Approach:**
- Use GenServer + ETS for active games
- Periodically snapshot to database
- Load from DB on server restart or on-demand

---

## 6. State Management

### Storage Options

For the Yahtzee implementation, we have several state management strategies, each with trade-offs:

#### Option 1: Ephemeral LiveView Process State (Simplest)

**Approach:** Store game state directly in LiveView process assigns.

**Pros:**
- Simplest implementation
- No additional infrastructure needed
- Fast access (in-process memory)

**Cons:**
- Lost on browser disconnect/refresh
- Cannot share game between devices
- No game history
- Doesn't scale beyond single server

**Best For:** Prototype, single-player, non-persistent games

**Implementation:**
```elixir
def mount(_params, _session, socket) do
  game = Game.new()
  {:ok, assign(socket, game: game)}
end
```

#### Option 2: GenServer Registry (Recommended for Production)

**Approach:** Use a GenServer per game, registered in a Registry.

**Pros:**
- Survives LiveView disconnects
- Can be accessed by multiple LiveView processes
- Enables multiplayer (multiple clients, one game)
- Supervision tree integration
- Background tasks (auto-save, timeouts)

**Cons:**
- More complex than Option 1
- Lost on server restart (unless persisted)
- Requires process management

**Best For:** Production single-server deployments, multiplayer games

**Implementation:**
```elixir
defmodule Ytz.GameServer do
  use GenServer
  
  # Client API
  def start_link(game_id) do
    GenServer.start_link(__MODULE__, game_id, name: via_tuple(game_id))
  end
  
  def get_game(game_id) do
    GenServer.call(via_tuple(game_id), :get_game)
  end
  
  def roll_dice(game_id) do
    GenServer.call(via_tuple(game_id), :roll_dice)
  end
  
  defp via_tuple(game_id) do
    {:via, Registry, {Ytz.GameRegistry, game_id}}
  end
  
  # Server Callbacks
  @impl true
  def init(game_id) do
    # Load from DB or create new
    game = case Ytz.Games.get_game(game_id) do
      nil -> Game.new() |> Map.put(:id, game_id)
      game -> game
    end
    
    {:ok, game}
  end
  
  @impl true
  def handle_call(:get_game, _from, game) do
    {:reply, game, game}
  end
  
  @impl true
  def handle_call(:roll_dice, _from, game) do
    case Game.roll_dice(game) do
      {:ok, updated_game} ->
        # Optional: async persist to DB
        Task.start(fn -> Ytz.Games.save_game(updated_game) end)
        {:reply, {:ok, updated_game}, updated_game}
      {:error, reason} ->
        {:reply, {:error, reason}, game}
    end
  end
end
```

**Supervision Tree:**
```elixir
defmodule Ytz.Application do
  use Application
  
  def start(_type, _args) do
    children = [
      # ...
      {Registry, keys: :unique, name: Ytz.GameRegistry},
      {DynamicSupervisor, name: Ytz.GameSupervisor, strategy: :one_for_one}
    ]
    
    Supervisor.start_link(children, strategy: :one_for_one, name: Ytz.Supervisor)
  end
end
```

#### Option 3: ETS Table (Alternative In-Memory)

**Approach:** Store games in an ETS table.

**Pros:**
- Fast lookups
- Shared across all processes
- No process overhead per game
- Can handle millions of games

**Cons:**
- No process isolation (games are just data)
- Lost on server restart
- No built-in concurrency control (need explicit locking)

**Best For:** High-volume, read-heavy scenarios

#### Option 4: Database-First (Most Durable)

**Approach:** Persist every state change to PostgreSQL.

**Pros:**
- Survives server restarts
- Full game history
- Easy analytics
- Multi-server support

**Cons:**
- Slower than in-memory options
- Higher database load
- More complex

**Best For:** Games requiring full persistence, multi-server deployments

**Recommended Hybrid:** GenServer (Option 2) + Database (Option 4)
- Active games in GenServers
- Periodic snapshots to database
- Load from DB on server restart or game resumption

### Session Management

For REST API approach, use Phoenix sessions or tokens:

```elixir
# In router.ex
pipeline :api do
  plug :accepts, ["json"]
  plug :fetch_session
  plug :put_secure_browser_headers
end

# In controller
def create(conn, _params) do
  game = Game.new()
  {:ok, _pid} = GameServer.start_game(game.id, game)
  
  conn
  |> put_session(:game_id, game.id)
  |> json(game)
end

def show(conn, _params) do
  game_id = get_session(conn, :game_id)
  game = GameServer.get_game(game_id)
  json(conn, game)
end
```

### Persistence Strategy

**Recommended Approach:**

1. **Write-Behind Caching:**
   - Keep game state in GenServer
   - Asynchronously write to DB after each action
   - Reduces latency for user actions

2. **Read-Through:**
   - On GameServer init, check DB first
   - If not in memory, load from DB
   - Otherwise create new game

3. **Periodic Snapshots:**
   - Every N minutes, snapshot all active games to DB
   - Ensures recent state survives crashes

```elixir
defmodule Ytz.GameServer do
  use GenServer
  
  @persist_interval :timer.minutes(5)
  
  def init(game_id) do
    game = load_or_create_game(game_id)
    schedule_persist()
    {:ok, game}
  end
  
  def handle_info(:persist, game) do
    Ytz.Games.save_game(game)
    schedule_persist()
    {:noreply, game}
  end
  
  defp schedule_persist do
    Process.send_after(self(), :persist, @persist_interval)
  end
end
```

### Recovery from Disconnections

**LiveView Approach:**
- On reconnect, LiveView mount function runs again
- Load game from GenServer or DB by ID
- Resume game state seamlessly

**REST API Approach:**
- Client stores game_id (localStorage, cookie)
- On reconnect, fetch game state via GET /api/games/:id
- Client reconstructs UI from returned state

---

## 7. Database Schema

While in-memory state is sufficient for prototyping, persistence enables game history, analytics, and multiplayer features.

### Schema Definitions

#### Games Table

```sql
CREATE TABLE games (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  turn INTEGER NOT NULL DEFAULT 1,
  rolls_remaining INTEGER NOT NULL DEFAULT 3,
  game_over BOOLEAN NOT NULL DEFAULT FALSE,
  dice JSONB NOT NULL,  -- Array of {value, frozen}
  scorecard JSONB NOT NULL,  -- Category scores
  total_score INTEGER GENERATED ALWAYS AS (
    (scorecard->>'total')::INTEGER
  ) STORED,
  player_id UUID REFERENCES players(id),
  started_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE,
  inserted_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX games_player_id_index ON games(player_id);
CREATE INDEX games_completed_at_index ON games(completed_at) WHERE completed_at IS NOT NULL;
```

#### Ecto Schema

```elixir
defmodule Ytz.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset
  
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  
  schema "games" do
    field :turn, :integer, default: 1
    field :rolls_remaining, :integer, default: 3
    field :game_over, :boolean, default: false
    field :dice, :map  # %{"dice" => [%{"value" => 1, "frozen" => false}, ...]}
    field :scorecard, :map  # %{"ones" => nil, "twos" => 5, ...}
    field :total_score, :integer, virtual: true
    field :started_at, :utc_datetime
    field :completed_at, :utc_datetime
    
    belongs_to :player, Ytz.Accounts.Player
    
    timestamps(type: :utc_datetime)
  end
  
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:turn, :rolls_remaining, :game_over, :dice, :scorecard, :completed_at])
    |> validate_required([:turn, :rolls_remaining, :dice, :scorecard])
    |> validate_inclusion(:turn, 1..13)
    |> validate_inclusion(:rolls_remaining, 0..3)
  end
end
```

#### Players Table (Optional - for multiplayer)

```sql
CREATE TABLE players (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE,
  inserted_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX players_email_index ON players(email);
```

#### Game History Table (Optional - for analytics)

```sql
CREATE TABLE game_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  game_id UUID NOT NULL REFERENCES games(id) ON DELETE CASCADE,
  event_type VARCHAR(50) NOT NULL,  -- 'roll', 'freeze', 'score', 'new_turn'
  event_data JSONB NOT NULL,
  occurred_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX game_history_game_id_index ON game_history(game_id);
CREATE INDEX game_history_occurred_at_index ON game_history(occurred_at);
```

### Migration Examples

```elixir
defmodule Ytz.Repo.Migrations.CreateGames do
  use Ecto.Migration
  
  def change do
    create table(:games, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :turn, :integer, null: false, default: 1
      add :rolls_remaining, :integer, null: false, default: 3
      add :game_over, :boolean, null: false, default: false
      add :dice, :map, null: false
      add :scorecard, :map, null: false
      add :started_at, :utc_datetime, null: false, default: fragment("NOW()")
      add :completed_at, :utc_datetime
      
      timestamps(type: :utc_datetime)
    end
    
    create index(:games, [:completed_at])
  end
end
```

---

## 8. Frontend Integration

### LiveView Component Structure

**Recommended Structure:**

```
lib/ytz_web/live/game_live/
├── game_live.ex              # Main LiveView module
├── dice_component.ex         # Dice display and freeze controls
├── scorecard_component.ex    # Scorecard with scoring buttons
├── game_controls_component.ex # Roll button, new game, etc.
└── templates/
    ├── game_live.html.heex
    ├── dice_component.html.heex
    └── scorecard_component.html.heex
```

### Dice Display Component

**Requirements:**
- Show all 5 dice with current values
- Visual indicator for frozen dice
- Click to freeze/unfreeze
- Animated roll transitions

**Implementation Sketch:**

```elixir
defmodule YtzWeb.GameLive.DiceComponent do
  use YtzWeb, :live_component
  
  def render(assigns) do
    ~H"""
    <div class="dice-container flex gap-4 justify-center my-8">
      <%= for {die, index} <- Enum.with_index(@dice.dice) do %>
        <.die 
          value={die.value} 
          frozen={die.frozen} 
          index={index}
          on_click={@on_click}
        />
      <% end %>
    </div>
    """
  end
  
  defp die(assigns) do
    ~H"""
    <div 
      class={"die-face die-#{@value} #{if @frozen, do: "frozen", else: ""}"} 
      phx-click={@on_click}
      phx-value-index={@index}
    >
      <.die_dots value={@value} />
    </div>
    """
  end
end
```

**CSS Considerations:**
- Use TailwindCSS for responsive layout
- Use CSS transitions for roll animations
- Visual distinction for frozen dice (border, opacity, or lock icon)
- Accessible click targets (min 44x44px)

### Scorecard Component

**Requirements:**
- Display all 13 categories with current scores
- Show available categories (can be scored)
- Show potential score for current dice
- Click category to score it
- Highlight upper section bonus progress

**Implementation Sketch:**

```elixir
defmodule YtzWeb.GameLive.ScorecardComponent do
  use YtzWeb, :live_component
  
  def render(assigns) do
    ~H"""
    <div class="scorecard border rounded-lg p-4">
      <h2 class="text-xl font-bold mb-4">Scorecard</h2>
      
      <!-- Upper Section -->
      <section class="mb-4">
        <h3 class="font-semibold">Upper Section</h3>
        <.category_row 
          category="ones" 
          label="Ones" 
          score={@scorecard.ones}
          potential={calculate_potential(@dice, "ones")}
          on_score={@on_score}
        />
        <!-- ... other upper categories -->
        
        <div class="border-t pt-2 mt-2">
          <div>Upper Total: <%= upper_total(@scorecard) %></div>
          <div>Bonus: <%= @scorecard.upper_bonus %> <%= bonus_progress(@scorecard) %></div>
        </div>
      </section>
      
      <!-- Lower Section -->
      <section>
        <h3 class="font-semibold">Lower Section</h3>
        <.category_row 
          category="three_of_a_kind" 
          label="3 of a Kind" 
          score={@scorecard.three_of_a_kind}
          potential={calculate_potential(@dice, "three_of_a_kind")}
          on_score={@on_score}
        />
        <!-- ... other lower categories -->
      </section>
      
      <!-- Total -->
      <div class="border-t-2 border-black pt-2 mt-4 font-bold text-lg">
        Total Score: <%= total_score(@scorecard) %>
      </div>
    </div>
    """
  end
  
  defp category_row(assigns) do
    ~H"""
    <div class="flex justify-between items-center py-2 border-b">
      <span><%= @label %></span>
      <div class="flex gap-4 items-center">
        <%= if @score != nil do %>
          <span class="font-semibold"><%= @score %></span>
        <% else %>
          <span class="text-gray-400 text-sm">(<%= @potential %>)</span>
          <button 
            phx-click={@on_score}
            phx-value-category={@category}
            class="btn-score px-3 py-1 bg-blue-500 text-white rounded hover:bg-blue-600"
          >
            Score
          </button>
        <% end %>
      </div>
    </div>
    """
  end
end
```

### Game Controls Component

**Requirements:**
- Roll button (disabled when no rolls remaining)
- New game button
- Display turn number and rolls remaining
- Display error messages

**Implementation Sketch:**

```elixir
defmodule YtzWeb.GameLive.GameControlsComponent do
  use YtzWeb, :live_component
  
  def render(assigns) do
    ~H"""
    <div class="game-controls text-center my-6">
      <div class="game-status mb-4">
        <p class="text-lg">Turn <%= @game.turn %> of 13</p>
        <p class="text-md text-gray-600">
          <%= @game.rolls_remaining %> rolls remaining
        </p>
      </div>
      
      <div class="flex gap-4 justify-center">
        <button 
          phx-click="roll_dice"
          disabled={@game.rolls_remaining == 0 or @game.game_over}
          class="btn-roll px-6 py-3 bg-green-500 text-white rounded-lg hover:bg-green-600 disabled:bg-gray-300 disabled:cursor-not-allowed"
        >
          Roll Dice
        </button>
        
        <button 
          phx-click="new_game"
          class="btn-new px-6 py-3 bg-gray-500 text-white rounded-lg hover:bg-gray-600"
        >
          New Game
        </button>
      </div>
      
      <%= if @game.game_over do %>
        <div class="game-over mt-6 p-4 bg-yellow-100 rounded">
          <h3 class="text-xl font-bold">Game Over!</h3>
          <p>Final Score: <%= Scorecard.total_score(@game.scorecard) %></p>
        </div>
      <% end %>
    </div>
    """
  end
end
```

### Interaction Handlers

**Dice Interactions:**
- **Click dice:** Freeze/unfreeze toggle
- **Visual feedback:** CSS class change (border, opacity)
- **Disabled state:** Cannot freeze before first roll

**Scorecard Interactions:**
- **Hover category:** Highlight row, show potential score
- **Click "Score":** Confirm and apply score, advance turn
- **Disabled state:** Cannot score if already filled or no rolls taken

### Real-Time Updates

LiveView automatically pushes updates to clients:

```elixir
def handle_event("roll_dice", _params, socket) do
  case Game.roll_dice(socket.assigns.game) do
    {:ok, updated_game} ->
      # LiveView automatically re-renders with new assigns
      {:noreply, assign(socket, game: updated_game)}
    {:error, reason} ->
      {:noreply, put_flash(socket, :error, reason)}
  end
end
```

**Update Flow:**
1. User clicks "Roll Dice"
2. Browser sends `phx-click` event to server
3. LiveView handles event, updates game state
4. LiveView re-renders template with new assigns
5. Only DOM diffs are sent to browser via WebSocket
6. Browser applies diffs, UI updates instantly

---

## 9. Testing Strategy

Comprehensive testing is critical for game logic correctness. Yahtzee has well-defined rules that must be validated.

### Unit Tests (Scoring Logic, Dice Rolling)

**Test Scope:** Individual modules in isolation.

**Dice Module Tests** (`test/ytz/game/dice_test.exs`):

```elixir
defmodule Ytz.Game.DiceTest do
  use ExUnit.Case, async: true
  alias Ytz.Game.Dice
  
  describe "new/0" do
    test "creates 5 dice with values between 1 and 6" do
      dice = Dice.new()
      assert length(dice.dice) == 5
      
      Enum.each(dice.dice, fn die ->
        assert die.value in 1..6
        refute die.frozen
      end)
    end
  end
  
  describe "roll/1" do
    test "rolls unfrozen dice" do
      dice = Dice.new()
      original_values = Dice.values(dice)
      
      # Roll enough times to ensure at least some values change
      # (statistically near certain after 100 rolls)
      Enum.reduce(1..100, dice, fn _, acc ->
        Dice.roll(acc)
      end)
      
      # Not a robust test for single roll, but validates behavior
    end
    
    test "does not roll frozen dice" do
      dice = Dice.new()
      {:ok, dice} = Dice.freeze(dice, 0)
      
      frozen_value = hd(dice.dice).value
      
      # Roll many times
      dice = Enum.reduce(1..50, dice, fn _, acc -> Dice.roll(acc) end)
      
      # First die should still have same value
      assert hd(dice.dice).value == frozen_value
      assert hd(dice.dice).frozen
    end
  end
  
  describe "freeze/2 and unfreeze/2" do
    test "freezes and unfreezes dice by index" do
      dice = Dice.new()
      
      {:ok, dice} = Dice.freeze(dice, 2)
      assert Enum.at(dice.dice, 2).frozen
      
      {:ok, dice} = Dice.unfreeze(dice, 2)
      refute Enum.at(dice.dice, 2).frozen
    end
    
    test "returns error for invalid index" do
      dice = Dice.new()
      assert {:error, _} = Dice.freeze(dice, 5)
      assert {:error, _} = Dice.freeze(dice, -1)
    end
  end
end
```

**Scorecard Module Tests** (`test/ytz/game/scorecard_test.exs`):

```elixir
defmodule Ytz.Game.ScorecardTest do
  use ExUnit.Case, async: true
  alias Ytz.Game.{Scorecard, Scoring}
  
  describe "upper section scoring" do
    test "calculates ones correctly" do
      assert Scoring.calculate_score([1, 1, 1, 3, 4], "ones") == 3
      assert Scoring.calculate_score([2, 3, 4, 5, 6], "ones") == 0
    end
    
    test "calculates sixes correctly" do
      assert Scoring.calculate_score([6, 6, 6, 6, 6], "sixes") == 30
      assert Scoring.calculate_score([1, 2, 3, 4, 5], "sixes") == 0
    end
  end
  
  describe "three of a kind" do
    test "scores sum of all dice when three match" do
      assert Scoring.calculate_score([4, 4, 4, 2, 5], "three_of_a_kind") == 19
      assert Scoring.calculate_score([6, 6, 6, 6, 1], "three_of_a_kind") == 25
    end
    
    test "scores 0 when less than three match" do
      assert Scoring.calculate_score([1, 2, 3, 4, 5], "three_of_a_kind") == 0
      assert Scoring.calculate_score([2, 2, 3, 4, 5], "three_of_a_kind") == 0
    end
  end
  
  describe "full house" do
    test "scores 25 for valid full house" do
      assert Scoring.calculate_score([3, 3, 3, 5, 5], "full_house") == 25
      assert Scoring.calculate_score([2, 2, 4, 4, 4], "full_house") == 25
    end
    
    test "scores 0 for invalid combinations" do
      assert Scoring.calculate_score([1, 2, 3, 4, 5], "full_house") == 0
      assert Scoring.calculate_score([3, 3, 3, 3, 5], "full_house") == 0
    end
  end
  
  describe "straights" do
    test "small straight scores 30" do
      assert Scoring.calculate_score([1, 2, 3, 4, 6], "small_straight") == 30
      assert Scoring.calculate_score([2, 3, 4, 5, 6], "small_straight") == 30
      assert Scoring.calculate_score([1, 2, 3, 4, 5], "small_straight") == 30
    end
    
    test "large straight scores 40" do
      assert Scoring.calculate_score([1, 2, 3, 4, 5], "large_straight") == 40
      assert Scoring.calculate_score([2, 3, 4, 5, 6], "large_straight") == 40
    end
    
    test "non-straights score 0" do
      assert Scoring.calculate_score([1, 1, 3, 4, 5], "small_straight") == 0
      assert Scoring.calculate_score([1, 2, 4, 5, 6], "large_straight") == 0
    end
  end
  
  describe "yahtzee" do
    test "scores 50 when all dice match" do
      assert Scoring.calculate_score([5, 5, 5, 5, 5], "yahtzee") == 50
      assert Scoring.calculate_score([1, 1, 1, 1, 1], "yahtzee") == 50
    end
    
    test "scores 0 when dice don't all match" do
      assert Scoring.calculate_score([5, 5, 5, 5, 6], "yahtzee") == 0
    end
  end
  
  describe "upper section bonus" do
    test "awards 35 points when upper section >= 63" do
      scorecard = %Scorecard{
        ones: 3,
        twos: 6,
        threes: 9,
        fours: 12,
        fives: 15,
        sixes: 18
      }
      assert Scorecard.calculate_upper_bonus(scorecard) == 35
    end
    
    test "awards 0 points when upper section < 63" do
      scorecard = %Scorecard{
        ones: 3,
        twos: 6,
        threes: 9,
        fours: 12,
        fives: 15,
        sixes: 12
      }
      assert Scorecard.calculate_upper_bonus(scorecard) == 0
    end
  end
end
```

### Context Tests (Game Flow)

**Test Scope:** Game module orchestration and state transitions.

**Game Context Tests** (`test/ytz/game_test.exs`):

```elixir
defmodule Ytz.GameTest do
  use ExUnit.Case, async: true
  alias Ytz.Game
  
  describe "new/0" do
    test "initializes a new game with correct starting state" do
      game = Game.new()
      
      assert game.turn == 1
      assert game.rolls_remaining == 3
      refute game.game_over
      assert length(game.dice.dice) == 5
    end
  end
  
  describe "roll_dice/1" do
    test "decrements rolls_remaining" do
      game = Game.new()
      {:ok, game} = Game.roll_dice(game)
      
      assert game.rolls_remaining == 2
    end
    
    test "returns error when no rolls remaining" do
      game = %{Game.new() | rolls_remaining: 0}
      assert {:error, _} = Game.roll_dice(game)
    end
    
    test "returns error when game is over" do
      game = %{Game.new() | game_over: true}
      assert {:error, _} = Game.roll_dice(game)
    end
  end
  
  describe "freeze_die/2" do
    test "prevents freezing before first roll" do
      game = Game.new()
      assert {:error, _} = Game.freeze_die(game, 0)
    end
    
    test "allows freezing after rolling" do
      game = Game.new()
      {:ok, game} = Game.roll_dice(game)
      assert {:ok, game} = Game.freeze_die(game, 0)
      assert Enum.at(game.dice.dice, 0).frozen
    end
  end
  
  describe "score_category/3" do
    test "records score and advances turn" do
      game = Game.new()
      {:ok, game} = Game.roll_dice(game)
      
      {:ok, game} = Game.score_category(game, "chance", 15)
      
      assert game.scorecard.chance == 15
      assert game.turn == 2
      assert game.rolls_remaining == 3
    end
    
    test "sets game_over after turn 13" do
      game = %{Game.new() | turn: 13}
      {:ok, game} = Game.roll_dice(game)
      {:ok, game} = Game.score_category(game, "chance", 20)
      
      assert game.game_over
      assert game.turn == 14
    end
    
    test "prevents scoring same category twice" do
      game = Game.new()
      {:ok, game} = Game.roll_dice(game)
      {:ok, game} = Game.score_category(game, "ones", 3)
      
      {:ok, game} = Game.roll_dice(game)
      assert {:error, _} = Game.score_category(game, "ones", 4)
    end
    
    test "prevents scoring without rolling" do
      game = Game.new()
      assert {:error, _} = Game.score_category(game, "ones", 0)
    end
  end
  
  describe "complete game flow" do
    test "can complete a full 13-turn game" do
      game = Game.new()
      
      categories = [
        "ones", "twos", "threes", "fours", "fives", "sixes",
        "three_of_a_kind", "four_of_a_kind", "full_house",
        "small_straight", "large_straight", "yahtzee", "chance"
      ]
      
      game = Enum.reduce(categories, game, fn category, acc ->
        {:ok, acc} = Game.roll_dice(acc)
        dice_values = Ytz.Game.Dice.values(acc.dice)
        score = Ytz.Game.Scoring.calculate_score(dice_values, category)
        {:ok, acc} = Game.score_category(acc, category, score)
        acc
      end)
      
      assert game.game_over
      assert game.turn == 14
    end
  end
end
```

### Integration Tests (API/LiveView)

**LiveView Tests** (`test/ytz_web/live/game_live_test.exs`):

```elixir
defmodule YtzWeb.GameLiveTest do
  use YtzWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  
  test "renders initial game state", %{conn: conn} do
    {:ok, view, html} = live(conn, "/game")
    
    assert html =~ "Turn 1 of 13"
    assert html =~ "3 rolls remaining"
    assert has_element?(view, "button", "Roll Dice")
  end
  
  test "rolling dice updates state", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/game")
    
    # Click roll button
    view |> element("button", "Roll Dice") |> render_click()
    
    # Should show 2 rolls remaining after 1 roll
    assert has_element?(view, "p", "2 rolls remaining")
  end
  
  test "freezing dice works", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/game")
    
    # Roll first
    view |> element("button", "Roll Dice") |> render_click()
    
    # Click first die to freeze
    view |> element(".die-face", at: 0) |> render_click()
    
    # Die should have frozen class
    assert has_element?(view, ".die-face.frozen")
  end
  
  test "scoring a category advances turn", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/game")
    
    # Roll and score
    view |> element("button", "Roll Dice") |> render_click()
    view |> element("button[phx-value-category='chance']") |> render_click()
    
    # Should advance to turn 2
    assert has_element?(view, "p", "Turn 2 of 13")
    assert has_element?(view, "p", "3 rolls remaining")
  end
  
  test "game over after 13 turns", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/game")
    
    categories = [
      "ones", "twos", "threes", "fours", "fives", "sixes",
      "three_of_a_kind", "four_of_a_kind", "full_house",
      "small_straight", "large_straight", "yahtzee", "chance"
    ]
    
    Enum.each(categories, fn category ->
      view |> element("button", "Roll Dice") |> render_click()
      view |> element("button[phx-value-category='#{category}']") |> render_click()
    end)
    
    assert has_element?(view, ".game-over")
    assert has_element?(view, "h3", "Game Over!")
  end
end
```

### Property-Based Testing

Use **StreamData** (ExUnitProperties) to test game rules with generated inputs.

**Installation:**
```elixir
# mix.exs
{:stream_data, "~> 1.1", only: [:test, :dev]}
```

**Property Tests** (`test/ytz/game/scoring_properties_test.exs`):

```elixir
defmodule Ytz.Game.ScoringPropertiesTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  alias Ytz.Game.Scoring
  
  # Generator for valid dice rolls
  defp dice_generator do
    list_of(integer(1..6), length: 5)
  end
  
  property "upper section scores are always non-negative" do
    check all dice <- dice_generator() do
      assert Scoring.calculate_score(dice, "ones") >= 0
      assert Scoring.calculate_score(dice, "twos") >= 0
      assert Scoring.calculate_score(dice, "threes") >= 0
      assert Scoring.calculate_score(dice, "fours") >= 0
      assert Scoring.calculate_score(dice, "fives") >= 0
      assert Scoring.calculate_score(dice, "sixes") >= 0
    end
  end
  
  property "chance score equals sum of dice" do
    check all dice <- dice_generator() do
      expected_sum = Enum.sum(dice)
      assert Scoring.calculate_score(dice, "chance") == expected_sum
    end
  end
  
  property "yahtzee scores 50 or 0 only" do
    check all dice <- dice_generator() do
      score = Scoring.calculate_score(dice, "yahtzee")
      assert score in [0, 50]
    end
  end
  
  property "full house scores 25 or 0 only" do
    check all dice <- dice_generator() do
      score = Scoring.calculate_score(dice, "full_house")
      assert score in [0, 25]
    end
  end
  
  property "large straight implies small straight" do
    check all dice <- dice_generator() do
      large_score = Scoring.calculate_score(dice, "large_straight")
      small_score = Scoring.calculate_score(dice, "small_straight")
      
      # If large straight scores, small straight must also score
      if large_score > 0 do
        assert small_score > 0
      end
    end
  end
end
```

### Testing Best Practices

1. **Isolation:** Use `async: true` for tests that don't share state
2. **Coverage:** Aim for 90%+ code coverage on game logic
3. **Edge Cases:** Test boundary conditions (0 rolls, turn 13, all same dice)
4. **Randomness:** Use seeded RNG for reproducible tests when needed
5. **Documentation:** Test descriptions should explain *what* and *why*

**Run Tests:**
```bash
mix test                           # Run all tests
mix test --only integration        # Run integration tests only
mix test --cover                   # Generate coverage report
mix test test/ytz/game_test.exs    # Run specific test file
```

---

## 10. Implementation Roadmap

Break implementation into manageable phases with clear deliverables.

### Phase 1: Core Game Logic (Foundation)

**Goal:** Implement pure Elixir game logic without UI.

**Tasks:**
- [x] Project setup (Phoenix 1.8.3 generated - already done)
- [ ] Implement `Dice` module
  - [ ] Struct definition with 5 dice
  - [ ] `new/0`, `roll/1`, `freeze/2`, `unfreeze/2`
  - [ ] Unit tests for all functions
- [ ] Implement `Scoring` module
  - [ ] All 13 category calculation functions
  - [ ] Upper bonus logic
  - [ ] Unit tests for each category
  - [ ] Property-based tests
- [ ] Implement `Scorecard` module
  - [ ] Struct definition for all categories
  - [ ] `score_category/3`, `available_categories/1`
  - [ ] `total_score/1` with bonus calculation
  - [ ] Unit tests

**Deliverables:**
- Fully tested Dice, Scoring, and Scorecard modules
- 90%+ test coverage on game logic
- Documentation with examples

**Time Estimate:** 2-3 days

---

### Phase 2: Game Context & State Management

**Goal:** Orchestrate game flow and enforce rules.

**Tasks:**
- [ ] Implement `Game` context module
  - [ ] Struct definition with game state
  - [ ] `new/0`, `roll_dice/1`, `freeze_die/2`
  - [ ] `score_category/3` with turn advancement
  - [ ] Game over detection
- [ ] Implement `GameServer` (GenServer)
  - [ ] Start/stop game processes
  - [ ] Registry integration
  - [ ] State queries and commands
  - [ ] Supervision tree setup
- [ ] Turn management logic
  - [ ] Reset rolls at turn start
  - [ ] Validate state transitions
  - [ ] Unfreeze dice on new turn
- [ ] Context tests
  - [ ] Full game flow test
  - [ ] Invalid state transition tests
  - [ ] Edge case tests

**Deliverables:**
- Working game state machine
- GenServer-based state management
- Complete game flow from start to finish

**Time Estimate:** 3-4 days

---

### Phase 3: API Layer (Choose LiveView or REST)

**Option A: LiveView Implementation**

**Tasks:**
- [ ] Create `GameLive` module
  - [ ] Mount function with game initialization
  - [ ] Event handlers: `roll_dice`, `freeze_die`, `score_category`, `new_game`
  - [ ] State management in LiveView process
- [ ] Router configuration
  - [ ] Add `/game` LiveView route
  - [ ] Configure WebSocket endpoint
- [ ] Integration tests
  - [ ] LiveView mount test
  - [ ] Event handler tests
  - [ ] State update tests

**Option B: REST API Implementation**

**Tasks:**
- [ ] Create `GameController`
  - [ ] `create` - POST /api/games
  - [ ] `show` - GET /api/games/:id
  - [ ] `roll` - POST /api/games/:id/roll
  - [ ] `freeze_die` - PUT /api/games/:id/dice/:index/freeze
  - [ ] `score` - POST /api/games/:id/score
- [ ] JSON views for game state serialization
- [ ] Session or token-based game identification
- [ ] API tests for all endpoints

**Deliverables:**
- Functional API (LiveView or REST)
- Integration tests passing
- API documentation

**Time Estimate:** 2-3 days

---

### Phase 4: Frontend UI

**Goal:** Build interactive, responsive user interface.

**Tasks:**
- [ ] Design and implement Dice Component
  - [ ] Visual dice representation (dot patterns or numbers)
  - [ ] Click to freeze/unfreeze
  - [ ] Frozen state indicator
  - [ ] CSS animations for rolling
- [ ] Design and implement Scorecard Component
  - [ ] All 13 categories displayed
  - [ ] Show filled vs. available categories
  - [ ] Display potential scores
  - [ ] Click to score functionality
  - [ ] Upper bonus progress indicator
- [ ] Design and implement Game Controls
  - [ ] Roll button with disabled states
  - [ ] New game button
  - [ ] Turn and rolls remaining display
  - [ ] Game over modal/message
- [ ] Responsive layout
  - [ ] Desktop view (side-by-side layout)
  - [ ] Mobile view (stacked layout)
  - [ ] TailwindCSS styling
- [ ] Accessibility
  - [ ] Keyboard navigation
  - [ ] Screen reader support
  - [ ] ARIA labels

**Deliverables:**
- Fully functional, styled UI
- Responsive design for all screen sizes
- Accessible controls

**Time Estimate:** 4-5 days

---

### Phase 5: Polish & Optional Features

**Goal:** Enhance user experience and add advanced features.

**Tasks:**
- [ ] **Animations & Transitions**
  - [ ] Dice roll animation (spinning/tumbling)
  - [ ] Score update transitions
  - [ ] Turn advancement feedback
- [ ] **Multiplayer Support** (optional)
  - [ ] Multiple players per game
  - [ ] Turn-based gameplay
  - [ ] Player scores display
  - [ ] PubSub for real-time updates
- [ ] **Game History** (optional)
  - [ ] Save completed games to database
  - [ ] View past games
  - [ ] Replay functionality
- [ ] **Statistics & Analytics** (optional)
  - [ ] Track average scores
  - [ ] Best/worst categories
  - [ ] Win streaks
  - [ ] Charts and visualizations
- [ ] **Leaderboards** (optional)
  - [ ] High scores table
  - [ ] Daily/weekly/all-time rankings
  - [ ] Player profiles
- [ ] **Database Persistence**
  - [ ] Implement Ecto schemas
  - [ ] Run migrations
  - [ ] Integrate with GameServer
  - [ ] Auto-save game state

**Deliverables:**
- Polished, production-ready application
- Optional features as time permits

**Time Estimate:** 5-7 days (varies by features chosen)

---

### Summary Timeline

| Phase | Duration | Cumulative |
|-------|----------|-----------|
| Phase 1: Core Logic | 2-3 days | 2-3 days |
| Phase 2: Game Context | 3-4 days | 5-7 days |
| Phase 3: API Layer | 2-3 days | 7-10 days |
| Phase 4: Frontend UI | 4-5 days | 11-15 days |
| Phase 5: Polish | 5-7 days | 16-22 days |

**Total Estimated Time:** 3-4 weeks for full implementation

---

## 11. Technical Considerations

### Elixir/OTP Best Practices

**Immutability:**
- All game state transformations return new structs
- Never mutate state in place
- Use pattern matching for state updates

```elixir
# Good: Returns new struct
def roll_dice(%Game{} = game) do
  new_dice = Dice.roll(game.dice)
  {:ok, %{game | dice: new_dice, rolls_remaining: game.rolls_remaining - 1}}
end

# Bad: Attempts mutation (won't work in Elixir)
def roll_dice(game) do
  game.dice = Dice.roll(game.dice)  # Compilation error
  game
end
```

**Error Handling:**
- Use tagged tuples `{:ok, value}` and `{:error, reason}`
- Let it crash for unexpected errors
- Validate inputs at boundaries (controllers, LiveView events)

**Supervision Trees:**
- Supervise GameServer processes with DynamicSupervisor
- Use `:one_for_one` strategy (one process crash doesn't affect others)
- Implement init callbacks to restore state from DB on crash

**Example Supervision Tree:**
```elixir
defmodule Ytz.Application do
  use Application
  
  def start(_type, _args) do
    children = [
      Ytz.Repo,
      YtzWeb.Telemetry,
      {Phoenix.PubSub, name: Ytz.PubSub},
      {Registry, keys: :unique, name: Ytz.GameRegistry},
      {DynamicSupervisor, name: Ytz.GameSupervisor, strategy: :one_for_one},
      YtzWeb.Endpoint
    ]
    
    opts = [strategy: :one_for_one, name: Ytz.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

### Process Design

**One Process Per Game:**
- Each active game runs in its own GenServer
- Isolated state (crash doesn't affect other games)
- Natural concurrency model
- Garbage collected when game ends

**Process Lifecycle:**
```
User starts game
    ↓
Create GameServer process (DynamicSupervisor)
    ↓
Register in Registry with game_id
    ↓
User plays (multiple events)
    ↓
Game ends or timeout
    ↓
Persist final state to DB
    ↓
Stop GameServer process (cleanup)
```

**Timeout Handling:**
```elixir
defmodule Ytz.GameServer do
  use GenServer
  
  @idle_timeout :timer.hours(1)
  
  def init(game_id) do
    game = load_or_create_game(game_id)
    {:ok, game, @idle_timeout}
  end
  
  def handle_info(:timeout, game) do
    # Save game before stopping due to inactivity
    Ytz.Games.save_game(game)
    {:stop, :normal, game}
  end
end
```

### Scalability Considerations

**Single Server:**
- ETS/GenServer registry handles thousands of concurrent games
- Each game is lightweight (few KB of memory)
- Elixir's BEAM VM excels at this workload

**Multi-Server (Future):**
- Use distributed Erlang or Phoenix Presence
- Sticky sessions to route players to same server
- Database as source of truth for game state
- Consider Redis/Memcached for shared session store

**Performance Optimization:**
- Cache scoring calculations (memoization)
- Use StreamData for exhaustive test coverage
- Profile with `:observer` and Telemetry
- Batch database writes (write-behind pattern)

### Security Considerations

**Input Validation:**
```elixir
def freeze_die(%Game{} = game, die_index) when is_integer(die_index) and die_index in 0..4 do
  # Safe to proceed
end

def freeze_die(_game, _invalid_index) do
  {:error, "Invalid die index"}
end
```

**CSRF Protection:**
- Phoenix LiveView includes automatic CSRF protection
- REST API should use CSRF tokens for state-changing operations

**SQL Injection:**
- Ecto parameterizes queries automatically
- Always use changesets for user input

**Game State Integrity:**
- Never trust client-calculated scores
- Always recalculate scores on server
- Validate all state transitions server-side

---

## 12. Code Examples

Below are skeleton implementations for key modules to guide development.

### Dice Module (`lib/ytz/game/dice.ex`)

```elixir
defmodule Ytz.Game.Dice do
  @moduledoc """
  Manages the collection of 5 dice for Yahtzee gameplay.
  Each die has a value (1-6) and a frozen state.
  """
  
  defstruct dice: []
  
  @type die :: %{value: 1..6, frozen: boolean()}
  @type t :: %__MODULE__{dice: [die()]}
  
  @doc """
  Creates a new set of 5 dice with random initial values.
  """
  @spec new() :: t()
  def new do
    dice = for _ <- 1..5, do: %{value: :rand.uniform(6), frozen: false}
    %__MODULE__{dice: dice}
  end
  
  @doc """
  Rolls all unfrozen dice, generating new random values.
  Frozen dice retain their current values.
  """
  @spec roll(t()) :: t()
  def roll(%__MODULE__{dice: dice} = struct) do
    new_dice = Enum.map(dice, fn die ->
      if die.frozen do
        die
      else
        %{die | value: :rand.uniform(6)}
      end
    end)
    
    %{struct | dice: new_dice}
  end
  
  @doc """
  Freezes the die at the given index (0-4).
  Returns {:ok, updated_dice} or {:error, reason}.
  """
  @spec freeze(t(), non_neg_integer()) :: {:ok, t()} | {:error, String.t()}
  def freeze(%__MODULE__{dice: dice} = struct, index) when index in 0..4 do
    updated_dice = List.update_at(dice, index, &Map.put(&1, :frozen, true))
    {:ok, %{struct | dice: updated_dice}}
  end
  
  def freeze(_struct, _index), do: {:error, "Invalid die index"}
  
  @doc """
  Unfreezes the die at the given index (0-4).
  """
  @spec unfreeze(t(), non_neg_integer()) :: {:ok, t()} | {:error, String.t()}
  def unfreeze(%__MODULE__{dice: dice} = struct, index) when index in 0..4 do
    updated_dice = List.update_at(dice, index, &Map.put(&1, :frozen, false))
    {:ok, %{struct | dice: updated_dice}}
  end
  
  def unfreeze(_struct, _index), do: {:error, "Invalid die index"}
  
  @doc """
  Unfreezes all dice. Called at the start of each turn.
  """
  @spec unfreeze_all(t()) :: t()
  def unfreeze_all(%__MODULE__{dice: dice} = struct) do
    updated_dice = Enum.map(dice, &Map.put(&1, :frozen, false))
    %{struct | dice: updated_dice}
  end
  
  @doc """
  Returns a list of current die values [1..6].
  """
  @spec values(t()) :: [1..6]
  def values(%__MODULE__{dice: dice}) do
    Enum.map(dice, & &1.value)
  end
  
  @doc """
  Returns the die at the given index.
  """
  @spec get_die(t(), non_neg_integer()) :: die() | nil
  def get_die(%__MODULE__{dice: dice}, index) when index in 0..4 do
    Enum.at(dice, index)
  end
  
  def get_die(_struct, _index), do: nil
end
```

### Scoring Module (`lib/ytz/game/scoring.ex`)

```elixir
defmodule Ytz.Game.Scoring do
  @moduledoc """
  Calculates scores for all Yahtzee categories given a set of dice values.
  """
  
  @full_house_score 25
  @small_straight_score 30
  @large_straight_score 40
  @yahtzee_score 50
  
  @doc """
  Calculates the score for a given category and dice values.
  """
  @spec calculate_score([1..6], String.t()) :: non_neg_integer()
  def calculate_score(dice_values, category) when is_list(dice_values) and length(dice_values) == 5 do
    case category do
      "ones" -> sum_matching(dice_values, 1)
      "twos" -> sum_matching(dice_values, 2)
      "threes" -> sum_matching(dice_values, 3)
      "fours" -> sum_matching(dice_values, 4)
      "fives" -> sum_matching(dice_values, 5)
      "sixes" -> sum_matching(dice_values, 6)
      "three_of_a_kind" -> calculate_n_of_kind(dice_values, 3)
      "four_of_a_kind" -> calculate_n_of_kind(dice_values, 4)
      "full_house" -> calculate_full_house(dice_values)
      "small_straight" -> calculate_small_straight(dice_values)
      "large_straight" -> calculate_large_straight(dice_values)
      "yahtzee" -> calculate_yahtzee(dice_values)
      "chance" -> Enum.sum(dice_values)
      _ -> 0
    end
  end
  
  # Private helper functions
  
  defp sum_matching(dice_values, target) do
    dice_values
    |> Enum.filter(&(&1 == target))
    |> Enum.sum()
  end
  
  defp calculate_n_of_kind(dice_values, n) do
    frequencies = Enum.frequencies(dice_values)
    
    if Enum.any?(frequencies, fn {_value, count} -> count >= n end) do
      Enum.sum(dice_values)
    else
      0
    end
  end
  
  defp calculate_full_house(dice_values) do
    frequencies = Enum.frequencies(dice_values)
    counts = Map.values(frequencies) |> Enum.sort()
    
    if counts == [2, 3] do
      @full_house_score
    else
      0
    end
  end
  
  defp calculate_small_straight(dice_values) do
    unique_sorted = dice_values |> Enum.uniq() |> Enum.sort()
    
    sequences = [
      [1, 2, 3, 4],
      [2, 3, 4, 5],
      [3, 4, 5, 6]
    ]
    
    if Enum.any?(sequences, &sequence_present?(unique_sorted, &1)) do
      @small_straight_score
    else
      0
    end
  end
  
  defp calculate_large_straight(dice_values) do
    sorted = Enum.sort(dice_values)
    
    if sorted == [1, 2, 3, 4, 5] or sorted == [2, 3, 4, 5, 6] do
      @large_straight_score
    else
      0
    end
  end
  
  defp calculate_yahtzee(dice_values) do
    if Enum.uniq(dice_values) |> length() == 1 do
      @yahtzee_score
    else
      0
    end
  end
  
  defp sequence_present?(dice, sequence) do
    Enum.all?(sequence, &(&1 in dice))
  end
end
```

### Scorecard Module (`lib/ytz/game/scorecard.ex`)

```elixir
defmodule Ytz.Game.Scorecard do
  @moduledoc """
  Tracks scores for all 13 Yahtzee categories and calculates totals.
  """
  
  defstruct [
    # Upper Section
    ones: nil,
    twos: nil,
    threes: nil,
    fours: nil,
    fives: nil,
    sixes: nil,
    
    # Lower Section
    three_of_a_kind: nil,
    four_of_a_kind: nil,
    full_house: nil,
    small_straight: nil,
    large_straight: nil,
    yahtzee: nil,
    chance: nil
  ]
  
  @type t :: %__MODULE__{
    ones: nil | non_neg_integer(),
    twos: nil | non_neg_integer(),
    threes: nil | non_neg_integer(),
    fours: nil | non_neg_integer(),
    fives: nil | non_neg_integer(),
    sixes: nil | non_neg_integer(),
    three_of_a_kind: nil | non_neg_integer(),
    four_of_a_kind: nil | non_neg_integer(),
    full_house: nil | non_neg_integer(),
    small_straight: nil | non_neg_integer(),
    large_straight: nil | non_neg_integer(),
    yahtzee: nil | non_neg_integer(),
    chance: nil | non_neg_integer()
  }
  
  @categories [
    "ones", "twos", "threes", "fours", "fives", "sixes",
    "three_of_a_kind", "four_of_a_kind", "full_house",
    "small_straight", "large_straight", "yahtzee", "chance"
  ]
  
  @doc """
  Creates a new empty scorecard.
  """
  @spec new() :: t()
  def new, do: %__MODULE__{}
  
  @doc """
  Records a score for the given category.
  Returns {:ok, updated_scorecard} or {:error, reason}.
  """
  @spec score_category(t(), String.t(), non_neg_integer()) :: {:ok, t()} | {:error, String.t()}
  def score_category(scorecard, category, score) when category in @categories do
    if category_filled?(scorecard, category) do
      {:error, "Category '#{category}' already scored"}
    else
      category_atom = String.to_atom(category)
      updated = Map.put(scorecard, category_atom, score)
      {:ok, updated}
    end
  end
  
  def score_category(_scorecard, category, _score) do
    {:error, "Invalid category: #{category}"}
  end
  
  @doc """
  Checks if a category has been scored.
  """
  @spec category_filled?(t(), String.t()) :: boolean()
  def category_filled?(scorecard, category) when category in @categories do
    category_atom = String.to_atom(category)
    Map.get(scorecard, category_atom) != nil
  end
  
  def category_filled?(_scorecard, _category), do: false
  
  @doc """
  Returns list of categories that haven't been scored yet.
  """
  @spec available_categories(t()) :: [String.t()]
  def available_categories(scorecard) do
    Enum.filter(@categories, &(!category_filled?(scorecard, &1)))
  end
  
  @doc """
  Calculates the sum of the upper section (ones through sixes).
  """
  @spec upper_section_total(t()) :: non_neg_integer()
  def upper_section_total(scorecard) do
    [
      scorecard.ones,
      scorecard.twos,
      scorecard.threes,
      scorecard.fours,
      scorecard.fives,
      scorecard.sixes
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.sum()
  end
  
  @doc """
  Calculates the upper section bonus (35 if upper total >= 63, else 0).
  """
  @spec calculate_upper_bonus(t()) :: 0 | 35
  def calculate_upper_bonus(scorecard) do
    if upper_section_total(scorecard) >= 63, do: 35, else: 0
  end
  
  @doc """
  Calculates the sum of the lower section.
  """
  @spec lower_section_total(t()) :: non_neg_integer()
  def lower_section_total(scorecard) do
    [
      scorecard.three_of_a_kind,
      scorecard.four_of_a_kind,
      scorecard.full_house,
      scorecard.small_straight,
      scorecard.large_straight,
      scorecard.yahtzee,
      scorecard.chance
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.sum()
  end
  
  @doc """
  Calculates the total score including upper section bonus.
  """
  @spec total_score(t()) :: non_neg_integer()
  def total_score(scorecard) do
    upper_section_total(scorecard) +
      calculate_upper_bonus(scorecard) +
      lower_section_total(scorecard)
  end
end
```

### Game Context Module (`lib/ytz/game.ex`)

```elixir
defmodule Ytz.Game do
  @moduledoc """
  Orchestrates Yahtzee game flow, managing state transitions and rule enforcement.
  """
  
  alias Ytz.Game.{Dice, Scorecard, Scoring}
  
  defstruct [
    :id,
    :dice,
    :scorecard,
    :turn,
    :rolls_remaining,
    :game_over,
    :started_at,
    :updated_at
  ]
  
  @type t :: %__MODULE__{
    id: String.t(),
    dice: Dice.t(),
    scorecard: Scorecard.t(),
    turn: 1..13,
    rolls_remaining: 0..3,
    game_over: boolean(),
    started_at: DateTime.t(),
    updated_at: DateTime.t()
  }
  
  @max_rolls 3
  @max_turns 13
  
  @doc """
  Creates a new game with initial state.
  """
  @spec new() :: t()
  def new do
    now = DateTime.utc_now()
    
    %__MODULE__{
      id: generate_id(),
      dice: Dice.new(),
      scorecard: Scorecard.new(),
      turn: 1,
      rolls_remaining: @max_rolls,
      game_over: false,
      started_at: now,
      updated_at: now
    }
  end
  
  @doc """
  Rolls all unfrozen dice, decrements rolls_remaining.
  """
  @spec roll_dice(t()) :: {:ok, t()} | {:error, String.t()}
  def roll_dice(%__MODULE__{game_over: true}), do: {:error, "Game is over"}
  def roll_dice(%__MODULE__{rolls_remaining: 0}), do: {:error, "No rolls remaining"}
  
  def roll_dice(%__MODULE__{} = game) do
    new_dice = Dice.roll(game.dice)
    
    updated_game = %{game |
      dice: new_dice,
      rolls_remaining: game.rolls_remaining - 1,
      updated_at: DateTime.utc_now()
    }
    
    {:ok, updated_game}
  end
  
  @doc """
  Freezes a die at the given index.
  """
  @spec freeze_die(t(), non_neg_integer()) :: {:ok, t()} | {:error, String.t()}
  def freeze_die(%__MODULE__{rolls_remaining: @max_rolls}, _index) do
    {:error, "Must roll before freezing dice"}
  end
  
  def freeze_die(%__MODULE__{} = game, index) do
    case Dice.freeze(game.dice, index) do
      {:ok, new_dice} ->
        {:ok, %{game | dice: new_dice, updated_at: DateTime.utc_now()}}
      {:error, reason} ->
        {:error, reason}
    end
  end
  
  @doc """
  Unfreezes a die at the given index.
  """
  @spec unfreeze_die(t(), non_neg_integer()) :: {:ok, t()} | {:error, String.t()}
  def unfreeze_die(%__MODULE__{} = game, index) do
    case Dice.unfreeze(game.dice, index) do
      {:ok, new_dice} ->
        {:ok, %{game | dice: new_dice, updated_at: DateTime.utc_now()}}
      {:error, reason} ->
        {:error, reason}
    end
  end
  
  @doc """
  Scores the given category and advances to the next turn.
  """
  @spec score_category(t(), String.t(), non_neg_integer()) :: {:ok, t()} | {:error, String.t()}
  def score_category(%__MODULE__{game_over: true}, _category, _score) do
    {:error, "Game is over"}
  end
  
  def score_category(%__MODULE__{rolls_remaining: @max_rolls}, _category, _score) do
    {:error, "Must roll at least once before scoring"}
  end
  
  def score_category(%__MODULE__{} = game, category, score) do
    case Scorecard.score_category(game.scorecard, category, score) do
      {:ok, new_scorecard} ->
        next_turn = game.turn + 1
        game_over = next_turn > @max_turns
        
        updated_game = %{game |
          scorecard: new_scorecard,
          turn: next_turn,
          rolls_remaining: @max_rolls,
          dice: Dice.unfreeze_all(game.dice),
          game_over: game_over,
          updated_at: DateTime.utc_now()
        }
        
        {:ok, updated_game}
        
      {:error, reason} ->
        {:error, reason}
    end
  end
  
  @doc """
  Calculates the potential score for a category given current dice.
  """
  @spec calculate_score_for_category(t(), String.t()) :: non_neg_integer()
  def calculate_score_for_category(%__MODULE__{} = game, category) do
    dice_values = Dice.values(game.dice)
    Scoring.calculate_score(dice_values, category)
  end
  
  @doc """
  Returns list of categories that can still be scored.
  """
  @spec available_categories(t()) :: [String.t()]
  def available_categories(%__MODULE__{} = game) do
    Scorecard.available_categories(game.scorecard)
  end
  
  # Private helpers
  
  defp generate_id do
    :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)
  end
end
```

---

## 13. Additional Resources

### Documentation References

- **Phoenix Framework:** https://hexdocs.pm/phoenix/
- **Phoenix LiveView:** https://hexdocs.pm/phoenix_live_view/
- **Ecto:** https://hexdocs.pm/ecto/
- **ExUnit:** https://hexdocs.pm/ex_unit/
- **StreamData:** https://hexdocs.pm/stream_data/

### Learning Resources

- **Elixir Getting Started:** https://elixir-lang.org/getting-started/
- **Phoenix LiveView Book:** https://pragprog.com/titles/liveview/programming-phoenix-liveview/
- **OTP Concepts:** https://elixir-lang.org/getting-started/mix-otp/

### Community

- **Elixir Forum:** https://elixirforum.com/
- **Elixir Slack:** https://elixir-slackin.herokuapp.com/
- **Phoenix Discord:** https://discord.gg/elixir

---

## 14. Conclusion

This document provides a comprehensive blueprint for implementing Yahtzee in Elixir with Phoenix. The architecture leverages Elixir's strengths—immutability, pattern matching, OTP supervision—while Phoenix LiveView enables rich, real-time user experiences with minimal JavaScript.

### Key Takeaways

1. **Pure Game Logic:** Core game rules are implemented in pure Elixir modules (Dice, Scoring, Scorecard) that are easy to test and reason about.

2. **State Management:** GenServer-based architecture provides robust state management with fault tolerance and supervision.

3. **Two API Options:** LiveView (recommended) for integrated real-time UI, or REST API for maximum frontend flexibility.

4. **Incremental Development:** The 5-phase roadmap breaks implementation into manageable, testable chunks.

5. **Production-Ready:** Consideration of testing, persistence, scalability, and security ensures the implementation is suitable for production deployment.

### Next Steps

1. **Choose API approach:** LiveView (recommended for this project) or REST
2. **Start with Phase 1:** Implement core game logic with comprehensive tests
3. **Iterate through phases:** Build incrementally, testing at each stage
4. **Deploy early:** Get feedback on UX and gameplay
5. **Iterate and enhance:** Add optional features based on user feedback

This plan should serve as a living document—update it as implementation reveals new insights or requirements. Good luck building your Yahtzee game!

---

**Document Version:** 1.0  
**Last Updated:** December 18, 2025  
**Maintainer:** Ytz Development Team
