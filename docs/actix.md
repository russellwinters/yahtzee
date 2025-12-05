# Actix Yahtzee Implementation Plan

This document tracks and expands upon TODO items found in the actix implementation of Yahtzee.

## Overview

The actix Yahtzee implementation is a Rust-based web application using the Actix Web framework. The core game logic is partially implemented, with several key features requiring completion.

---

## TODO Items

### 1. Die Freeze/Unfreeze Functionality

**Location:** `actix/src/lib/die.rs:9`

**Original TODO:**
```rust
// TODO: implement freeze and unfreeze fn, which will preserve the current value on roll
```

**Current State:**
- The `Die` struct has a tuple `value: (u8, bool)` where the boolean represents frozen state
- The `lock()` and `unlock()` methods already exist and set the frozen flag
- The `roll()` method checks the frozen state and returns early if frozen

**Status:** ✅ **COMPLETE**

The freeze/unfreeze functionality is already implemented through the `lock()` and `unlock()` methods. The TODO comment is outdated and can be removed.

**Action Items:**
- [ ] Remove the outdated TODO comment
- [ ] Consider renaming `lock()`/`unlock()` to `freeze()`/`unfreeze()` for clarity if preferred
- [ ] Add unit tests for freeze/unfreeze behavior

**Related Issue:**
Note that `actix/src/lib/scorecard.rs` has two critical bugs in the existing `score_upper` method (lines 38-96):

1. **Wrong value added**: Line 44 uses `total += 1` instead of `total += die.val() as u16`, so it counts matching dice instead of summing their face values
2. **Assignment inside loop**: Line 45 sets `self.ones = Some(total)` inside the loop, overwriting the value on each iteration

For example, if dice show `[1,1,1,3,4]`, scoring "ones":
- Current buggy behavior: Adds 1 three times (total becomes 3) but overwrites `self.ones` each time, potentially resulting in `Some(1)`, `Some(2)`, or `Some(3)` depending on execution
- Expected behavior: Should sum the face values (1+1+1=3) and set `self.ones = Some(3)` once after the loop

The corrected logic should be:
```rust
"ones" => {
    let total: u16 = dice.iter()
        .filter(|die| die.val() == 1)
        .map(|die| die.val() as u16)  // Sum face values, not count
        .sum();
    self.ones = Some(total);  // Set once after accumulation
}
```

This bug affects all six upper section categories (ones through sixes) and should be fixed before implementing the full game logic.

---

### 2. Dice Collection Freeze Functionality

**Location:** `actix/src/lib/dice.rs:12`

**Original TODO:**
```rust
// TODO: Implement freeze fn, which will take an index and freeze that die in the iter()
```

**Current State:**
- The `Dice` struct contains five individual `Die` instances
- Individual dice can be frozen via `Die::lock()`, but there's no method at the `Dice` level
- No mechanism to freeze specific dice by index

**Analysis:**
The `Dice` struct needs a method to freeze/unfreeze individual dice by index. This is crucial for Yahtzee gameplay where players can choose which dice to keep between rolls.

**Action Plan:**

#### Step 1: Add Index-Based Access
Add methods to access individual dice by index:
```rust
pub fn get_die_mut(&mut self, index: usize) -> Option<&mut Die> {
    match index {
        0 => Some(&mut self.first),
        1 => Some(&mut self.second),
        2 => Some(&mut self.third),
        3 => Some(&mut self.fourth),
        4 => Some(&mut self.fifth),
        _ => None,
    }
}
```

#### Step 2: Implement Freeze by Index
Add method to freeze a specific die:
```rust
pub fn freeze(&mut self, index: usize) -> Result<(), String> {
    match self.get_die_mut(index) {
        Some(die) => {
            die.lock();
            Ok(())
        }
        None => Err(format!("Invalid die index: {}", index)),
    }
}
```

#### Step 3: Implement Unfreeze by Index
Add method to unfreeze a specific die:
```rust
pub fn unfreeze(&mut self, index: usize) -> Result<(), String> {
    match self.get_die_mut(index) {
        Some(die) => {
            die.unlock();
            Ok(())
        }
        None => Err(format!("Invalid die index: {}", index)),
    }
}
```

#### Step 4: Batch Operations
Add convenience methods for batch freeze/unfreeze:
```rust
pub fn freeze_multiple(&mut self, indices: &[usize]) -> Result<(), String> {
    for &index in indices {
        self.freeze(index)?;
    }
    Ok(())
}

pub fn unfreeze_all(&mut self) {
    self.first.unlock();
    self.second.unlock();
    self.third.unlock();
    self.fourth.unlock();
    self.fifth.unlock();
}
```

#### Step 5: Update Roll Method
Ensure the `roll()` method respects frozen dice (it already does via `Die::roll()`):
- No changes needed; individual dice check their frozen state

**Testing Requirements:**
- [ ] Test freezing individual dice by valid index
- [ ] Test freezing with invalid index returns error
- [ ] Test frozen dice don't change value on roll
- [ ] Test unfrozen dice do change value on roll
- [ ] Test `unfreeze_all()` unfreezes all dice
- [ ] Test `freeze_multiple()` with various combinations

**Files to Modify:**
- `actix/src/lib/dice.rs`

---

### 3. Game Logic Implementation

**Location:** `actix/src/lib/game.rs:18`

**Original TODO:**
```rust
// TODO: plan out how to implement the rest of this game, with:
// - rolls
// - freeze/unfreeze
// - Tally scores
// - scratching
// - validation on each scorecard item
```

**Current State:**
- Basic `Game` struct exists with `dice`, `rolls`, and `score` fields
- No game flow logic implemented
- No turn management
- No scoring integration

**Analysis:**
This is the most complex TODO item, requiring a complete game state machine. Yahtzee has specific rules:
- 13 turns per game (one for each scorecard category)
- 3 rolls per turn maximum
- Players can choose which dice to keep between rolls
- After rolls, player must choose a category to score (or scratch)
- Game ends when all categories are filled

**Action Plan:**

#### Step 1: Enhance Game State
Add fields to track game state:
```rust
pub struct Game {
    dice: Dice,
    rolls_remaining: u8,  // NEW: Track remaining rolls in current turn
    turn: u8,             // NEW: Track which turn (1-13)
    score: Scorecard,
    game_over: bool,      // NEW: Track if game has ended
}
```

**Migration Note:** The existing `rolls` field (which tracked total rolls taken) is being replaced with `rolls_remaining` (which tracks remaining rolls in the current turn). This is a breaking change that better aligns with game logic. When implementing:
1. Remove the old `rolls: u8` field
2. Add the new fields: `rolls_remaining: u8`, `turn: u8`, and `game_over: bool`
3. Update the `new()` constructor to initialize these fields:
   ```rust
   pub fn new() -> Self {
       Self {
           dice: Dice::new(),
           rolls_remaining: consts::MAX_ROLLS,
           turn: 1,
           score: Scorecard::new(),
           game_over: false,
       }
   }
   ```


#### Step 2: Implement Turn Management
Add turn lifecycle methods:

##### Initialize New Turn
```rust
pub fn start_turn(&mut self) {
    self.rolls_remaining = consts::MAX_ROLLS;
    self.dice.unfreeze_all();
}
```

##### Roll Dice
```rust
pub fn roll(&mut self) -> Result<(), String> {
    if self.game_over {
        return Err("Game is over".to_string());
    }
    if self.rolls_remaining == 0 {
        return Err("No rolls remaining".to_string());
    }
    
    self.dice.roll();
    self.rolls_remaining -= 1;
    Ok(())
}
```

##### Freeze/Unfreeze Dice
```rust
pub fn freeze_die(&mut self, index: usize) -> Result<(), String> {
    if self.rolls_remaining == consts::MAX_ROLLS {
        return Err("Must roll before freezing dice".to_string());
    }
    self.dice.freeze(index)
}

pub fn unfreeze_die(&mut self, index: usize) -> Result<(), String> {
    self.dice.unfreeze(index)
}
```

#### Step 3: Implement Scoring
Add methods to score categories:

##### Score Category
```rust
pub fn score_category(&mut self, category: &str) -> Result<u16, String> {
    if self.game_over {
        return Err("Game is over".to_string());
    }
    if self.rolls_remaining == consts::MAX_ROLLS {
        return Err("Must roll before scoring".to_string());
    }
    
    // Calculate score for category
    let score = self.calculate_score(category)?;
    
    // Record score on scorecard
    self.score.record_score(category, score)?;
    
    // Move to next turn
    self.turn += 1;
    if self.turn > 13 {
        self.game_over = true;
    } else {
        self.start_turn();
    }
    
    Ok(score)
}
```

##### Scratch Category
```rust
pub fn scratch_category(&mut self, category: &str) -> Result<(), String> {
    if self.game_over {
        return Err("Game is over".to_string());
    }
    if self.rolls_remaining == consts::MAX_ROLLS {
        return Err("Must roll before scratching".to_string());
    }
    
    // Record zero score on scorecard
    self.score.record_score(category, 0)?;
    
    // Move to next turn
    self.turn += 1;
    if self.turn > 13 {
        self.game_over = true;
    } else {
        self.start_turn();
    }
    
    Ok(())
}
```

#### Step 4: Implement Score Calculation
Add scoring logic for each category. Note: Helper methods like `sum_matching()`, `calculate_n_of_kind()`, etc. are defined in Step 5 below. The `get_dice_values()` method is defined in Step 6.

```rust
// Private helper method for calculating scores
fn calculate_score(&self, category: &str) -> Result<u16, String> {
    // Get current dice values using public method (defined in Step 6)
    let dice_values = self.get_dice_values();
    
    match category {
        // Upper section: sum of matching face values
        // Example: three 5s scores 15 points (5+5+5), not 3
        "ones" => Ok(Self::sum_matching(&dice_values, 1)),
        "twos" => Ok(Self::sum_matching(&dice_values, 2)),
        "threes" => Ok(Self::sum_matching(&dice_values, 3)),
        "fours" => Ok(Self::sum_matching(&dice_values, 4)),
        "fives" => Ok(Self::sum_matching(&dice_values, 5)),
        "sixes" => Ok(Self::sum_matching(&dice_values, 6)),
        
        // Lower section: pattern matching
        "three_of_a_kind" => Ok(Self::calculate_n_of_kind(&dice_values, 3)),
        "four_of_a_kind" => Ok(Self::calculate_n_of_kind(&dice_values, 4)),
        "full_house" => Ok(Self::calculate_full_house(&dice_values)),
        "small_straight" => Ok(Self::calculate_small_straight(&dice_values)),
        "large_straight" => Ok(Self::calculate_large_straight(&dice_values)),
        "yahtzee" => Ok(Self::calculate_yahtzee(&dice_values)),
        "chance" => Ok(dice_values.iter().map(|&v| v as u16).sum()),
        
        _ => Err(format!("Invalid category: {}", category)),
    }
}
```

#### Step 5: Implement Helper Methods
Add scoring helper methods as associated functions on `Game`:

```rust
// Helper methods for Game impl block

// Sums the face values of all dice matching the target value
// Example: for dice [5,5,5,3,2] and target 5, returns 15 (5+5+5)
fn sum_matching(values: &[u8], target: u8) -> u16 {
    values.iter()
        .filter(|&&v| v == target)
        .map(|&v| v as u16)
        .sum()
}

fn calculate_n_of_kind(values: &[u8], n: usize) -> u16 {
    let mut counts = [0u8; 7]; // index 0 unused, 1-6 for die values
    for &val in values {
        counts[val as usize] += 1;
    }
    
    if counts.iter().any(|&count| count >= n as u8) {
        values.iter().map(|&v| v as u16).sum()
    } else {
        0
    }
}

fn calculate_full_house(values: &[u8]) -> u16 {
    let mut counts = [0u8; 7];
    for &val in values {
        counts[val as usize] += 1;
    }
    
    let has_three = counts.iter().any(|&count| count == 3);
    let has_two = counts.iter().any(|&count| count == 2);
    
    if has_three && has_two {
        25
    } else {
        0
    }
}

fn calculate_small_straight(values: &[u8]) -> u16 {
    let mut sorted = values.to_vec();
    sorted.sort();
    sorted.dedup();
    
    // Check for sequences: 1-2-3-4, 2-3-4-5, or 3-4-5-6
    let patterns = vec![
        vec![1, 2, 3, 4],
        vec![2, 3, 4, 5],
        vec![3, 4, 5, 6],
    ];
    
    for pattern in patterns {
        if pattern.iter().all(|&v| sorted.contains(&v)) {
            return 30;
        }
    }
    0
}

fn calculate_large_straight(values: &[u8]) -> u16 {
    let mut sorted = values.to_vec();
    sorted.sort();
    
    // Check for sequences: 1-2-3-4-5 or 2-3-4-5-6
    if sorted == vec![1, 2, 3, 4, 5] || sorted == vec![2, 3, 4, 5, 6] {
        40
    } else {
        0
    }
}

fn calculate_yahtzee(values: &[u8]) -> u16 {
    if values.iter().all(|&v| v == values[0]) {
        50
    } else {
        0
    }
}
```

#### Step 6: Add Query Methods
Add methods to check game state:

```rust
pub fn get_rolls_remaining(&self) -> u8 {
    self.rolls_remaining
}

pub fn get_turn(&self) -> u8 {
    self.turn
}

pub fn is_game_over(&self) -> bool {
    self.game_over
}

pub fn get_dice_values(&self) -> Vec<u8> {
    self.dice.iter().map(|die| die.val()).collect()
}

pub fn get_available_categories(&self) -> Vec<String> {
    self.score.get_available_categories()
}
```

#### Step 7: Update Scorecard
Enhance `Scorecard` to support the game flow:

```rust
// In scorecard.rs
pub fn record_score(&mut self, category: &str, score: u16) -> Result<(), String> {
    // Check if category already scored
    if self.is_category_filled(category) {
        return Err(format!("Category '{}' already scored", category));
    }
    
    // Record the score
    match category {
        "ones" => self.ones = Some(score),
        "twos" => self.twos = Some(score),
        "threes" => self.threes = Some(score),
        "fours" => self.fours = Some(score),
        "fives" => self.fives = Some(score),
        "sixes" => self.sixes = Some(score),
        "three_of_a_kind" => self.three_of_a_kind = Some(score),
        "four_of_a_kind" => self.four_of_a_kind = Some(score),
        "full_house" => self.full_house = Some(score),
        "small_straight" => self.small_straight = Some(score),
        "large_straight" => self.large_straight = Some(score),
        "yahtzee" => self.yahtzee = Some(score),
        "chance" => self.chance = Some(score),
        _ => return Err(format!("Invalid category: {}", category)),
    }
    
    Ok(())
}

pub fn is_category_filled(&self, category: &str) -> bool {
    match category {
        "ones" => self.ones.is_some(),
        "twos" => self.twos.is_some(),
        "threes" => self.threes.is_some(),
        "fours" => self.fours.is_some(),
        "fives" => self.fives.is_some(),
        "sixes" => self.sixes.is_some(),
        "three_of_a_kind" => self.three_of_a_kind.is_some(),
        "four_of_a_kind" => self.four_of_a_kind.is_some(),
        "full_house" => self.full_house.is_some(),
        "small_straight" => self.small_straight.is_some(),
        "large_straight" => self.large_straight.is_some(),
        "yahtzee" => self.yahtzee.is_some(),
        "chance" => self.chance.is_some(),
        _ => false,
    }
}

pub fn get_available_categories(&self) -> Vec<String> {
    let mut available = Vec::new();
    
    if self.ones.is_none() { available.push("ones".to_string()); }
    if self.twos.is_none() { available.push("twos".to_string()); }
    if self.threes.is_none() { available.push("threes".to_string()); }
    if self.fours.is_none() { available.push("fours".to_string()); }
    if self.fives.is_none() { available.push("fives".to_string()); }
    if self.sixes.is_none() { available.push("sixes".to_string()); }
    if self.three_of_a_kind.is_none() { available.push("three_of_a_kind".to_string()); }
    if self.four_of_a_kind.is_none() { available.push("four_of_a_kind".to_string()); }
    if self.full_house.is_none() { available.push("full_house".to_string()); }
    if self.small_straight.is_none() { available.push("small_straight".to_string()); }
    if self.large_straight.is_none() { available.push("large_straight".to_string()); }
    if self.yahtzee.is_none() { available.push("yahtzee".to_string()); }
    if self.chance.is_none() { available.push("chance".to_string()); }
    
    available
}
```

**Testing Requirements:**
- [ ] Test complete game flow from start to finish
- [ ] Test roll limits (max 3 per turn)
- [ ] Test scoring each category correctly
- [ ] Test scratching categories
- [ ] Test preventing duplicate category scoring
- [ ] Test game over after 13 turns
- [ ] Test upper section bonus (63+ points = 35 bonus)
- [ ] Test invalid state transitions
- [ ] Test edge cases (all same values, all different values, etc.)

**Files to Modify:**
- `actix/src/lib/game.rs` (major expansion)
- `actix/src/lib/scorecard.rs` (add validation and query methods)
- `actix/src/lib/consts.rs` (add scoring constants like FULL_HOUSE_SCORE = 25)

---

## Implementation Priority

1. **High Priority:** Dice freeze functionality (TODO #2)
   - Foundational for game mechanics
   - Relatively simple to implement
   - Enables testing of roll mechanics

2. **Medium Priority:** Remove outdated TODO (TODO #1)
   - Quick win
   - Improves code clarity

3. **High Priority:** Game logic implementation (TODO #3)
   - Most complex item
   - Core game functionality
   - Should be broken into multiple PRs:
     - PR 1: Turn management and rolling
     - PR 2: Scoring calculation helpers
     - PR 3: Category scoring and validation
     - PR 4: Game state queries and integration

---

## Additional Considerations

### Web API Integration
Once core game logic is complete, the following API endpoints should be implemented in `main.rs`:

- `POST /game/new` - Start a new game
- `POST /game/{id}/roll` - Roll dice
- `POST /game/{id}/freeze` - Freeze specific dice
- `POST /game/{id}/unfreeze` - Unfreeze specific dice
- `GET /game/{id}/state` - Get current game state
- `POST /game/{id}/score` - Score a category
- `POST /game/{id}/scratch` - Scratch a category

### Data Persistence
Consider adding persistence layer:
- Save/load game state
- Player profiles
- Game history
- Leaderboards

### Testing Strategy
- Unit tests for each scoring function
- Integration tests for game flow
- Property-based tests for scoring rules
- API endpoint tests

### Documentation
- Add doc comments to all public methods
- Create examples/demo in `main.rs`
- Add README in `actix/` directory explaining the implementation

---

## Notes

This implementation plan breaks down the TODO items into actionable, testable components. Each step is designed to be independently implementable and testable, allowing for incremental progress while maintaining a working codebase.

The most complex item (Game logic) is intentionally broken into multiple sub-steps that can be implemented across several PRs, making code review easier and reducing risk.
