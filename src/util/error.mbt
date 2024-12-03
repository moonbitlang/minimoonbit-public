///|
pub fn die[T](msg : String) -> T {
  println("Error: " + msg)
  panic()
}
