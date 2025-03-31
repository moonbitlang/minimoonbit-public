///|
pub fn i32_to_hex(v : Int) -> String {
  let buf = @buffer.new()
  buf.write_string("0x")
  for i = 7; i >= 0; i = i - 1 {
    let nibble = (v >> (i * 4)) & 0xf
    if nibble < 10 {
      buf.write_char(Char::from_int('0'.to_int() + nibble))
    } else {
      buf.write_char(Char::from_int('a'.to_int() + nibble - 10))
    }
  }
  buf.contents().to_unchecked_string()
}

///|
pub fn i64_to_hex(v : Int64) -> String {
  let buf = @buffer.new()
  buf.write_string("0x")
  for i = 15; i >= 0; i = i - 1 {
    let nibble = (v >> (i * 4)) & 0xf
    if nibble < 10 {
      buf.write_char(Char::from_int('0'.to_int() + nibble.to_int()))
    } else {
      buf.write_char(Char::from_int('a'.to_int() + nibble.to_int() - 10))
    }
  }
  buf.contents().to_unchecked_string()
}
