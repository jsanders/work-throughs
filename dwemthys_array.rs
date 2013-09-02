enum Monster {
  ScubaArgentine(int, int, int, int),
  IndustrialRaverMonster(int, int, int, int)
}

impl Monster {
  fn attack(&self) {
    match *self {
      ScubaArgentine(l, s, c, w) => println(fmt!("The monster attacks for %d damage.", w)),
      IndustrialRaverMonster(l, s, c, w) => println(fmt!("The monster attacks for %d damage.", w))
    }
  }
}

fn main() {
  let irm = IndustrialRaverMonster(46, 35, 91, 2);
  irm.attack();
}
