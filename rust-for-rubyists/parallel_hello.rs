fn main() {
  do 100.times {
    do spawn {
      println("Hello");
    }
  }
}
