fn matmul(l: Int, m: Int, n: Int, a: Array[Array[Double]], b: Array[Array[Double]], c: Array[Array[Double]]) -> Unit {
  fn loop1(i: Int) -> Unit {
    if 0 <= i {
      fn loop2(j: Int) -> Unit {
        if 0 <= j {
          fn loop3(k: Int) -> Unit {
            if 0 <= k {
              c[i][j] = c[i][j] + a[i][k] * b[k][j];
              loop3(k - 1)
            } else {
              ()
            }
          };
          let _ = loop3(m - 1);
          loop2(j - 1)
        } else {
          ()
        }
      };
      let _ = loop2(n - 1);
      loop1(i - 1)
    } else {
      ()
    }
  };
  loop1(l - 1)
};

fn main {
  let dummy = Array::make(0, 0.0);
  fn gen_arr(m: Int, n: Int) -> Array[Array[Double]] {
    let mat = Array::make(m, dummy);
    fn init_arr(i: Int) -> Unit {
      if 0 <= i {
        mat[i] = Array::make(n, 0.0);
        init_arr(i - 1)
      } else {
        ()
      }
    };
    let _ = init_arr(m - 1);
    mat
  };
  let a = gen_arr(2, 3);
  let b = gen_arr(3, 2);
  let c = gen_arr(2, 2);
  a[0][0] = 1.0; a[0][1] = 2.0; a[0][2] = 3.0;
  a[1][0] = 4.0; a[1][1] = 5.0; a[1][2] = 6.0;
  b[0][0] = 7.0; b[0][1] = 8.0;
  b[1][0] = 9.0; b[1][1] = 10.0;
  b[2][0] = 11.0; b[2][1] = 12.0;
  let _ = matmul(2,3,2,a,b,c);
  let _ = print_int(truncate(c[0][0]));
  let _ = print_endline();
  let _ = print_int(truncate(c[0][1]));
  let _ = print_endline();
  let _ = print_int(truncate(c[1][0]));
  let _ = print_endline();
  let _ = print_int(truncate(c[1][1]));
  ()
};
