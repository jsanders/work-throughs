use std::io::stdin;
use std::rand;
use std::rand::RngUtil;
use std::num::abs;
use std::int;

fn generate_secret_number() -> int {
  return abs(rand::rng().gen::<int>() % 100) + 1;
}

fn process_guess(secret: int, guess: int, guesses: &mut int) {
  println(fmt!("You guessed: %d", guess));

  if guess > secret {
    println("Your guess was too high!");
  } else if guess < secret {
    println("Your guess was too low!");
  } else if guess == secret {
    println("You got it!");
    *guesses = 4;
  }

  *guesses += 1;
}

fn main() {
  let secret = generate_secret_number();

  let guesses = @mut 1;

  println("--- N U M B E R - G A M E ---");
  println("");
  println("Guess a number from 1-100 (you get five tries):");

  loop {
    println(fmt!("Guess #%d", *guesses));

    let input = stdin().read_line();

    match int::from_str(input) {
      Some(number) => process_guess(secret, number, guesses),
      None         => println("Hey, put in a number.")
    }
    if *guesses == 5 { break; }
  }

  println("Done!");
}
