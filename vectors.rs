fn main() {
  let your_favorite_numbers = @[1,2,3];
  let my_favorite_numbers = @[4,5,6];

  let our_favorite_numbers = your_favorite_numbers + my_favorite_numbers;

  println(fmt!("The third favorite number is %d.", our_favorite_numbers[2]));
}
