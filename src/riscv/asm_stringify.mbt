///|
pub fn print_functions(asm : Array[AssemblyFunction]) -> String {
  let logger = @buffer.new()
  for f in asm {
    f.output(logger)
    logger.write_string("\n")
  }
  logger.contents().to_unchecked_string()
}
