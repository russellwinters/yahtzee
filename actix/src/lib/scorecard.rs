use super::Dice;

pub struct Scorecard {
    ones: Option<u16>,
    twos: Option<u16>,
    threes: Option<u16>,
    fours: Option<u16>,
    fives: Option<u16>,
    sixes: Option<u16>,
    three_of_a_kind: Option<u16>,
    four_of_a_kind: Option<u16>,
    full_house: Option<u16>,
    small_straight: Option<u16>,
    large_straight: Option<u16>,
    yahtzee: Option<u16>,
    chance: Option<u16>,
}

impl Scorecard {
    pub fn new() -> Self {
        Self {
            ones: None,
            twos: None,
            threes: None,
            fours: None,
            fives: None,
            sixes: None,
            three_of_a_kind: None,
            four_of_a_kind: None,
            full_house: None,
            small_straight: None,
            large_straight: None,
            yahtzee: None,
            chance: None,
        }
    }

    pub fn score_upper(&mut self, val: &str, dice: Dice) {
        match val {
            "ones" => {
                let mut total: u16 = 0;
                for die in dice.iter() {
                    if die.val() == 1 {
                        total += 1;
                        self.ones = Some(total);
                    }
                }
            }
            "twos" => {
                let mut total: u16 = 0;
                for die in dice.iter() {
                    if die.val() == 2 {
                        total += 1;
                        self.twos = Some(total);
                    }
                }
            }
            "threes" => {
                let mut total: u16 = 0;
                for die in dice.iter() {
                    if die.val() == 3 {
                        total += 1;
                        self.threes = Some(total);
                    }
                }
            }
            "fours" => {
                let mut total: u16 = 0;
                for die in dice.iter() {
                    if die.val() == 4 {
                        total += 1;
                        self.fours = Some(total);
                    }
                }
            }
            "fives" => {
                let mut total: u16 = 0;
                for die in dice.iter() {
                    if die.val() == 5 {
                        total += 1;
                        self.fives = Some(total);
                    }
                }
            }
            "sixes" => {
                let mut total: u16 = 0;
                for die in dice.iter() {
                    if die.val() == 6 {
                        total += 1;
                        self.sixes = Some(total);
                    }
                }
            }
            _ => {}
        }
    }

    fn validate_board(&self) -> bool {
        self.ones.is_some()
            && self.twos.is_some()
            && self.threes.is_some()
            && self.fours.is_some()
            && self.fives.is_some()
            && self.sixes.is_some()
            && self.three_of_a_kind.is_some()
            && self.four_of_a_kind.is_some()
            && self.full_house.is_some()
            && self.small_straight.is_some()
            && self.large_straight.is_some()
            && self.yahtzee.is_some()
            && self.chance.is_some()
    }

    pub fn get_total(&self) -> Result<u16, String> {
        if !self.validate_board() {
            return Err("Not all fields are filled out".to_string());
        }
        let mut total = 0;
        total += self.ones.unwrap();
        total += self.twos.unwrap();
        total += self.threes.unwrap();
        total += self.fours.unwrap();
        total += self.fives.unwrap();
        total += self.sixes.unwrap();
        total += self.three_of_a_kind.unwrap();
        total += self.four_of_a_kind.unwrap();
        total += self.full_house.unwrap();
        total += self.small_straight.unwrap();
        total += self.large_straight.unwrap();
        total += self.yahtzee.unwrap();
        total += self.chance.unwrap();

        Ok(total)
    }
}
