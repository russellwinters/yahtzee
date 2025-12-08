# Dice Representation Decision

This document lists action items and concrete examples for two ways to represent the five dice in the `actix` crate, with pros/cons and migration steps. You indicated you're leaning toward the fixed-array approach (`[Die; 5]`). The goal is to make it easy to interact with multiple dice (lock/unlock, iterate, and compute score tallies).

**Decision Context (short)**
- Current `Dice` uses named fields: `first`, `second`, `third`, `fourth`, `fifth`.
- `Die` already exposes mutable lock/unlock methods (`fn lock(&mut self) -> &mut Die`).
- We want an ergonomic API to: lock/unlock individual dice by index, operate on multiple dice at once, iterate (mutable and immutable), and produce values for scoring.

**Options**

## Option A: Keep Named Fields (Minimal Change)

- Representation:

```rust
pub struct Dice {
    first: Die,
    second: Die,
    third: Die,
    fourth: Die,
    fifth: Die,
}
```

- API additions (suggested):
  - `pub fn iter_mut(&mut self) -> Vec<&mut Die>`
  - `pub fn get_mut(&mut self, idx: usize) -> Option<&mut Die>`
  - `pub fn freeze(&mut self, idx: usize) -> Result<(), String>` (calls `lock()` on found die)
  - `pub fn unfreeze(&mut self, idx: usize) -> Result<(), String>`
  - `pub fn freeze_multiple(&mut self, indices: &[usize])` convenience helper

- Example implementations:

```rust
pub fn iter_mut(&mut self) -> Vec<&mut Die> {
    vec![
        &mut self.first,
        &mut self.second,
        &mut self.third,
        &mut self.fourth,
        &mut self.fifth,
    ]
}

pub fn get_mut(&mut self, idx: usize) -> Option<&mut Die> {
    match idx {
        0 => Some(&mut self.first),
        1 => Some(&mut self.second),
        2 => Some(&mut self.third),
        3 => Some(&mut self.fourth),
        4 => Some(&mut self.fifth),
        _ => None,
    }
}

pub fn freeze(&mut self, idx: usize) -> Result<(), String> {
    match self.get_mut(idx) {
        Some(d) => { d.lock(); Ok(()) }
        None => Err(format!("invalid index {}", idx)),
    }
}
```

- Pros:
  - Minimal code changes; quick to implement.
  - Existing call sites that reference named fields remain valid.
  - Explicit field names are clear in small codebases.

- Cons:
  - Boilerplate for indexing (the `match` clause)
  - Iteration requires assembling a `Vec<&mut Die>` rather than using `array.iter_mut()` which is more ergonomic.
  - Harder to generalize if you later want N dice instead of exactly 5.

- Effort estimate: small (15–30 minutes to implement and test).

## Option B: Use Fixed-Size Array `[Die; 5]` (Recommended)

- Representation:

```rust
pub struct Dice {
    dies: [Die; 5],
}
```

- API additions / replacements:
  - `pub fn new() -> Self { Self { dies: [Die::new(), Die::new(), Die::new(), Die::new(), Die::new()] } }`
  - `pub fn iter(&self) -> impl Iterator<Item=&Die> { self.dies.iter() }`
  - `pub fn iter_mut(&mut self) -> impl Iterator<Item=&mut Die> { self.dies.iter_mut() }`
  - `pub fn get_mut(&mut self, idx: usize) -> Option<&mut Die> { self.dies.get_mut(idx) }`
  - `pub fn freeze(&mut self, idx: usize) -> Option<&mut Die> { self.dies.get_mut(idx).map(|d| d.lock()) }`
  - `pub fn freeze_multiple(&mut self, indices: &[usize])` can use iterator utilities

- Example:

```rust
pub fn freeze(&mut self, idx: usize) -> Option<&mut Die> {
    self.dies.get_mut(idx).map(|d| d.lock())
}

pub fn roll(&mut self) {
    for die in self.dies.iter_mut() {
        die.roll();
    }
}
```

- Pros:
  - Idiomatic Rust: easy iteration, indexing, mapping, borrowing.
  - Cleaner implementation for batch operations and functional-style helpers (map/filter)
  - Easier to extend to variable size later if you switch to `Vec<Die>`
  - Less boilerplate and fewer match arms
  - Simplifies scoring helpers that operate on a slice of values

- Cons:
  - Must update call sites using `.first/.second/.third` etc.
  - Small, localized refactor across repo (search/replace or manual edits)

- Effort estimate: moderate (30–60 minutes) depending on number of call sites.

**Why this is recommended:** your key decision point is making it easy to interact with multiple dice at once (lock/unlock, tally scores). The fixed-array approach makes iteration, indexing, and borrow-checker-safe mutable access straightforward and minimizes ad-hoc glue code.


## Migration Steps (If choosing Option B — refactor to `[Die; 5]`)

1. Replace `Dice` struct fields with `dies: [Die; 5]` and update `new()` and `roll()` to use `dies`.

2. Add convenience accessors (public or pub(crate) depending on needs):
   - `iter()`, `iter_mut()`, `get()`, `get_mut()`, `freeze()`, `unfreeze()`.

3. Update all call sites referencing `.first`, `.second`, etc. Search the repo for these field names and replace with appropriate `get()` or indexing (`dice.get_mut(i)` or `dice.dies[i]` if within same module).

4. Run `cargo build` and fix compiler errors. Typical small fixes:
   - Replace `dice.first.roll()` with `dice.dies[0].roll()` or `dice.get_mut(0).unwrap().roll()`
   - Replace patterns that relied on named fields in pattern matching or destructuring.

5. Add unit tests to confirm freeze/unfreeze and iteration behavior.

6. Update any serialization / debug code if you were deriving traits that depend on field names.


## API Design Recommendations (Regardless of choice)

- Expose both immutable and mutable iteration methods:
  - `pub fn iter(&self) -> impl Iterator<Item=&Die>`
  - `pub fn iter_mut(&mut self) -> impl Iterator<Item=&mut Die>`

- Provide safe indexed accessors that return `Option<&mut Die>` rather than panicking:
  - `pub fn get_mut(&mut self, idx: usize) -> Option<&mut Die>`

- Provide ergonomics for common operations:
  - `pub fn freeze(&mut self, idx: usize) -> Result<(), Error>`
  - `pub fn freeze_multiple(&mut self, indices: &[usize]) -> Result<(), Error>`
  - `pub fn unfreeze_all(&mut self)`

- For scoring: expose a simple value extractor:
  - `pub fn values(&self) -> [u8; 5]` or `pub fn values_vec(&self) -> Vec<u8>` so `Game` scoring helpers can operate on `&[u8]` easily.


## Tests to Add

- Unit tests for `Dice`:
  - Freeze/unfreeze single die by valid index
  - Freeze/unfreeze with invalid index returns error
  - `roll()` respects frozen dice and changes unfrozen dice
  - `freeze_multiple()` with several combinations
  - `iter_mut()` allows changing each die value
  - `values()` returns correct slice/array of die face values

- Integration tests for `Game`:
  - Start turn -> roll -> freeze one or more -> roll again -> score category
  - Ensure score calculation uses current values


## Estimated Timeline

- Document & choose approach: done (this doc)
- Implement minimal `get_mut` + `iter_mut` + `freeze` (Option A): ~15–30 minutes
- Refactor to `[Die; 5]` (Option B): ~30–60 minutes + fixups
- Tests & CI: ~30–60 minutes depending on test coverage


## Next Steps (pick one)
- [ ] I will implement the minimal API on the existing struct (Option A) and add tests (fast).
- [ ] I will refactor `Dice` to use `[Die; 5]`, update usages, and add tests (recommended).


If you want, I can implement the chosen option now and run `cargo build`. Which option should I implement for you?