fn f(a: Int, b: Int, c: Int, d: Int) -> Int {
  let e = a + b;
  let f = a + c;
  let g = a + d;
  let h = b + c;
  let i = b + d;
  let j = c + d;

  let k = e + f;
  let l = e + g;
  let m = e + h;
  let n = e + i;
  let o = e + j;
  let p = f + g;
  let q = f + h;
  let r = f + i;
  let s = f + j;
  let t = g + h;
  let u = g + i;
  let v = g + j;
  let w = h + i;
  let x = h + j;
  let y = i + j;

  let aa = k + l;
  let ab = k + m;
  let ac = k + n;
  let ad = k + o;
  let ae = k + p;
  let af = k + q;
  let ag = k + r;
  let ah = k + s;
  let ai = k + t;
  let aj = k + u;
  let ak = k + v;
  let al = k + w;
  let am = k + x;
  let an = k + y;

  let z = a + b + c + d + e + f + g + h + i + j + k + l + m + n + o + p + q + r + s + t + u + v + w + x + y + aa + ab + ac + ad + ae + af + ag + ah + ai + aj + ak + al + am + an;

  -z
};

fn main {
  print_int(f(1, 2, 3, 4))
};