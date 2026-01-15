
# Game module TODOs

This file summarizes outstanding TODOs discovered in the `Ytz.Game` modules (`dice.ex`, `scorecard.ex`, `scoring.ex`). Use these as a prioritized checklist when implementing features and tests.

- Add `extract_values/1` in `Ytz.Game.Dice`: implement a function that accepts a `Dice` struct (or the dice list) and returns a plain list of integer values for the five dice.

- Add an overloaded `freeze/2` in `Ytz.Game.Dice` that accepts a list of indices and freezes multiple dice at once (in addition to the existing single-index version).

- Add module documentation (`@moduledoc`) for `Ytz.Game.Dice` after implementation.

- Implement `Scorecard.category_filled?/2` and corresponding tests; use this helper to simplify `calculate_score/3` logic.

- Move `Scorecard.calculate_score/2` to the `Scoring` module (including tests)

- Implement scorecard aggregation helpers and tests: `upper_total/1`, `upper_bonus/1` (bonus 35 or 0 based on upper total), `lower_total/1`, and `total_score/1`.
