use super::consts::{MAX_NUMBER, MIN_NUMBER};
use rand::Rng;

pub struct Die {
    value: (u8, bool),
}

impl Die {
    pub fn new() -> Self {
        Self {
            value: (MIN_NUMBER, false),
        }
    }

    pub fn val(&self) -> u8 {
        self.value.0
    }

    fn rand_num(&self) -> u8 {
        let mut rng = rand::rng();
        let val = rng.random_range(MIN_NUMBER..=MAX_NUMBER);
        val
    }

    pub fn roll(&mut self) {
        if self.value.1 {
            return;
        }

        let val = self.rand_num();
        self.value = (val, self.value.1);
    }

    pub fn lock(&mut self) -> &mut Die {
        self.value = (self.value.0, true);

        self
    }

    pub fn unlock(&mut self) -> &mut Die {
        self.value = (self.value.0, false);

        self
    }
}
