///|
struct PrettyKnf {
  knf : Knf
}

///|
pub fn Knf::to_pretty_print(self : Knf) -> PrettyKnf {
  { knf: self }
}

///|
fn PrettyKnf::print_one_level(
  self : PrettyKnf,
  logger : @util.IndentLogger,
  val : Knf
) -> Unit {
  match val {
    Unit => logger.write_string("Unit")
    Int(i) => logger.write_string("Int(\{i})")
    Double(d) => logger.write_string("Double(\{d})")
    Neg(e) => logger.write_string("Neg(\{e})")
    Var(name) => logger.write_string("Var(\{name})")
    Add(e1, e2) => logger.write_string("Add(\{e1}, \{e2})")
    Sub(e1, e2) => logger.write_string("Sub(\{e1}, \{e2})")
    Mul(e1, e2) => logger.write_string("Mul(\{e1}, \{e2})")
    Div(e1, e2) => logger.write_string("Div(\{e1}, \{e2})")
    FNeg(e) => logger.write_string("FNeg(\{e})")
    FAdd(e1, e2) => logger.write_string("FAdd(\{e1}, \{e2})")
    FSub(e1, e2) => logger.write_string("FSub(\{e1}, \{e2})")
    FMul(e1, e2) => logger.write_string("FMul(\{e1}, \{e2})")
    FDiv(e1, e2) => logger.write_string("FDiv(\{e1}, \{e2})")
    IfEq(e1, e2, e3, e4) => {
      logger.write_string("if (\{e1} == \{e2}) then {")
      logger.indent()
      logger.write_string("\n")
      self.print_one_level(logger, e3)
      logger.outdent()
      logger.write_string("\n")
      logger.write_string("} else {")
      logger.indent()
      logger.write_string("\n")
      self.print_one_level(logger, e4)
      logger.outdent()
      logger.write_string("\n}")
    }
    IfLe(e1, e2, e3, e4) => {
      logger.write_string("if (\{e1} <= \{e2}) then {")
      logger.indent()
      logger.write_string("\n")
      self.print_one_level(logger, e3)
      logger.outdent()
      logger.write_string("\n")
      logger.write_string("} else {")
      logger.indent()
      logger.write_string("\n")
      self.print_one_level(logger, e4)
      logger.outdent()
      logger.write_string("\n}")
    }
    Let((name, ty), e1, e2) => {
      logger.write_string("let \{name}: \{ty} = ")
      match e1 {
        Let(_) | LetRec(_) | LetTuple(_, _, _) => {
          logger.write_string("\n")
          logger.indent()
          self.print_one_level(logger, e1)
          logger.outdent()
        }
        _ => self.print_one_level(logger, e1)
      }
      logger.write_string("\n")
      self.print_one_level(logger, e2)
    }
    LetTuple(name_types, y, e) => {
      logger.write_string("let (")
      let mut first = true
      for nt in name_types {
        if first {
          first = false
          logger.write_string(", ")
        }
        let (name, ty) = nt
        logger.write_string("\{name}: \{ty}")
      }
      logger.write_string(") = \{y}")
      self.print_one_level(logger, e)
    }
    LetRec(fundef, e) => {
      let { name, ty, args, body } = fundef
      logger.write_string("let rec \{name}: \{ty} = (")
      let mut first = true
      for arg in args {
        let (arg_name, arg_ty) = arg
        if first {
          first = false
        } else {
          logger.write_string(", ")
        }
        logger.write_string("\{arg_name}: \{arg_ty}")
      }
      logger.write_string(") {")
      logger.indent()
      logger.write_string("\n")
      self.print_one_level(logger, body)
      logger.outdent()
      logger.write_string("\n}\n")
      self.print_one_level(logger, e)
    }
    Apply(name, args) => {
      logger.write_string("Apply(\{name}, [")
      for arg in args {
        logger.write_string(arg.to_string())
        logger.write_string(", ")
      }
      logger.write_string("])")
    }
    Tuple(es) => {
      logger.write_string("Tuple([")
      for e in es {
        logger.write_string(e.to_string())
        logger.write_string(", ")
      }
      logger.write_string("])")
    }
    Put(e1, e2, e3) => logger.write_string("Put \{e1}[\{e2}] = \{e3}")
    Get(e1, e2) => logger.write_string("Get \{e1}[\{e2}]")
    ExternalArray(name) => logger.write_string("ExternalArray(\{name})")
    ExternalFunctionApplication(name, args) => {
      logger.write_string("ExtApply(\{name}, [")
      for arg in args {
        logger.write_string(arg.to_string())
        logger.write_string(", ")
      }
      logger.write_string("])")
    }
  }
}

///|
pub impl Show for PrettyKnf with output(self : PrettyKnf, logger : Logger) -> Unit {
  let indent_logger = @util.IndentLogger::new(logger)
  self.print_one_level(indent_logger, self.knf)
}
