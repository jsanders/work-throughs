fn message(i: int) {
  match i {
    1 => println("ONE!"),
    2 => println("Two is a prime."),
    3 => println("THREE"),
    _ => println("no idea what that is, boss")
  }
}

fn main() {
  message(1);
  message(2);
  message(3);
  message(70);
}
