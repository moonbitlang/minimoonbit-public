pub enum Expr {
  Cst(Int)
  Add(Expr, Expr)
  Mul(Expr, Expr)
  Var(String)
  Let(String, Expr, Expr)
}

// -------------- Tiny Language 2 --------------
pub type Env @immut/list.T[Int]

pub type Cenv @immut/list.T[String]

pub enum ExprNameless {
  Cst(Int)
  Add(ExprNameless, ExprNameless)
  Mul(ExprNameless, ExprNameless)
  Var(Int)
  Let(ExprNameless, ExprNameless)
}

pub fn index[T : Eq](l : @immut/list.T[T], v : T, ~acc : Int = 0) -> Int? {
  match l {
    Nil => None
    Cons(x, xs) => if x == v { Some(acc) } else { index(xs, v, acc=acc + 1) }
  }
}

pub fn comp(e : Expr, cenv : Cenv) -> ExprNameless {
  match e {
    Cst(i) => Cst(i)
    Add(a, b) => Add(comp(a, cenv), comp(b, cenv))
    Mul(a, b) => Mul(comp(a, cenv), comp(b, cenv))
    Var(x) => Var(index(cenv.0, x).unwrap())
    Let(x, e1, e2) => Let(comp(e1, cenv), comp(e2, Cons(x, cenv.0)))
  }
}

pub fn eval(e : ExprNameless, env : Env) -> Int {
  match e {
    Cst(i) => i
    Add(a, b) => eval(a, env) + eval(b, env)
    Mul(a, b) => eval(a, env) * eval(b, env)
    Var(n) => env.0.nth(n).unwrap()
    Let(e1, e2) => eval(e2, Cons(eval(e1, env), env.0))
  }
}
// ---------------------------------------------

// -------------- Tiny Langauge 1 --------------
pub type EnvTL1 @immut/list.T[(String, Int)]

pub fn assoc[K : Eq, V](key : K, assoc_lst : @immut/list.T[(K, V)]) -> V? {
  match assoc_lst {
    Nil => None
    Cons((k, v), xs) => if k == key { Some(v) } else { assoc(key, xs) }
  }
}

pub fn eval_tl1(expr : Expr, env : EnvTL1) -> Int {
  match (expr, env) {
    (Cst(i), _) => i
    (Add(a, b), _) => eval_tl1(a, env) + eval_tl1(b, env)
    (Mul(a, b), _) => eval_tl1(a, env) * eval_tl1(b, env)
    (Var(x), EnvTL1(env)) => assoc(x, env).unwrap()
    (Let(x, e1, e2), EnvTL1(env)) =>
      eval_tl1(e2, Cons((x, eval_tl1(e1, env)), env))
  }
}
// ---------------------------------------------

// -------------- Stack Machine --------------
pub enum Instr {
  Cst(Int)
  Add
  Mul
  Var(Int)
  Pop
  Swap
}

pub type Instrs @immut/list.T[Instr]

pub type Operand Int

pub type Stack @immut/list.T[Operand]

pub fn eval_stack_machine(instrs : Instrs, stk : Stack) -> Int {
  match (instrs.0, stk.0) {
    (Cons(Cst(i), rest), _) => eval_stack_machine(rest, Cons(i, stk.0))
    (Cons(Add, rest), Cons(Operand(a), Cons(Operand(b), stk))) =>
      eval_stack_machine(rest, Cons(a + b, stk))
    (Cons(Mul, rest), Cons(Operand(a), Cons(Operand(b), stk))) =>
      eval_stack_machine(rest, Cons(a * b, stk))
    (Nil, Cons(Operand(a), _)) => a
    _ => abort("Matched none")
  }
}
// ---------------------------------------------
