fn foo(a: Int, b: Int, c: Int, d: Int, e: Int, f: Int) -> Unit {
  let _ =  print_int(a);
  let _ =  print_int(b);
  let _ =  print_int(c);
  let _ =  print_int(d);
  let _ =  print_int(e);
  let _ =  print_int(f);
  ()
};

fn bar(a: Int, b: Int, c: Int, d: Int, e: Int, f: Int) -> Unit {
  foo(b, a, d, e, f, c)
};

fn main {
  bar(1, 2, 3, 4, 5, 6)
};