use super::{Dice, Scorecard};

pub struct Game {
    dice: Dice,
    rolls: u8,
    score: Scorecard,
}

impl Game {
    pub fn new() -> Self {
        Self {
            dice: Dice::new(),
            rolls: 0,
            score: Scorecard::new(),
        }
    }

    // TODO: plan out how to implement the rest of this game, with:
    // - rolls
    // - freeze/unfreeze
    // - Tally scores
    // - scratching
    // - validation on each scorecard item
}
