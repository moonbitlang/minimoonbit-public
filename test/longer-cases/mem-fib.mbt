let unmem_magic: Int = -1919810;

fn mem(func: ((Int) -> Int, Int) -> Int, max_n: Int) -> (Int) -> Int {
  let cache = Array::make(max_n, unmem_magic);

  fn memed(n: Int) -> Int {
    if cache[n] == unmem_magic {
      let res = func(memed, n);
      cache[n] = res;
      res
    } else {
      cache[n]
    }
  };

  memed
};

fn mem_fib(f: (Int) -> Int, n: Int) -> Int {
  if n <= 1 {
    n
  } else {
    f(n - 1) + f(n - 2)
  }
};

fn fib(n: Int) -> Int {
  let f = mem(mem_fib, n+1);
  f(n)
};

fn main {
  let n = read_int();
  let _ = print_int(fib(n));
  let _ = print_char(10);
  ()
};