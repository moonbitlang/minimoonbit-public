pub struct Name {
  name : String?
  slot : Int
} derive(Eq, Hash, Compare)

pub impl Show for Name with output(self : Name, logger : Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub fn Name::to_string(self : Name) -> String {
  let { name, slot } = self
  match (name, slot) {
    (None, _) => "_\{slot}"
    (Some(name), 0) => name
    (Some(name), _) => "\{name}.\{slot}"
  }
}

pub fn Name::name_only(name : String) -> Name {
  { name: Some(name), slot: 0 }
}

pub fn Name::name_and_slot(name : String, slot : Int) -> Name {
  { name: Some(name), slot }
}

pub fn Name::slot_only(slot : Int) -> Name {
  { name: None, slot }
}
