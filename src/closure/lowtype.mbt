/// Low-level types. Main difference between this and Type is that it distinguishes between direct function pointers and closure function pointers.
pub enum LowType {
  Unit
  Bool
  Int
  Double
  ClosureFn(Array[LowType], LowType) // (fn_ptr, closure_args...)
  DirectFn(Array[LowType], LowType) // fn_ptr itself
  Tuple(Array[LowType])
  Array(LowType)
  Ptr
} derive(Show)

pub fn LowType::is_ptr_like(self : LowType) -> Bool {
  match self {
    ClosureFn(_) | DirectFn(_) | Tuple(_) | Array(_) | Ptr => true
    _ => false
  }
}

pub fn LowType::is_float_like(self : LowType) -> Bool {
  match self {
    Double => true
    _ => false
  }
}

pub fn LowType::size_of(self : LowType, size_of_ptr : Int) -> Int {
  match self {
    Unit => 0
    Bool => 4
    Int => 4
    Double => 8
    _ => if self.is_ptr_like() { size_of_ptr } else { 4 }
  }
}
