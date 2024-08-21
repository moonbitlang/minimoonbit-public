fn f() -> Int {
  12345
};

fn g(y: Int) -> Int {
  y + 1
};

fn main {
  let z = Array::make(10, 1);
  let x = f();
  let y = 67890;
  let z0 = z[0];
  let z1 = z0 + z0;
  let z2 = z1 + z1;
  let z3 = z2 + z2;
  let z4 = z3 + z3;
  let z5 = z4 + z4;
  let z6 = z5 + z5;
  let z7 = z6 + z6;
  let z8 = z7 + z7;
  let z9 = z8 + z8;
  let z10 = z9 + z9;
  let z11 = z10 + z10;
  let z12 = z11 + z11;
  let z13 = z12 + z12;
  let z14 = z13 + z13;
  let z15 = z14 + z14;
  print_int(
    if z[1] == 0 {
      g(y)
    } else {
      z0 + z1 + z2 + z3 + z4 + z5 + z6 + z7 + z8 + z9 + z10 + z11 + z12 + z13 + z14 + z15 + x
    }
  )
};