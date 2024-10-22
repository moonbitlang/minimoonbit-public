fn map(stream: (Unit) -> (Int, Int), f: (Int) -> Int) -> (Unit) -> (Int, Int) {
  fn aux(u) -> (Int, Int) {
    let (ok, val) = stream(());
    if ok == 0 {
      (0, 0)
    } else {
      (1, f(val))
    }
  };
  aux
};
fn filter(stream: (Unit) -> (Int, Int), f: (Int) -> Int) -> (Unit) -> (Int, Int) {
  fn aux(u) -> (Int, Int) {
    let (ok, val) = stream(());
    if ok == 0 {
      (0, 0)
    } else {
      let r = f(val);
      if r == 0 {
        (1, val)
      } else {
        aux(())
      }
    }
  };
  aux
};

fn concat(stream1: (Unit) -> (Int, Int), stream2: (Unit) -> (Int, Int)) -> (Unit) -> (Int, Int) {
  fn aux(u) -> (Int, Int) {
    let (ok, val) = stream1(());
    if ok == 0 {
      stream2(())
    } else {
      (1, val)
    }
  };
  aux
};

fn range(from: Int, to: Int) -> (Unit) -> (Int, Int) {
  let state = Array::make(1, from);
  fn aux(u) -> (Int, Int) {
    let val = state[0];
    if val == to {
      (0, 0)
    } else {
      state[0] = val + 1;
      (1, val)
    }
  };
  aux
};

fn addx(x: Int) -> (Int) -> Int {
  fn aux(y: Int) -> Int {
    x + y
  };
  aux
};

fn fold(stream: (Unit) -> (Int, Int), f: (Int, Int) -> Int, acc: Int) -> Int {
  let (ok, val) = stream(());
  if ok == 0 {
    acc
  } else {
    fold(stream, f, f(acc, val))
  }
};

fn sum(stream: (Unit) -> (Int, Int)) -> Int {
  fn add(x: Int, y: Int) -> Int {
    x + y
  };
  fold(stream, add, 0)
};

fn gt(x: Int) -> (Int) -> Int {
  fn aux(y: Int) -> Int {
    if x <= y {
      0
    } else {
      1
    }
  };
  aux
};

fn le(x: Int) -> (Int) -> Int {
  fn aux(y: Int) -> Int {
    if y <= x {
      0
    } else {
      1
    }
  };
  aux
};

fn main {
  let range100 = range(0, 100);
  let range1000 = range(0, 1000);
  let catt = concat(range100, range1000);
  let addone = map(catt, addx(1));
  let over50 = filter(addone, gt(50));
  let under1200 = filter(over50, le(1200));
  let sum = sum(under1200);
  let _ = print_int(sum);
  let _ = print_char(10);
  ()
};