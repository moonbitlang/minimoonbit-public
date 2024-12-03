///|
struct IndentLogger {
  logger : Logger
  mut indent : Int
  mut line_start : Bool
}

///|
pub fn IndentLogger::new(logger : Logger) -> IndentLogger {
  IndentLogger::{ logger, indent: 0, line_start: true }
}

///|
fn IndentLogger::print_indent(self : IndentLogger) -> Unit {
  for i = 0; i < self.indent; i = i + 1 {
    self.logger.write_string("  ")
  }
}

///|
pub fn IndentLogger::indent(self : IndentLogger) -> Unit {
  self.indent += 1
}

///|
pub fn IndentLogger::outdent(self : IndentLogger) -> Unit {
  self.indent -= 1
}

///|
pub impl Logger for IndentLogger with write_substring(
  self : IndentLogger,
  s : String,
  start : Int,
  len : Int
) -> Unit {
  // Find the next newline character
  let mut start = start
  let mut curr = start
  let end = start + len
  while curr < end {
    if self.line_start {
      self.print_indent()
      self.line_start = false
    }
    if s[curr] == '\n' {
      self.logger.write_sub_string(s, start, curr - start)
      self.logger.write_char('\n')
      self.line_start = true
      start = curr + 1
    }
    curr += 1
  }
  if self.line_start && start < end {
    self.print_indent()
    self.line_start = false
  }
  self.logger.write_sub_string(s, start, end - start)
}

///|
pub impl Logger for IndentLogger with write_char(self : IndentLogger, c : Char) -> Unit {
  if c == '\n' {
    self.logger.write_char(c)
    self.line_start = true
  } else {
    if self.line_start {
      self.print_indent()
      self.line_start = false
    }
    self.logger.write_char(c)
  }
}

///|
pub fn IndentLogger::write_string(self : IndentLogger, s : String) -> Unit {
  Logger::write_sub_string(self, s, 0, s.length())
}
