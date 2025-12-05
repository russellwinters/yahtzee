use super::Die;

pub struct Dice {
    first: Die,
    second: Die,
    third: Die,
    fourth: Die,
    fifth: Die,
}

impl Dice {
    // TODO: Implement freeze fn, which will take an index and freeze that die in the iter()
    pub fn new() -> Self {
        Self {
            first: Die::new(),
            second: Die::new(),
            third: Die::new(),
            fourth: Die::new(),
            fifth: Die::new(),
        }
    }

    pub fn roll(&mut self) {
        self.first.roll();
        self.second.roll();
        self.third.roll();
        self.fourth.roll();
        self.fifth.roll();
    }

    pub fn iter(&self) -> Vec<&Die> {
        vec![
            &self.first,
            &self.second,
            &self.third,
            &self.fourth,
            &self.fifth,
        ]
    }
}
