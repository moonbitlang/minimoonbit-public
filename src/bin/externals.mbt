fn add_interpreter_fns(interpreter : @knf_eval.KnfInterpreter) -> Unit {
  interpreter.add_extern_fn(
    "minimbt_print_int",
    fn(args) {
      match args[0] {
        Int(i) => @io.print(i)
        _ => @util.die("print_int expects Int")
      }
      Unit
    },
  )
  interpreter.add_extern_fn(
    "minimbt_print_endline",
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
  interpreter.add_extern_fn("minimbt_create_array", create_array)
  interpreter.add_extern_fn("minimbt_create_float_array", create_array)
  interpreter.add_extern_fn("minimbt_create_ptr_array", create_array)
  interpreter.add_extern_fn(
    "minimbt_truncate",
    fn(args) {
      match args[0] {
        Double(d) => Int(d.to_int())
        _ => @util.die("truncate expects Double")
      }
    },
  )
  interpreter.add_extern_fn(
    "minimbt_sin",
    fn(args) {
      match args[0] {
        Double(d) => Double(@math.sin(d))
        _ => @util.die("sin expects Double")
      }
    },
  )
  interpreter.add_extern_fn(
    "minimbt_cos",
    fn(args) {
      match args[0] {
        Double(d) => Double(@math.cos(d))
        _ => @util.die("cos expects Double")
      }
    },
  )
  interpreter.add_extern_fn(
    "minimbt_sqrt",
    fn(args) {
      match args[0] {
        Double(d) => Double(d.sqrt())
        _ => @util.die("sqrt expects Double")
      }
    },
  )
  interpreter.add_extern_fn(
    "minimbt_abs_float",
    fn(args) {
      match args[0] {
        Double(d) => Double(@double.abs(d))
        _ => @util.die("abs_float expects Double")
      }
    },
  )
  interpreter.add_extern_fn(
    "minimbt_int_of_float",
    fn(args) {
      match args[0] {
        Double(d) => Int(d.to_int())
        _ => @util.die("int_of_float expects Double")
      }
    },
  )
  interpreter.add_extern_fn(
    "minimbt_float_of_int",
    fn(args) {
      match args[0] {
        Int(i) => Double(i.to_double())
        _ => @util.die("float_of_int expects Int")
      }
    },
  )
}

fn add_closure_interpreter_fns(
  interpreter : @closure_eval.ClosureInterpreter
) -> Unit {
  interpreter.add_extern_fn(
    "minimbt_print_int",
    fn(args) {
      match args[0] {
        Int(i) => @io.print(i)
        _ => @util.die("print_int expects Int")
      }
      Unit
    },
  )
  interpreter.add_extern_fn(
    "minimbt_print_endline",
    fn(_args) {
      @io.print("\n")
      Unit
    },
  )
  let create_array = fn(args : Array[@closure_eval.Value]) {
    match args[0] {
      Int(n) => @closure_eval.Value::Array(Array::make(n, args[1]))
      _ => @util.die("create_array expects Int")
    }
  }
  interpreter.add_extern_fn("minimbt_create_array", create_array)
  interpreter.add_extern_fn("minimbt_create_float_array", create_array)
  interpreter.add_extern_fn("minimbt_create_ptr_array", create_array)
  interpreter.add_extern_fn(
    "minimbt_truncate",
    fn(args) {
      match args[0] {
        Double(d) => Int(d.to_int())
        _ => @util.die("truncate expects Double")
      }
    },
  )
  interpreter.add_extern_fn(
    "minimbt_sin",
    fn(args) {
      match args[0] {
        Double(d) => Double(@math.sin(d))
        _ => @util.die("sin expects Double")
      }
    },
  )
  interpreter.add_extern_fn(
    "minimbt_cos",
    fn(args) {
      match args[0] {
        Double(d) => Double(@math.cos(d))
        _ => @util.die("cos expects Double")
      }
    },
  )
  interpreter.add_extern_fn(
    "minimbt_sqrt",
    fn(args) {
      match args[0] {
        Double(d) => Double(d.sqrt())
        _ => @util.die("sqrt expects Double")
      }
    },
  )
  interpreter.add_extern_fn(
    "minimbt_abs_float",
    fn(args) {
      match args[0] {
        Double(d) => Double(@double.abs(d))
        _ => @util.die("abs_float expects Double")
      }
    },
  )
  interpreter.add_extern_fn(
    "minimbt_int_of_float",
    fn(args) {
      match args[0] {
        Double(d) => Int(d.to_int())
        _ => @util.die("int_of_float expects Double")
      }
    },
  )
  interpreter.add_extern_fn(
    "minimbt_float_of_int",
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
  .add("read_int", @types.Fun([], Int))
  .add("read_char", @types.Fun([], Int))
  .add("print_int", @types.Fun([Int], Unit))
  .add("print_char", @types.Fun([Int], Unit))
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
