fn f(x0 : Int) -> Int {
  let x1 = x0 + 1;
  let x2 = x1 + 1;
  let x3 = x2 + 1;
  let x4 = x3 + 1;
  let x5 = x4 + 1;
  let x6 = x5 + 1;
  let x7 = x6 + 1;
  let x8 = x7 + 1;
  let x9 = x8 + 1;
  let x10 = x9 + 1;
  let x11 = x10 + 1;
  let x12 = x11 + 1;
  let x13 = x12 + 1;
  let x14 = x13 + 1;
  let x15 = x14 + 1;
  let x16 = x15 + 1;
  let x17 = x16 + 1;
  let x18 = x17 + 1;
  let x19 = x18 + x1;
  let x20 = x19 + x2;
  let x21 = x20 + x3;
  let x22 = x21 + x4;
  let x23 = x22 + x5;
  let x24 = x23 + x6;
  let x25 = x24 + x7;
  let x26 = x25 + x8;
  let x27 = x26 + x9;
  let x28 = x27 + x10;
  let x29 = x28 + x11;
  let x30 = x29 + x12;
  let x31 = x30 + x13;
  let x32 = x31 + x14;
  let x33 = x32 + x15;
  let x34 = x33 + x16;
  let x35 = x34 + x17;
  let x36 = x35 + x0;
  x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 + x10 + x11 + x12 + x13 + x14 + x15 + x16 + x17 + x18 + x19 + x20 + x21 + x22 + x23 + x24 + x25 + x26 + x27 + x28 + x29 + x30 + x31 + x32 + x33 + x34 + x35 + x36 + x0
};

fn main {
  print_int(f(0))
};