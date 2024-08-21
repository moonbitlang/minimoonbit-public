fn f(u: Unit) -> Int {
  123
};

fn g(u: Unit) -> Int {
  456
};

fn h(u: Unit) -> Int {
  789
};

fn main {
  let x = f(());
  let y = g(());
  print_int(if h(()) == 0 { x + 1 } else { y + 2 } + x + y)
};