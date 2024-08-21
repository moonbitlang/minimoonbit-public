fn main {
  fn f() -> Int {
    12345
  };
  let y = Array::make(10, 3);
  let x = 67890;
  print_int(if y[0] == 3 { f() + y[1] + x } else { 7 })
};