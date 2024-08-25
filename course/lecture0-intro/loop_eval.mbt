enum Instr {
  Cst(Int)
  Add
  Mul
} // non-recursive

typealias Instrs = @immut/list.T[Instr]

typealias Operand = Int

typealias Stack = @immut/list.T[Operand]

fn loop_eval(instrs : Instrs, stk : Stack) -> Int {
  loop instrs, stk {
    Cons(Cst(i), rest), stk => continue rest, Cons(i, stk)
    Cons(Add, rest), Cons(a, Cons(b, stk)) => continue rest, Cons(a + b, stk)
    Cons(Mul, rest), Cons(a, Cons(b, stk)) => continue rest, Cons(a * b, stk)
    Nil, Cons(a, _) => a
    _, _ => abort("Matched none")
  }
}
