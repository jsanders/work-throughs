fn main() {
  let x: ~int = ~10;
  // let y = x;
  // error: use of moved value: `x`
  let y: ~int = x.clone();
  println((*x).to_str());
  println((*y).to_str());
}

