//Roll Dice
const dice1 = { element: document.querySelector("#dice-1") };
const dice2 = { element: document.querySelector("#dice-2") };
const dice3 = { element: document.querySelector("#dice-3") };
const dice4 = { element: document.querySelector("#dice-4") };
const dice5 = { element: document.querySelector("#dice-5") };

let ALL_DICE = [dice1, dice2, dice3, dice4, dice5];
let scratchStatus = false;
let DiceScores = [];
let roundscore = 0;
let ROLLS_IN_ROUND = 0;

//!Rolls All dice
document.querySelector(".btn-roll").addEventListener("click", () => {
  if (ROLLS_IN_ROUND < 3) {
    roundscore = 0;
    ALL_DICE.forEach((item) => {
      if (!item.holdStatus) {
        RollDice(item);
      }
    });
    roundscore =
      dice1.value + dice2.value + dice3.value + dice4.value + dice5.value;

    ROLLS_IN_ROUND += 1;
    document.querySelector("#rolls-in-round").innerHTML = ROLLS_IN_ROUND;
  }
});

//!Click to Hold particular dice
document.querySelectorAll(".dice").forEach((item, i) => {
  item.addEventListener("click", () => {
    let testArray = ALL_DICE.filter((dice) => {
      return dice.element === item;
    });
    // console.log(testArray[0]);
    if (testArray[0].holdStatus) {
      testArray[0].holdStatus = false;
    } else {
      testArray[0].holdStatus = true;
    }
  });
});

//Scoring rules:
const BOX_SCORES = {
  score1: { value: "free" },
  score2: { value: "free" },
  score3: { value: "free" },
  score4: { value: "free" },
  score5: { value: "free" },
  score6: { value: "free" },
  threekind: { value: "free", rules: "threekind" },
  fourkind: { value: "free", rules: "fourkind" },
  fullhouse: { value: 25, rules: "fullhouse" },
  smallstraight: { value: 30, rules: "smallstraight" },
  largestraight: { value: 40, rules: "largestraight" },
  yahtzee: { value: 50, rules: "yahtzee" },
  chance: { value: "free", rules: "none" },
  upperTotal: "upperTotal",
  lowerTotal: "lowerTotal",
  grandTotal: "grandTotal",
};

//!Listener for Submitting Scores
document.querySelectorAll(".score-card").forEach((item) => {
  item.addEventListener("click", () => {
    let c = item.children;
    let CLICKED_WRONG_BOX = false;

    //*Handle Scratch
    if (scratchStatus) {
      c[1].innerHTML = "X";
      BOX_SCORES[c[1].id].score = "X";
      console.log(BOX_SCORES);
      ActivateScratch();
    } else {
      //*Upper Scores
      if (
        item.parentElement.className === "upper-score" &&
        roundscore &&
        !c[1].innerHTML
      ) {
        let box_value = c[1].id.charAt(5);
        let value = CalculateScores(box_value);
        //? console.log(value);
        BOX_SCORES[c[1].id].score = value;
        c[1].innerHTML = value;
      }

      //*Lower Scores
      if (
        item.parentElement.className === "lower-score" &&
        roundscore &&
        !c[1].innerHTML
      ) {
        let rule = BOX_SCORES[c[1].id].rules; //rule
        let ALL_DICE_TO_VERIFY = [
          dice1.value,
          dice2.value,
          dice3.value,
          dice4.value,
          dice5.value,
        ]; //Dice Array

        console.log(ALL_DICE_TO_VERIFY);
        let check = VerifyScoreAndInput(rule, ALL_DICE_TO_VERIFY);
        console.log(check);

        if (check) {
          //!Run these if conditional passes
          let value = BOX_SCORES[c[1].id].value;

          typeof value === "number"
            ? (c[1].innerHTML = value)
            : (c[1].innerHTML = roundscore);
          typeof value === "number"
            ? (BOX_SCORES[c[1].id].score = value)
            : (BOX_SCORES[c[1].id].score = roundscore);
        } else {
          CLICKED_WRONG_BOX = true;
        }
      }
    }

    //*Grand Total
    CalculateUpper();
    CalculateLower();
    CalculateTotal();
    ALL_DICE = [dice1, dice2, dice3, dice4, dice5];
    if (!CLICKED_WRONG_BOX) {
      ALL_DICE.forEach((item) => {
        item.holdStatus = false;
      });
      ROLLS_IN_ROUND = 0;
      document.querySelector("#rolls-in-round").innerHTML = 0;
    }
  });
});

//Handle Scratches:
document.querySelector("#scratch").addEventListener("click", () => {
  ActivateScratch();
});

//Functions below
function RollDice(itemToRoll) {
  let num = Math.floor(Math.random() * 6 + 1);
  itemToRoll.element.src = `./dice/dice-${num}.png`;
  itemToRoll.value = num;
}

function CalculateScores(number) {
  let score = 0;
  let diceArray = [
    dice1.value,
    dice2.value,
    dice3.value,
    dice4.value,
    dice5.value,
  ];

  diceArray.forEach((num) => {
    num === Number(number) ? (score += num) : (score += 0);
  });
  return score;
}

const CalculateLower = () => {
  if (
    BOX_SCORES.threekind.score &&
    BOX_SCORES.fourkind.score &&
    BOX_SCORES.fullhouse.score &&
    BOX_SCORES.smallstraight.score &&
    BOX_SCORES.largestraight.score &&
    BOX_SCORES.yahtzee.score &&
    BOX_SCORES.chance.score
  ) {
    let scoreArray = [
      BOX_SCORES.threekind.score,
      BOX_SCORES.fourkind.score,
      BOX_SCORES.fullhouse.score,
      BOX_SCORES.smallstraight.score,
      BOX_SCORES.largestraight.score,
      BOX_SCORES.yahtzee.score,
      BOX_SCORES.chance.score,
    ];

    let lowerValue = [];
    scoreArray.forEach((value) => {
      DetermineValueOfScore(value, lowerValue);
    });
    let lower_score = lowerValue.reduce((num, cum) => num + cum);
    //? console.log(lower_score);

    document.querySelector("#lowertotal").innerHTML = lower_score;
  }
};

const CalculateUpper = () => {
  if (
    typeof BOX_SCORES.score1.score === "number" &&
    typeof BOX_SCORES.score2.score === "number" &&
    typeof BOX_SCORES.score3.score === "number" &&
    typeof BOX_SCORES.score4.score === "number" &&
    typeof BOX_SCORES.score5.score === "number" &&
    typeof BOX_SCORES.score6.score === "number"
  ) {
    let UPPER_TOTAL =
      BOX_SCORES.score1.score +
      BOX_SCORES.score2.score +
      BOX_SCORES.score3.score +
      BOX_SCORES.score4.score +
      BOX_SCORES.score5.score +
      BOX_SCORES.score6.score;

    if (UPPER_TOTAL >= 63) {
      UPPER_TOTAL += 35;
    }

    document.querySelector("#uppertotal").innerHTML = UPPER_TOTAL;
  }
};

function CalculateTotal() {
  let upper_total = document.querySelector("#uppertotal").innerHTML;
  let lower_total = document.querySelector("#lowertotal").innerHTML;
  if (upper_total && lower_total) {
    let GRAND_TOTAL = Number(lower_total) + Number(upper_total);
    document.querySelector("#grandtotal").innerHTML = GRAND_TOTAL;
  }
}

function ActivateScratch() {
  scratchStatus = !scratchStatus;
}

function DetermineValueOfScore(value, array) {
  if (typeof value === "number") {
    array.push(value);
  }
}

function VerifyScoreAndInput(rule, diceArray) {
  let setToTest, testArray, countObject;
  switch (rule) {
    case "threekind": //!DONE
      console.log("Three of a kind");
      setToTest = new Set(diceArray);
      if (Number(Array.from(setToTest).length <= 3)) {
        return true;
      }
      break;
    case "fourkind": //!DONE
      console.log("Four of a kind");
      setToTest = new Set(diceArray);
      countObject = {}; //Condition two is that these values must be 2 or 3
      diceArray.forEach((num) => {
        if (countObject[num]) {
          countObject[num] += 1;
        } else {
          countObject[num] = 1;
        }
      });
      if (
        Number(Array.from(setToTest).length <= 2) &&
        (Object.values(countObject)[0] >= 4 ||
          Object.values(countObject)[0] === 1)
      ) {
        return true;
      }
      break;
    case "fullhouse": //!DONE
      console.log("Full House");
      setToTest = new Set(diceArray); //Condition one is length here === 2
      countObject = {}; //Condition two is that these values must be 2 or 3
      diceArray.forEach((num) => {
        if (countObject[num]) {
          countObject[num] += 1;
        } else {
          countObject[num] = 1;
        }
      });
      if (
        Number(Array.from(setToTest).length) === 2 &&
        (Object.values(countObject)[0] === 3 ||
          Object.values(countObject)[0] === 2)
      ) {
        return true;
      }
      break;
    case "smallstraight": //!DONE
      console.log("Small Straight");
      testArray = Array.from(new Set(diceArray));
      testArray.sort();
      let values = {
        1: false,
        2: false,
        3: false,
        4: false,
        5: false,
        6: false,
      };
      testArray.forEach((num) => {
        values[num] = true;
      });
      let booleans = Object.values(values);
      if (
        (booleans[0] === true &&
          booleans[1] === true &&
          booleans[2] === true &&
          booleans[3] === true) ||
        (booleans[1] === true &&
          booleans[2] === true &&
          booleans[3] === true &&
          booleans[4] === true) ||
        (booleans[2] === true &&
          booleans[3] === true &&
          booleans[4] === true &&
          booleans[5] === true)
      ) {
        return true;
        // console.log("Condition passed");
      }
      break;
    case "largestraight": //!DONE
      console.log("Large Straight");
      testArray = Array.from(new Set(diceArray));
      let sum = testArray.reduce((cum, num) => cum + num);
      if (testArray.length === 5 && (sum === 15 || sum === 20)) {
        return true;
      }
      break;
    case "yahtzee": //!DONE
      console.log("Yahtzee");
      setToTest = new Set(diceArray);
      if (Number(Array.from(setToTest).length) === 1) {
        return true;
      }
      break;
    case "none": //!DONE
      return true;
      break;
  }
  // console.log(ConditionStatus);
}

document.querySelector(".btn-new").addEventListener("click", () => {
  Initialize__NEW__GAME();
});

function Initialize__NEW__GAME() {
  document.querySelectorAll(".score-card").forEach((element) => {
    let children = element.children;
    children[1].innerHTML = null;
  });
  document.querySelectorAll(".total-score-card").forEach((element) => {
    let children = element.children;
    children[1].innerHTML = null;
  });
  document.querySelector("#rolls-in-round").innerHTML = 0;
  ROLLS_IN_ROUND = 0;
}
