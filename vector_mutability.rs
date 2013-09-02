fn main() {
  let a_vector = @[1,2,3];
  let mut another_vector = @[];
  another_vector = another_vector + a_vector;

  println(fmt!("The first number is %d.", another_vector[0]));
}
