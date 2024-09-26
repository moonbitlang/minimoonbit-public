typealias Name = String

enum Ast {
  Var(Name)
  Int(Int)
  Add(Ast, Ast)
  Mul(Ast, Ast)
  Let(Name, Ast, Ast)
  If(Ast, Ast, Ast)
} derive(Eq, Show)

enum Knf {
  Var(Name)
  Int(Int)
  Add(Name, Name)
  Mul(Name, Name)
  Let(Name, Knf, Knf)
  If(Name, Knf, Knf)
} derive(Eq, Show)

pub struct AstToKnfEnv {
  mut counter : Int
}

pub fn AstToKnfEnv::new() -> AstToKnfEnv {
  { counter: 0 }
}

/// Generate a fresh variable name
fn AstToKnfEnv::fresh(self : AstToKnfEnv) -> Name {
  let name = "x\{self.counter}"
  self.counter += 1
  name
}

pub fn ast_to_knf(env : AstToKnfEnv, ast : Ast) -> Knf {
  match ast {
    // Trivial cases
    Var(name) => Knf::Var(name)
    Int(i) => Knf::Int(i)
    Add(a, b) => {
      let a_name = env.fresh()
      let b_name = env.fresh()

      // let a_name = <a> in
      // let b_name = <b> in
      // a_name + b_name
      Knf::Let(
        a_name,
        ast_to_knf(env, a),
        Knf::Let(b_name, ast_to_knf(env, b), Knf::Add(a_name, b_name)),
      )
    }
    Mul(a, b) => {
      let a_name = env.fresh()
      let b_name = env.fresh()

      // let a_name = <a> in
      // let b_name = <b> in
      // a_name * b_name
      Knf::Let(
        a_name,
        ast_to_knf(env, a),
        Knf::Let(b_name, ast_to_knf(env, b), Knf::Mul(a_name, b_name)),
      )
    }
    Let(name, value, body) =>
      // let name = <value> in
      // <body>
      Knf::Let(name, ast_to_knf(env, value), ast_to_knf(env, body))
    If(cond, then, els) => {
      let cond_name = env.fresh()

      // let cond_name = <cond> in
      // if cond_name then <then> else <els>
      Knf::Let(
        cond_name,
        ast_to_knf(env, cond),
        Knf::If(cond_name, ast_to_knf(env, then), ast_to_knf(env, els)),
      )
    }
  }
}

fn main {
  let ast = Ast::Add(Ast::Int(1), Ast::Int(2))
  let knf = Knf::Let(
    "x0",
    Knf::Int(1),
    Knf::Let("x1", Knf::Int(2), Knf::Add("x0", "x1")),
  )
  if ast_to_knf(AstToKnfEnv::new(), ast) == knf {
    println("Test passed")
  } else {
    println("Test failed")
  }

  // A more complex example
  let ast = Ast::Let(
    "x",
    Ast::Int(1),
    Ast::If(
      Ast::Var("x"),
      Ast::Add(Ast::Var("x"), Ast::Int(2)),
      Ast::Mul(Ast::Var("x"), Ast::Int(2)),
    ),
  )
  let knf = ast_to_knf(AstToKnfEnv::new(), ast)
  println(knf)
  // Let("x", Int(1),
  // Let("x0", Var("x"), 
  //   If("x0", 
  //     Let("x1", Var("x"), 
  //     Let("x2", Int(2), 
  //       Add("x1", "x2"))),
  //     Let("x3", Var("x"),
  //     Let("x4", Int(2), 
  //       Mul("x3", "x4"))))))
}
