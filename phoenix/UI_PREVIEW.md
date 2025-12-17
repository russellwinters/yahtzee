# UI Preview

This document provides a preview of what the Phoenix Yahtzee UI looks like.

## Homepage (Current Implementation)

The homepage at `http://localhost:4000` displays:

```
┌─────────────────────────────────────────────────────────┐
│                                                           │
│  Welcome to Yahtzee!                                      │
│                                                           │
│  Hello, World! This is a Phoenix LiveView application.   │
│                                                           │
│  ┌─────────────────────────────────────────────────┐    │
│  │ Health Check                                    │    │
│  │                                                 │    │
│  │ ┌────────┐                                      │    │
│  │ │  Ping  │                                      │    │
│  │ └────────┘                                      │    │
│  │                                                 │    │
│  │ Response: pong   (appears after clicking Ping) │    │
│  └─────────────────────────────────────────────────┘    │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

### Features Demonstrated

1. **Static Content**: The welcome message and description
2. **LiveView Interaction**: The Ping button demonstrates real-time server-client communication
3. **Dynamic Updates**: The pong response appears without page reload
4. **Clean Styling**: Simple, modern CSS with a card-based layout

### Technical Details

- **LiveView**: The entire page is a LiveView, enabling real-time updates
- **Event Handling**: The `phx-click="ping"` attribute connects the button to server-side event handler
- **State Management**: The `pong_message` is stored in the LiveView socket assigns
- **Rendering**: The `~H` sigil provides HTML templating with embedded Elixir

## Future UI Components

As the Yahtzee game is developed, the UI will be expanded to include:

### Game Board Layout
```
┌─────────────────────────────────────────────────────────┐
│  Yahtzee Game                                  Roll: 1/3 │
├─────────────────────────────────────────────────────────┤
│  Dice:  [ 3 ] [ 6 ] [ 2 ] [ 5 ] [ 3 ]                  │
│         [Hold] [Hold] [Hold] [Hold] [Hold]               │
│                                                           │
│  ┌──────────┐                                            │
│  │   Roll   │                                            │
│  └──────────┘                                            │
├─────────────────────────────────────────────────────────┤
│  Scorecard:                                              │
│  ┌─────────────────────────────────────────────┐        │
│  │ Upper Section           Score   Bonus       │        │
│  │ Ones                    ---                 │        │
│  │ Twos                    ---                 │        │
│  │ Threes                  6      ┌──────┐     │        │
│  │ Fours                   ---    │ 35/63│     │        │
│  │ Fives                   ---    └──────┘     │        │
│  │ Sixes                   ---                 │        │
│  └─────────────────────────────────────────────┘        │
│  ┌─────────────────────────────────────────────┐        │
│  │ Lower Section           Score               │        │
│  │ Three of a Kind         ---                 │        │
│  │ Four of a Kind          ---                 │        │
│  │ Full House              ---                 │        │
│  │ Small Straight          ---                 │        │
│  │ Large Straight          ---                 │        │
│  │ Yahtzee                 ---                 │        │
│  │ Chance                  ---                 │        │
│  └─────────────────────────────────────────────┘        │
│                                                           │
│  Total Score: 6                                          │
└─────────────────────────────────────────────────────────┘
```

### Multiplayer Lobby
```
┌─────────────────────────────────────────────────────────┐
│  Game Lobby                                              │
├─────────────────────────────────────────────────────────┤
│  Players:                                                │
│  • Player 1 (You)                    Ready ✓            │
│  • Player 2                          Ready ✓            │
│  • Waiting for player...             Empty              │
│  • Waiting for player...             Empty              │
│                                                           │
│  ┌──────────────┐  ┌──────────────┐                     │
│  │ Start Game   │  │ Invite Link  │                     │
│  └──────────────┘  └──────────────┘                     │
└─────────────────────────────────────────────────────────┘
```

## Design Philosophy

The UI follows these principles:

1. **Minimalism**: Clean, uncluttered interface focused on gameplay
2. **Responsiveness**: Works on desktop and mobile devices
3. **Real-time Updates**: LiveView enables instant feedback without page reloads
4. **Accessibility**: Semantic HTML and proper ARIA labels
5. **Visual Feedback**: Clear indication of interactive elements and state changes

## Color Scheme

Current implementation uses:
- Background: `#f5f5f5` (light gray)
- Cards: `#ffffff` (white) with subtle shadow
- Primary Action: `#4CAF50` (green)
- Text: `#333333` (dark gray) and `#666666` (medium gray)
- Success/Active: `#e8f5e9` (light green) with `#4CAF50` accent

These colors provide good contrast and are easy on the eyes during extended play sessions.
