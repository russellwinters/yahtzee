
# Game module TODOs

This file summarizes outstanding TODOs discovered in the `Ytz.Game` modules (`dice.ex`, `scorecard.ex`, `scoring.ex`). Use these as a prioritized checklist when implementing features and tests.

- Implement `Scorecard.calculate_score/3`, considering what that should really be called.

- Add module documentation (`@moduledoc`) for `Ytz.Game.Dice` after implementation.

- Implement `Scorecard.category_filled?/2` and corresponding tests; use this helper to simplify `calculate_score/3` logic.

- Move `Scorecard.calculate_score/2` to the `Scoring` module (including tests)

- Implement scorecard aggregation helpers and tests: `upper_total/1`, `upper_bonus/1` (bonus 35 or 0 based on upper total), `lower_total/1`, and `total_score/1`.
