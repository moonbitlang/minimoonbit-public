///|
pub fn emit(
  _input : Unit // TODO
) -> Array[AssemblyFunction] {
  abort("todo")
}

///|
pub(all) struct AssemblyFunction {
  name : String
  export : Bool
  body : Array[RvAsm]
}

///|
pub fn AssemblyFunction::output(
  self : AssemblyFunction,
  logger : Logger
) -> Unit {
  let name = self.name
  if self.export {
    logger.write_string(".global \{name}\n")
  }
  logger.write_string("\{name}:\n")
  for asm in self.body {
    Show::output(asm, logger)
    logger.write_string("\n")
  }
}
