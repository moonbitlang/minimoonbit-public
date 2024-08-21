fn inprod(v1: Array[Double], v2: Array[Double], i: Int) -> Double {
  if 0 <= i {
    v1[i] * v2[i] + inprod(v1, v2, i - 1)
  } else {
    0.0
  }
};

fn main {
  let v1 = Array::make(3, 1.23);
  let v2 = Array::make(3, 4.56);
  print_int(truncate(1000000.0 * inprod(v1, v2, 2)))
};