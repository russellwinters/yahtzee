use actix_web::{get, App, HttpResponse, HttpServer, Responder};
use rand::Rng;

#[get("/")]
async fn hello() -> impl Responder {
    HttpResponse::Ok().body("Hello, Actix web here")
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| App::new().service(hello))
        .bind(("127.0.0.1", 8080))?
        .run()
        .await
}

const MAX_ROLLS: u8 = 3;
const MAX_NUMBER: u8 = 6;
const MIN_NUMBER: u8 = 1;

struct Game {
    dice: Dice,
    rolls: u8,
    score: Scorecard,
}

impl Game {
    fn new() -> Self {
        Self {
            dice: Dice::new(),
            rolls: 0,
            score: Scorecard::new(),
        }
    }
}

struct Scorecard {
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
    fn new() -> Self {
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

struct Die {
    value: (u8, bool),
}

impl Die {
    fn new() -> Self {
        Self {
            value: (MIN_NUMBER, false),
        }
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

    pub fn lock(&mut self) {
        self.value = (self.value.0, true);
    }

    pub fn unlock(&mut self) {
        self.value = (self.value.0, false);
    }
}

struct Dice {
    first: Die,
    second: Die,
    third: Die,
    fourth: Die,
    fifth: Die,
}

impl Dice {
    fn new() -> Self {
        Self {
            first: Die::new(),
            second: Die::new(),
            third: Die::new(),
            fourth: Die::new(),
            fifth: Die::new(),
        }
    }
}
