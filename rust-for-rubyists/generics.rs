fn print_vec<T: ToStr>(v: &[T]) {
  for i in v.iter() {
    println(i.to_str());
  }
}

fn main() {
  let vec = [1,2,3];

  print_vec(vec);

  let str_vec = [~"hey", ~"there", ~"yo"];

  print_vec(str_vec);
}
