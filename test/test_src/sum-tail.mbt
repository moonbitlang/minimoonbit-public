fn sum(acc: Int, x: Int) -> Int {
  if x <= 0 {
    acc
  } else {
    sum(acc + x, x - 1)
  }
};

fn main {
  print_int(sum(0, 10000))
};