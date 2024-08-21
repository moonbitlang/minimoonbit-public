fn inprod(v1: Array[Double], v2: Array[Double], acc: Double, i: Int) -> Double {
  if 0 <= i {
    inprod(v1, v2, acc + v1[i] * v2[i], i - 1)
  } else {
    acc
  }
};

fn main {
  let v1 = Array::make(3, 1.23);
  let v2 = Array::make(3, 4.56);
  print_int(truncate(1000000.0 * inprod(v1, v2, 0.0, 2)))
};