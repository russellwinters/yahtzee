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
}
