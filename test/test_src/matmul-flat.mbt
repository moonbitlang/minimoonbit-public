fn loop3(i: Int, j: Int, k: Int, a: Array[Array[Double]], b: Array[Array[Double]], c: Array[Array[Double]]) -> Unit {
    if 0 <= k {
        c[i][j] = c[i][j] + a[i][k] * b[k][j];
        loop3(i, j, k - 1, a, b, c)
    } else {
      ()
    }
};

fn loop2(i: Int, m: Int, j: Int, a: Array[Array[Double]], b: Array[Array[Double]], c: Array[Array[Double]]) -> Unit {
    if 0 <= j {
        let _ = loop3(i, j, m - 1, a, b, c);
        loop2(i, m, j - 1, a, b, c)
    } else {
      ()
    }
};

fn loop1(i: Int, m: Int, n: Int, a: Array[Array[Double]], b: Array[Array[Double]], c: Array[Array[Double]]) -> Unit {
    if 0 <= i {
        let _ = loop2(i, m, n - 1, a, b, c);
        loop1(i - 1, m, n, a, b, c)
    } else {
      ()
    }
};

fn mul(l: Int, m: Int, n: Int, a: Array[Array[Double]], b: Array[Array[Double]], c: Array[Array[Double]]) -> Unit {
    let _ = loop1(l - 1, m, n, a, b, c);
    ()
};

fn main {
  let dummy = Array::make(0, 0.0);
  fn init(i: Int, n: Int, mat: Array[Array[Double]]) -> Unit {
    if 0 <= i {
        mat[i] = Array::make(n, 0.0);
        init(i - 1, n, mat)
    } else {
      ()
    }
  };
  fn make(m: Int, n: Int, dummy: Array[Double]) -> Array[Array[Double]] {
    let mat = Array::make(m, dummy);
    let _ = init(m - 1, n, mat);
    mat
  };
  let a = make(2, 3, dummy);
  let b = make(3, 2, dummy);
  let c = make(2, 2, dummy);
  a[0][0] = 1.0; a[0][1] = 2.0; a[0][2] = 3.0;
  a[1][0] = 4.0; a[1][1] = 5.0; a[1][2] = 6.0;
  b[0][0] = 7.0; b[0][1] = 8.0;
  b[1][0] = 9.0; b[1][1] = 10.0;
  b[2][0] = 11.0; b[2][1] = 12.0;
  let _ = mul(2,3,2,a,b,c);
  let _ = print_int(truncate(c[0][0]));
  let _ = print_endline();
  let _ = print_int(truncate(c[0][1]));
  let _ = print_endline();
  let _ = print_int(truncate(c[1][0]));
  let _ = print_endline();
  let _ = print_int(truncate(c[1][1]));
  ()
};