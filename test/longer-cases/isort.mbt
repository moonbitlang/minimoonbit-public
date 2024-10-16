fn random(state: Int) -> Int {
  state * 1103515245 + 12345
};

fn modulo(x: Int, y: Int) -> Int {
  let q = x / y;
  x - q * y
};

fn fill_buffer(arr: Array[Int], n: Int) -> Unit {
  fn aux(i: Int, state: Int) -> Unit {
    if i == n {
      ()
    } else {
      let new_state = random(state);
      arr[i] = modulo(new_state, 10000);
      aux(i + 1, new_state)
    }
  };
  aux(0, 12345)
};

fn isort(arr: Array[Int], n: Int) -> Unit {
  fn insert(arr: Array[Int], i: Int) -> Unit {
    if i == 0 {
      ()
    } else {
      if arr[i - 1] <= arr[i] {
        ()
      } else {
        let tmp = arr[i];
        arr[i] = arr[i - 1];
        arr[i - 1] = tmp;
        insert(arr, i - 1)
      }
    }
  };

  fn aux(i: Int) -> Unit {
    if i == n {
      ()
    } else {
      let _ = insert(arr, i);
      aux(i + 1)
    }
  };

  aux(1)
};

fn print_array(arr: Array[Int], n: Int) -> Unit {
  fn aux(i: Int) -> Unit {
    if i == n {
      ()
    } else {
      let _ = print_int(arr[i]);
      let _ = print_char(32);
      aux(i + 1)
    }
  };
  aux(0)
};

fn main {
  let n = 100;
  let arr = Array::make(n, 0);
  let _ = fill_buffer(arr, n);
  let _ = isort(arr, n);
  print_array(arr, n)
};
