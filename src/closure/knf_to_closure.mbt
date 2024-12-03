///|
pub typealias LocalEnv = @immut/hashmap.T[Name, LowType]

///|
pub fn knf_program_to_closure(
  _prog : @knf.Knf,
  _extern_env : Map[String, Type]
) -> Program {
  abort("todo")
}
