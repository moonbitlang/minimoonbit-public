///|
pub(all) type Label String derive(Show)

///|
pub typealias Name = @types.Name

///|
pub typealias Type = @types.Type

///|
pub(all) enum Expr {
  Unit
  Int(Int)
  Double(Double)
  Neg(Name)
  Add(Name, Name)
  Sub(Name, Name)
  Mul(Name, Name)
  Div(Name, Name)
  FNeg(Name)
  FAdd(Name, Name)
  FSub(Name, Name)
  FMul(Name, Name)
  FDiv(Name, Name)
  IfEq(Name, Name, Expr, Expr)
  IfLe(Name, Name, Expr, Expr)
  Let((Name, LowType), Expr, Expr)
  Var(Name)
  MakeClosure((Name, LowType), Closure, Expr)
  CallClosure(Name, Array[Name])
  CallDirect(Label, Array[Name])
  MakeTuple(Array[Name])
  LetTuple(Array[(Name, LowType)], Name, Expr)
  ArrayGet(Name, Name)
  ArrayPut(Name, Name, Name)
  ExternalArray(Label)
} derive(Show)

///|
pub(all) struct Closure {
  name : Label
  actual_free_vars : Array[Name]
} derive(Show)

///|
pub(all) struct FuncDef {
  name : Label
  old_name : Name
  /// true if the function is a closure function, and the closure will be available at `s11` on 
  /// function entry.
  is_closure : Bool
  ty : LowType
  args : Array[(Name, LowType)]
  formal_free_vars : Array[(Name, LowType)]
  body : Expr
} derive(Show)

///|
pub(all) struct Program {
  fundefs : Array[FuncDef]
  body : Expr
} derive(Show)
