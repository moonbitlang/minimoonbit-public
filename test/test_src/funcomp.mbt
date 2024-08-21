fn compose(f: (Int) -> Int, g: (Int) -> Int) -> (Int) -> Int {
  fn composed(x: Int) -> Int {
    g(f(x))
  };
  composed
};

fn dbl(x: Int) -> Int {
  x + x
};

fn inc(x: Int) -> Int {
  x + 1
};

fn dec(x: Int) -> Int {
  x - 1
};

fn main {
  let h = compose(inc, compose(dbl, dec));
  print_int(h(123))
};