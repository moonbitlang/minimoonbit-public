fn f(x: Unit) -> Int {
  123
};

fn g(x: Unit) -> Int {
  456
};

fn h(x: Unit) -> Int {
  789
};

fn main {
  let x = f(());
  let y = g(());
  print_int(if h(()) == 0 { x - y } else { y - x } + x + y)
};