fn sum(x: Int) -> Int {
  if x <= 0 {
    0
  } else {
    sum(x - 1) + x
  }
};

fn main {
  print_int(sum(10000))
};