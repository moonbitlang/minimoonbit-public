///|
struct KnfInterpreter {
  extern_fns : Map[String, (Array[Value]) -> Value]
  mut init_env : InterpreterLocalVars
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
  Closure(@knf.FuncDef, Ref[InterpreterLocalVars])
} derive(Show)

///|
pub fn Value::op_equal(self : Value, other : Value) -> Bool {
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
pub fn KnfInterpreter::new() -> KnfInterpreter {
  { extern_fns: Map::new(), init_env: InterpreterLocalVars::new() }
}

///|
pub fn KnfInterpreter::add_extern_fn(
  self : KnfInterpreter,
  name : String,
  f : (Array[Value]) -> Value
) -> Unit {
  self.extern_fns.set(name, f)
  self.init_env = self.init_env.add(Name::name_only(name), ExternFn(name))
}

///|
fn find(env : InterpreterLocalVars, name : Name) -> Value!Failure {
  env.find(name).or_error!(Failure("variable not found: \{name}"))
}

///|
pub fn KnfInterpreter::eval_full(
  self : KnfInterpreter,
  expr : @knf.Knf
) -> Value!Failure {
  self.eval!(self.init_env, expr)
}

///|
pub fn KnfInterpreter::eval(
  self : KnfInterpreter,
  env : InterpreterLocalVars,
  expr : @knf.Knf
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
    LetRec(f, e) => {
      let f_env = Ref::new(env)
      let new_env = env.add(f.name, Closure(f, f_env))
      f_env.val = new_env
      self.eval!(new_env, e)
    }
    Apply(f, xs) => {
      let f = find!(env, f)
      match f {
        Closure(f, f_env) => {
          let mut new_env = f_env.val
          for i = 0; i < f.args.length(); i = i + 1 {
            let (x, _) = f.args[i]
            new_env = new_env.add(x, find!(env, xs[i]))
          }
          self.eval!(new_env, f.body)
        }
        ExternFn(name) => {
          let args = []
          for x in xs {
            args.push(find!(env, x))
          }
          let f = self.extern_fns
            .get(name)
            .or_error!(Failure("extern fn not found \{name}"))
          f(args)
        }
        _ => fail!("type mismatch, apply expects Closure or ExternFn")
      }
    }
    Tuple(xs) => {
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
    Get(arr, idx) => {
      let arr = find!(env, arr)
      let idx = find!(env, idx)
      match (arr, idx) {
        (Array(arr), Int(idx)) => arr[idx]
        _ => fail!("type mismatch, get expects Array and Int")
      }
    }
    Put(arr, idx, v) => {
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
    ExternalFunctionApplication(name, args) => {
      let f = self.extern_fns
        .get(name)
        .or_error!(Failure("extern fn not found \{name}"))
      let argv = []
      for x in args {
        argv.push(find!(env, x))
      }
      f(argv)
    }
  }
}
