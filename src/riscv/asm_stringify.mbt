pub fn asm_stringify(asm : AssemblyFunction) -> String {
  let buf = Buffer::new()
  let name = asm.name
  buf.write_string("\{name}:\n")
  for inst in asm.body {
    Show::output(inst, buf)
  }
  buf.write_string("\n")
  buf.to_string()
}
