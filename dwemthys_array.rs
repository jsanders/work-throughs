struct Monster {
  health: int,
  attack: int
}

impl Monster {
  fn attack(&self) {
    println(fmt!("The monster attacks for %d damage.", self.attack));
  }

  fn count() {
    println("There are a bunch of monsters out tonight.");
  }

  fn new(health: int, attack: int) -> Monster {
    Monster { health:health, attack:attack }
  }
}

fn main() {
  Monster::new(20, 40).attack();
}
