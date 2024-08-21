fn ack(x : Int, y : Int) -> Int {
  if x <= 0 {
    y + 1
  } else {
    if y <= 0 {
      ack(x - 1, 1)
    } else {
      ack(x - 1, ack(x, y - 1))
    }
  }
};

fn main {
  print_int(ack(3,8))
};