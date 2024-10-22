let limit: Double = 2.0;
let limit_sq: Double = limit * limit;
let iter: Int = 300;

let c_re: Double = -0.123;
let c_im: Double = 0.745;

fn calc_pixel(zr: Double, zi: Double, it: Int) -> Int {
  let zr2 = zr * zr;
  let zi2 = zi * zi;
  if it == iter {
    iter
  } else {
    if limit_sq <= (zr2 + zi2) {
      it
    } else {
      let new_zi = 2.0 * zr * zi + c_im;
      let new_zr = zr2 - zi2 + c_re;
      calc_pixel(new_zr, new_zi, it + 1)
    }
  }
};

fn clamp(i: Int) -> Int {
  if i <= 0 {
    0
  } else {
    if 48 <= i {
      48
    } else {
      i
    }
  }
};

fn main_loop(w: Int, h: Int, x: Int, y: Int, ret: Array[Int]) -> Unit {
  if y == h {
    ()
  } else {
    if x == w {
      main_loop(w, h, 0, y + 1, ret)
    } else {
      let cr = -(3.0 * float_of_int(x) / float_of_int(w) - 1.5);
      let ci = 3.0 * float_of_int(y) / float_of_int(h) - 1.5;
      let res = calc_pixel(cr,ci,0);
      ret[y * w + x] = clamp(res);
      main_loop(w, h, x + 1, y, ret)
    }
  }
};

fn print_loop(w: Int, h: Int, x: Int, y: Int, ret: Array[Int]) -> Unit {
  if y == h {
    ()
  } else {
    if x == w {
      let _ = print_char(10);
      print_loop(w, h, 0, y + 1, ret)
    } else {
      let _ = print_char(48 + ret[y * w + x]);
      print_loop(w, h, x + 1, y, ret)
    }
  }
};
    
fn main {
  let h = read_int();
  let w = h*2;
  let ret = Array::make(w * h, 0);
  let _ = main_loop(w, h, 0, 0, ret);
  let _ = print_loop(w, h, 0, 0, ret);
  ()
};