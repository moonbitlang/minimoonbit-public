fn f(u: Unit) -> Int {
  123
};

fn g(u: Unit) -> Int {
  456
};

fn main {
  let x = f(());
  print_int(if x <= 0 { g(()) + x } else { x } + x)
};