fn make_adder(x: Int) -> (Int) -> Int {
  fn adder(y: Int) -> Int {
    x + y
  };
  adder
};

fn main {
  let add2 = make_adder(2);
  let add3 = make_adder(3);
  print_int(add2(10) + add3(20))
};