///|
struct ClosureInterpreter {
  extern_fns : Map[String, (Array[Value]) -> Value]
  functions : Map[String, @closure.FuncDef]
}

///|
pub typealias Name = @types.Name

///|
pub typealias InterpreterLocalVars = @immut/hashmap.T[Name, Value]

///|
pub(all) enum Value {
  Unit
  Int(Int)
  Double(Double)
  Tuple(Array[Value])
  Array(Array[Value])
  ExternFn(String)
  Closure(@closure.FuncDef, Array[Value])
} derive(Show)

///|
pub impl Eq for Value with op_equal(self : Value, other : Value) -> Bool {
  match (self, other) {
    (Unit, Unit) => true
    (Int(x), Int(y)) => x == y
    (Double(x), Double(y)) => x == y
    (Tuple(xs), Tuple(ys)) => xs == ys
    (Array(xs), Array(ys)) => xs == ys
    (ExternFn(x), ExternFn(y)) => x == y
    (Closure(_, _), Closure(_, _)) => false
    _ => false
  }
}

///|
pub fn ClosureInterpreter::new() -> ClosureInterpreter {
  { extern_fns: Map::new(), functions: Map::new() }
}

///|
pub fn ClosureInterpreter::add_extern_fn(
  self : ClosureInterpreter,
  name : String,
  f : (Array[Value]) -> Value
) -> Unit {
  self.extern_fns.set(name, f)
}

///|
fn find(env : InterpreterLocalVars, name : Name) -> Value!Failure {
  env.find(name).or_error!(Failure("variable not found: \{name}"))
}

///|
pub fn ClosureInterpreter::eval_full(
  self : ClosureInterpreter,
  expr : @closure.Program
) -> Value!Failure {
  for f in expr.fundefs {
    self.functions.set(f.name._, f)
  }
  let env = @immut/hashmap.new()
  self.eval!(env, expr.body)
}

///|
pub fn ClosureInterpreter::eval(
  self : ClosureInterpreter,
  env : InterpreterLocalVars,
  expr : @closure.Expr
) -> Value!Failure {
  match expr {
    Unit => Unit
    Int(i) => Int(i)
    Double(d) => Double(d)
    Var(v) => find!(env, v)
    Neg(x) => {
      let x = find!(env, x)
      match x {
        Int(x) => Int(-x)
        _ => fail!("type mismatch, neg expects Int")
      }
    }
    Add(x, y) => {
      let x = find!(env, x)
      let y = find!(env, y)
      match (x, y) {
        (Int(x), Int(y)) => Int(x + y)
        _ => fail!("type mismatch, add expects Int")
      }
    }
    Sub(x, y) => {
      let x = find!(env, x)
      let y = find!(env, y)
      match (x, y) {
        (Int(x), Int(y)) => Int(x - y)
        _ => fail!("type mismatch, sub expects Int")
      }
    }
    Mul(x, y) => {
      let x = find!(env, x)
      let y = find!(env, y)
      match (x, y) {
        (Int(x), Int(y)) => Int(x * y)
        _ => fail!("type mismatch, mul expects Int")
      }
    }
    Div(x, y) => {
      let x = find!(env, x)
      let y = find!(env, y)
      match (x, y) {
        (Int(x), Int(y)) => Int(x / y)
        _ => fail!("type mismatch, div expects Int")
      }
    }
    FNeg(x) => {
      let x = find!(env, x)
      match x {
        Double(x) => Double(-x)
        _ => fail!("type mismatch, fneg expects Double")
      }
    }
    FAdd(x, y) => {
      let x = find!(env, x)
      let y = find!(env, y)
      match (x, y) {
        (Double(x), Double(y)) => Double(x + y)
        _ => fail!("type mismatch, fadd expects Double")
      }
    }
    FSub(x, y) => {
      let x = find!(env, x)
      let y = find!(env, y)
      match (x, y) {
        (Double(x), Double(y)) => Double(x - y)
        _ => fail!("type mismatch, fsub expects Double")
      }
    }
    FMul(x, y) => {
      let x = find!(env, x)
      let y = find!(env, y)
      match (x, y) {
        (Double(x), Double(y)) => Double(x * y)
        _ => fail!("type mismatch, fmul expects Double")
      }
    }
    FDiv(x, y) => {
      let x = find!(env, x)
      let y = find!(env, y)
      match (x, y) {
        (Double(x), Double(y)) => Double(x / y)
        _ => fail!("type mismatch, fdiv expects Double")
      }
    }
    IfEq(x, y, e1, e2) => {
      let x = find!(env, x)
      let y = find!(env, y)
      match (x, y) {
        (Int(x), Int(y)) =>
          if x == y {
            self.eval!(env, e1)
          } else {
            self.eval!(env, e2)
          }
        (Double(x), Double(y)) =>
          if x == y {
            self.eval!(env, e1)
          } else {
            self.eval!(env, e2)
          }
        _ => fail!("type mismatch, ifeq expects Int or Double")
      }
    }
    IfLe(x, y, e1, e2) => {
      let x = find!(env, x)
      let y = find!(env, y)
      match (x, y) {
        (Int(x), Int(y)) =>
          if x <= y {
            self.eval!(env, e1)
          } else {
            self.eval!(env, e2)
          }
        (Double(x), Double(y)) =>
          if x <= y {
            self.eval!(env, e1)
          } else {
            self.eval!(env, e2)
          }
        _ => fail!("type mismatch, ifle expects Int or Double")
      }
    }
    Let((x, _), e1, e2) => {
      let v = self.eval!(env, e1)
      let new_env = env.add(x, v)
      self.eval!(new_env, e2)
    }
    MakeClosure((n, _), c, e) => {
      let closure = self.functions
        .get(c.name._)
        .or_error!(Failure("closure not found"))
      let fv = []
      for x in c.actual_free_vars {
        fv.push(find!(env, x))
      }
      let new_env = env.add(n, Closure(closure, fv))
      self.eval!(new_env, e)
    }
    CallDirect(l, xs) => {
      let args = []
      for x in xs {
        args.push(find!(env, x))
      }
      match self.functions.get(l._) {
        Some(f) => self.eval_fn!(f, args, [])
        None => {
          let ext_fn = self.extern_fns
            .get(l._)
            .or_error!(
              Failure(
                "Given function \{l} is not found in both internal and external functions",
              ),
            )
          ext_fn(args)
        }
      }
    }
    CallClosure(n, xs) => {
      let closure = find!(env, n)
      let args = []
      for x in xs {
        args.push(find!(env, x))
      }
      match closure {
        Closure(f, fv) => self.eval_fn!(f, args, fv)
        _ => fail!("type mismatch, callclosure expects Closure")
      }
    }
    MakeTuple(xs) => {
      let vs = []
      for x in xs {
        vs.push(find!(env, x))
      }
      Tuple(vs)
    }
    LetTuple(xts, y, e) => {
      let mut new_env = env
      let y = find!(env, y)
      match y {
        Tuple(vs) => {
          let len = xts.length()
          if len != vs.length() {
            fail!("tuple size mismatch")
          }
          for i = 0; i < len; i = i + 1 {
            let (x, _) = xts[i]
            new_env = new_env.add(x, vs[i])
          }
        }
        _ => fail!("type mismatch, lettuple expects Tuple")
      }
      self.eval!(new_env, e)
    }
    ArrayGet(arr, idx) => {
      let arr = find!(env, arr)
      let idx = find!(env, idx)
      match (arr, idx) {
        (Array(arr), Int(idx)) => arr[idx]
        _ => fail!("type mismatch, get expects Array and Int")
      }
    }
    ArrayPut(arr, idx, v) => {
      let arr = find!(env, arr)
      let idx = find!(env, idx)
      let v = find!(env, v)
      match (arr, idx) {
        (Array(arr), Int(idx)) => arr[idx] = v
        _ => fail!("type mismatch, put expects Array and Int")
      }
      Unit
    }
    ExternalArray(_) => fail!("ExternalArray is not supported")
  }
}

///|
pub fn ClosureInterpreter::eval_fn(
  self : ClosureInterpreter,
  func : @closure.FuncDef,
  args : Array[Value],
  fv : Array[Value]
) -> Value!Failure {
  let mut env = @immut/hashmap.new()
  for i = 0; i < func.args.length(); i = i + 1 {
    let (x, _) = func.args[i]
    env = env.add(x, args[i])
  }
  for i = 0; i < func.formal_free_vars.length(); i = i + 1 {
    let (x, _) = func.formal_free_vars[i]
    env = env.add(x, fv[i])
  }
  env = env.add(func.old_name, Closure(func, fv))
  self.eval!(env, func.body)
}
