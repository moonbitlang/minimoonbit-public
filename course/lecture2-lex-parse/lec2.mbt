struct Context {
  str : String
  mut offset : Int
  array : Array[Token]
}

fn lex(context : Context) -> Unit {
  let { offset, str, array } = context
  if offset >= str.length() {
    return
  }
  match str[offset] {
    '+' => {
      array.push(Add)
      context.offset += 1
      lex(context)
    }
    '-' => {
      array.push(Sub)
      context.offset += 1
      lex(context)
    }
    '*' => {
      array.push(Mul)
      context.offset += 1
      lex(context)
    }
    '/' => {
      array.push(Div)
      context.offset += 1
      lex(context)
    }
    '(' => {
      array.push(LParen)
      context.offset += 1
      lex(context)
    }
    ')' => {
      array.push(RParen)
      context.offset += 1
      lex(context)
    }
    ' ' | '\n' | '\t' | '\r' => {
      context.offset += 1
      lex(context)
    }
    ch => if ch >= '0' && ch <= '9' { lex_number(context) } else { panic() }
  }
}

fn lex_number(context : Context) -> Unit {
  let { offset, str, .. } = context
  let number = "\{str[offset]}"
  context.offset += 1
  lex_number_rest(context, number)
}

fn lex_number_rest(context : Context, number : String) -> Unit {
  let { offset, str, array } = context
  if offset >= str.length() {
    array.push(Number(@strconv.parse_int?(number).unwrap()))
    return
  }
  let ch = str[offset]
  if ch >= '0' && ch <= '9' {
    context.offset += 1
    lex_number_rest(context, number + ch.to_string())
  } else {
    array.push(Number(@strconv.parse_int?(number).unwrap()))
    lex(context)
  }
}

test {
  let array = []
  lex({ str: "-10123 -+ - 523 103 (5))", offset: 0, array })
  inspect!(
    array,
    content="[Sub, Number(10123), Sub, Add, Sub, Number(523), Number(103), LParen, Number(5), RParen, RParen]",
  )
}

enum Token {
  Number(Int)
  LParen
  RParen
  Add
  Sub
  Mul
  Div
} derive(Show)

enum Expression {
  Number(Int)
  Plus(Expression, Expression)
  Minus(Expression, Expression)
  Multiply(Expression, Expression)
  Divide(Expression, Expression)
} derive(Show)

type Parser[V] (ArrayView[Token]) -> (V, ArrayView[Token])?

fn parse[V](
  self : Parser[V],
  tokens : ArrayView[Token]
) -> (V, ArrayView[Token])? {
  (self._)(tokens)
}

fn ptoken(predicate : (Token) -> Bool) -> Parser[Token] {
  fn {
    [hd, .. as tl] => if predicate(hd) { Some((hd, tl)) } else { None }
    [] => None
  }
}

fn map[I, O](self : Parser[I], f : (I) -> O) -> Parser[O] {
  fn {
    input =>
      match self.parse(input) {
        Some((token, rest)) => Some((f(token), rest))
        None => None
      }
  }
}

fn and[V1, V2](self : Parser[V1], parser2 : Parser[V2]) -> Parser[(V1, V2)] {
  fn {
    input =>
      self
      .parse(input)
      .bind(
        fn {
          (value, rest) =>
            parser2
            .parse(rest)
            .map(fn { (value2, rest2) => ((value, value2), rest2) })
        },
      )
  }
}

fn or[Value](self : Parser[Value], parser2 : Parser[Value]) -> Parser[Value] {
  fn {
    input =>
      match self.parse(input) {
        None => parser2.parse(input)
        Some(_) as result => result
      }
  }
}

fn many[Value : Show](self : Parser[Value]) -> Parser[Array[Value]] {
  fn(input) {
    let cumul = []
    let mut rest = input
    println("Many")
    println(input)
    println(self.parse(input))
    loop self.parse(input) {
      None => Some((cumul, rest))
      Some((v, rest_)) => {
        println("Many")
        println(rest_)
        println(self.parse(rest_))
        cumul.push(v)
        rest = rest_
        continue self.parse(rest_)
      }
    }
  }
}

fn Parser::ref[Value](ref : Ref[Parser[Value]]) -> Parser[Value] {
  fn(input) { ref.val.parse(input) }
}

let lparen : Parser[Token] = ptoken(
  fn {
    LParen => true
    _ => false
  },
)

let rparen : Parser[Token] = ptoken(
  fn {
    RParen => true
    _ => false
  },
)

let number : Parser[Expression] = ptoken(
  fn {
    Token::Number(_) => true
    _ => false
  },
).map(fn { Number(value) => Expression::Number(value) })

// 定义互递归函数
// atomic = Value / "(" expression ")"
fn atomic(tokens : ArrayView[Token]) -> (Expression, ArrayView[Token])? {
  lparen
  .and(
    expression, // 引用函数
  )
  .and(rparen)
  .map(fn { ((_, expr), _) => expr })
  .or(number)
  .parse(tokens)
}

fn combine(tokens : ArrayView[Token]) -> (Expression, ArrayView[Token])? {
  Parser(atomic)
  .and(
    ptoken(
      fn {
        Mul | Div => true
        _ => false
      },
    )
    .and(atomic)
    .many(),
  )
  .map(
    fn {
      (e, list) => {
        println("fold: \{e} \{list}")
        list.fold(
          init=e,
          fn {
            e, (Mul, expr) => Multiply(e, expr)
            e, (_, expr) => Divide(e, expr)
          },
        )
      }
    },
  )
  .parse(tokens)
}

fn expression(tokens : ArrayView[Token]) -> (Expression, ArrayView[Token])? {
  Parser(combine)
  .and(
    ptoken(
      fn {
        Add | Sub => true
        _ => false
      },
    )
    .and(combine)
    .many(),
  )
  .map(
    fn {
      (e, list) => {
        let result = list.fold(
          init=e,
          fn {
            e, (Add, expr) => Plus(e, expr)
            e, (_, expr) => Minus(e, expr)
          },
        )
        println("fold: \{e} \{list} -> \{result}")
        result
      }
    },
  )
  .parse(tokens)
}

let parser : Parser[Expression] = Parser(expression)

test {
  let input = "1 + 2 - 3"
  let tokens = []
  lex({ str: input, offset: 0, array: tokens })
  inspect!(tokens, content="[Number(1), Add, Number(2), Sub, Number(3)]")
  let (expr, _) = parser.parse(tokens[:]).unwrap()
  inspect!(expr, content="Minus(Plus(Number(1), Number(2)), Number(3))")
  let input = "1 + 2 * 3 - 6"
  let tokens = []
  lex({ str: input, offset: 0, array: tokens })
  inspect!(
    tokens,
    content="[Number(1), Add, Number(2), Mul, Number(3), Sub, Number(6)]",
  )
  let (expr, _) = parser.parse(tokens[:]).unwrap()
  inspect!(
    expr,
    content="Minus(Plus(Number(1), Multiply(Number(2), Number(3))), Number(6))",
  )
}

// fn pparser() -> Parser[Expression] {
//   // 首先定义空引用
//   let expression_ref : Ref[Parser[Expression]] = { val : fn{ _ => None } }

//   // atomic : Number | LParen expr RParen;
//   let atomic =  // 利用引用定义
//     (lparen.and(ref(expression_ref)).and(rparen).map(fn { ((_, expr), _) => expr}))
//       .or(number)

//   // combine : atomic ( (Mul | Div) atomic)*;
//   let combine = atomic.and(multiply.or(divide).and(atomic).many()).map(fn {
//     ...
//   })

//   // expression : combine ( (Add | Sub) combine)*;
//   expression_ref.val = combine.and(plus.or(minus).and(combine).many()).map(fn {
//     ...
//   })

//   expression_ref.val
// }
