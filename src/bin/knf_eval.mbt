fn main {
  let argv = @env.get_args()
  let mut file = None
  let no_run = Ref::new(false)
  let print_ast = Ref::new(false)
  let print_knf = Ref::new(false)
  let print_each_knf = Ref::new(false)
  let print_final_knf = Ref::new(false)
  let print_closure_ir = Ref::new(false)
  let print_asm = Ref::new(false)
  let knf_opt_iters = Ref::new(10)
  let run_with_interpreter = Ref::new(false)
  @ArgParser.parse(
    [
      (
        "--interpret",
        "-i",
        @ArgParser.Set(run_with_interpreter),
        "Run with interpreter",
      ),
      ("--print-ast", "", @ArgParser.Set(print_ast), "Print AST"),
      ("--no-run", "", @ArgParser.Set(no_run), "Do not run the program"),
      ("--print-knf", "", @ArgParser.Set(print_knf), "Print initial KNF"),
      (
        "--print-each-knf",
        "",
        @ArgParser.Set(print_each_knf),
        "Print each KNF in optimization",
      ),
      (
        "--print-final-knf",
        "",
        @ArgParser.Set(print_final_knf),
        "Print final KNF",
      ),
      (
        "--print-closure-ir",
        "",
        @ArgParser.Set(print_closure_ir),
        "Print closure IR",
      ),
      ("--print-asm", "", @ArgParser.Set(print_asm), "Print assembly"),
      (
        "--knf-opt-iters",
        "N",
        @ArgParser.String(
          fn(s) {
            let i = @strconv.parse_int?(s)
            match i {
              Ok(i) => knf_opt_iters.val = i
              Err(e) => @util.die("Invalid number")
            }
          },
        ),
        "Number of optimization iterations",
      ),
    ],
    fn(s) {
      if file.is_empty().not() {
        @util.die("multiple files are given")
      }
      file = Some(s)
    },
    "",
    argv,
  )

  // Input
  let file = if file.is_empty() {
    println("no input file")
    @util.die("no input file")
  } else {
    file.unwrap()
  }
  let contents = @fs.read_to_string(file)
  let typechecked = to_typecheked(contents)
  if print_ast.val {
    println(typechecked.to_string())
  }

  // To KNF
  let external_fns = externals()
  let knf_env = @knf.KnfEnv::new(external_fns)
  let knf = knf_env.to_knf(typechecked)
  if print_knf.val {
    println("Initial KNF:")
    println(knf.to_pretty_print())
  }

  // Optimization
  let mut knf = knf
  for i = 0; i < knf_opt_iters.val; i = i + 1 {
    let new_knf = knf_env.opt_pass(knf)
    if new_knf == knf {
      break
    }
    knf = new_knf
    if print_each_knf.val {
      println("KNF Iteration \{i}:")
      println(knf.to_pretty_print())
    }
  }
  if print_final_knf.val || no_run.val {
    println("Final KNF:")
    println(knf.to_pretty_print())
  }

  // Interpretation
  if run_with_interpreter.val {
    if no_run.val {
      return
    }
    let interpreter = @knf_eval.KnfInterpreter::new()
    add_interpreter_fns(interpreter)
    let _result = match interpreter.eval_full?(knf) {
      Ok(result) => result
      Err(Failure(e)) => {
        println("Error: " + e)
        @util.die("Evaluation error")
      }
    }
    return
  }

  // KNF to closure
  let closure_ir = @closure.knf_program_to_closure(
    knf,
    Map::from_iter(external_fns.iter()),
  )
  if print_closure_ir.val {
    println("Closure IR:")
    println(closure_ir.to_string())
  }

  // Fill in the holes here!

  // Code generation
  let real_asm = @riscv.emit(abort("TODO"))

  // Print asm
  for asm in real_asm {
    println(asm)
    println("")
  }
}

fn to_typecheked(source : String) -> @types.Syntax {
  abort("todo")
}

fn add_interpreter_fns(interpreter : @knf_eval.KnfInterpreter) -> Unit {
  interpreter.add_extern_fn(
    "print_int",
    fn(args) {
      match args[0] {
        Int(i) => @io.print(i)
        _ => @util.die("print_int expects Int")
      }
      Unit
    },
  )
  interpreter.add_extern_fn(
    "print_endline",
    fn(_args) {
      @io.print("\n")
      Unit
    },
  )
  let create_array = fn(args : Array[@knf_eval.Value]) {
    match args[0] {
      Int(n) => @knf_eval.Value::Array(Array::make(n, args[1]))
      _ => @util.die("create_array expects Int")
    }
  }
  interpreter.add_extern_fn("create_array", create_array)
  interpreter.add_extern_fn("create_float_array", create_array)
  interpreter.add_extern_fn("create_ptr_array", create_array)
  interpreter.add_extern_fn(
    "truncate",
    fn(args) {
      match args[0] {
        Double(d) => Int(d.to_int())
        _ => @util.die("truncate expects Double")
      }
    },
  )
  interpreter.add_extern_fn(
    "sin",
    fn(args) {
      match args[0] {
        Double(d) => Double(@math.sin(d))
        _ => @util.die("sin expects Double")
      }
    },
  )
  interpreter.add_extern_fn(
    "cos",
    fn(args) {
      match args[0] {
        Double(d) => Double(@math.cos(d))
        _ => @util.die("cos expects Double")
      }
    },
  )
  interpreter.add_extern_fn(
    "sqrt",
    fn(args) {
      match args[0] {
        Double(d) => Double(d.sqrt())
        _ => @util.die("sqrt expects Double")
      }
    },
  )
  interpreter.add_extern_fn(
    "abs_float",
    fn(args) {
      match args[0] {
        Double(d) => Double(@double.abs(d))
        _ => @util.die("abs_float expects Double")
      }
    },
  )
  interpreter.add_extern_fn(
    "int_of_float",
    fn(args) {
      match args[0] {
        Double(d) => Int(d.to_int())
        _ => @util.die("int_of_float expects Double")
      }
    },
  )
  interpreter.add_extern_fn(
    "float_of_int",
    fn(args) {
      match args[0] {
        Int(i) => Double(i.to_double())
        _ => @util.die("float_of_int expects Int")
      }
    },
  )
}

fn externals() -> @immut/hashmap.T[String, @types.Type] {
  @immut/hashmap.T::new()
  .add("print_int", @types.Fun([Int], Unit))
  .add("print_endline", @types.Fun([], Unit))
  .add("create_array", @types.Fun([Int, Int], @types.Type::Array(Int)))
  .add(
    "create_float_array",
    @types.Fun([Int, Double], @types.Type::Array(Double)),
  )
  .add("create_ptr_array", @types.Fun([Int, Ptr], @types.Type::Array(Ptr)))
  .add("truncate", @types.Fun([Double], Int))
  .add("sin", @types.Fun([Double], Double))
  .add("cos", @types.Fun([Double], Double))
  .add("sqrt", @types.Fun([Double], Double))
  .add("abs_float", @types.Fun([Double], Double))
  .add("int_of_float", @types.Fun([Double], Int))
  .add("float_of_int", @types.Fun([Int], Double))
}
