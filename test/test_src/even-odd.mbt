let t: Int = 123;
let f: Int = 456;

fn even(x: Int) -> Int {
  fn odd(x: Int) -> Int {
    if 0 <= x {
      if x == 0 {
        f
      } else {
        even(x - 1)
      }
    } else {
      even(x + 1)
    }
  };
  if 0 <= x {
    if x == 0 {
      t
    } else {
      odd(x - 1)
    }
  } else {
    odd(x + 1)
  }
};

fn main {
  print_int(even(789))
};
