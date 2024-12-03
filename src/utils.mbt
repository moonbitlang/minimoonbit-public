///|
pub fn to_json(self : Type) -> Json {
  match self {
    Unit => "Unit"
    Bool => "Bool"
    Int => "Int"
    Double => "Float"
    Fun(params, result) =>
      ["Fun", params.map(Type::to_json) |> Json::Array, result.to_json()]
    Tuple(types) => ["Tuple", types.map(Type::to_json) |> Json::Array]
    Array(t) => ["Array", t.to_json()]
    Var({ val: None }) => ["Var", "None"]
    Var({ val: Some(t) }) => ["Var", ["Some", t.to_json()]]
    Ptr => "Ptr"
  }
}

///|
pub fn Type::from_json(self : Json) -> Type!Error {
  fn from(values : ArrayView[Json]) -> Array[Type]!Error {
    let array = []
    for i = 0; i < values.length(); i = i + 1 {
      array.push(values[i] |> Type::from_json!())
    }
    array
  }

  match self {
    "Unit" => Unit
    "Bool" => Bool
    "Int" => Int
    "Float" => Double
    ["Fun", [.. as params], result] =>
      Fun(from!(params), result |> Type::from_json!())
    ["Tuple", [.. as types]] => Tuple(from!(types))
    ["Array", t] => Array(t |> Type::from_json!())
    ["Var", "None"] => Var({ val: None })
    ["Var", ["Some", t]] => Var({ val: Some(t |> Type::from_json!()) })
    "Ptr" => Ptr
    _ => fail!("invalid json: should contain a valid type")
  }
}

test {
  inspect!(Type::from_json?(Type::Unit.to_json()), content="Ok(Unit)")
  inspect!(Type::from_json?(Type::Bool.to_json()), content="Ok(Bool)")
  inspect!(Type::from_json?(Type::Int.to_json()), content="Ok(Int)")
  inspect!(Type::from_json?(Type::Double.to_json()), content="Ok(Double)")
  inspect!(
    Type::from_json?(Type::Fun([Type::Int, Type::Double], Type::Unit).to_json()),
    content="Ok(Fun([Int, Double], Unit))",
  )
  inspect!(
    Type::from_json?(Type::Tuple([Type::Int, Type::Double]).to_json()),
    content="Ok(Tuple([Int, Double]))",
  )
  inspect!(
    Type::from_json?(Type::Array(Type::Int).to_json()),
    content="Ok(Array(Int))",
  )
  inspect!(
    Type::from_json?(Type::Var({ val: None }).to_json()),
    content="Ok(Var({val: None}))",
  )
  inspect!(
    Type::from_json?(Type::Var({ val: Some(Type::Int) }).to_json()),
    content="Ok(Var({val: Some(Int)}))",
  )
}

///|
pub fn to_json(self : Fundef) -> Json {
  {
    "name": [self.name.0 |> Json::String, self.name.1.to_json()],
    "args": [
      ..self.args.map(
        fn { (name, ty) => ([name |> Json::String, ty.to_json()] : Json) },
      ),
    ],
    "body": self.body.to_json(),
  }
}

///|
pub fn Fundef::from_json(json : Json) -> Fundef!Error {
  fn from_json(json : ArrayView[Json]) -> Array[(String, Type)]!Error {
    let array = []
    for i = 0; i < json.length(); i = i + 1 {
      match json[i] {
        [name, ty] => {
          let name = match name.as_string() {
            Some(name) => name
            None =>
              fail!(
                "invalid json: function parameters should contain a string as name",
              )
          }
          let ty = ty |> Type::from_json!()
          array.push((name, ty))
        }
        _ =>
          fail!(
            "invalid json: function parameters should contain an array of name and type",
          )
      }
    }
    array
  }

  match json {
    { "name": [name, ty], "args": [.. as args], "body": body } => {
      let name = match name.as_string() {
        Some(name) => name
        None => fail!("invalid field name: should contain a string and a type")
      }
      let ty = ty |> Type::from_json!()
      let args = from_json!(args)
      let body = body |> Syntax::from_json!()
      Fundef::{ name: (name, ty), args, body }
    }
    _ =>
      fail!(
        "invalid json: should contain name, args, and body where name is an array of two elements",
      )
  }
}

///|
pub fn to_json(self : Syntax) -> Json {
  match self {
    Unit => "Unit"
    Bool(b) => ["Bool", if b { true } else { false }]
    Int(i) => ["Int", Json::Number(i.to_double())]
    Double(f) => ["Float", Json::Number(f)]
    Not(e) => ["Not", e.to_json()]
    Neg(e, kind=Some(Double)) => ["FNeg", e.to_json()]
    Neg(e, kind=_) => ["Neg", e.to_json()]
    Prim(e1, e2, op, kind~) => {
      let op = if kind == Some(Double) { "F\{op}" } else { "{op}" }
      [op |> Json::String, e1.to_json(), e2.to_json()]
    }
    Eq(e1, e2) => ["Eq", e1.to_json(), e2.to_json()]
    LE(e1, e2) => ["LE", e1.to_json(), e2.to_json()]
    If(e1, e2, e3) => ["If", e1.to_json(), e2.to_json(), e3.to_json()]
    Let((x, t), e1, e2) =>
      ["Let", [x |> Json::String, t.to_json()], e1.to_json(), e2.to_json()]
    Var(id) => ["Var", id |> Json::String]
    LetRec(funcdef, e) => ["LetRec", funcdef.to_json(), e.to_json()]
    App(e, es) => ["App", e.to_json(), es.map(Syntax::to_json) |> Json::Array]
    Tuple(es) => ["Tuple", es.map(Syntax::to_json) |> Json::Array]
    LetTuple(def, value, body) =>
      [
        "LetTuple",
        [..def.map(fn { (x, t) => ([x |> Json::String, t.to_json()] : Json) })],
        value.to_json(),
        body.to_json(),
      ]
    Array(size, init) => ["Array", size.to_json(), init.to_json()]
    Get(arr, idx) => ["Get", arr.to_json(), idx.to_json()]
    Put(arr, idx, value) =>
      ["Put", arr.to_json(), idx.to_json(), value.to_json()]
  }
}

///|
pub fn Syntax::from_json(json : Json) -> Syntax! {
  match json {
    "Unit" => Syntax::Unit
    ["Bool", true] => Bool(true)
    ["Bool", false] => Bool(false)
    ["Int", i] =>
      match i.as_number() {
        Some(i) =>
          if i.to_int().to_double() != i {
            fail!("invalid json: an int should be an integer")
          } else {
            Int(i.to_int())
          }
        None => fail!("invalid json: should contain a number as int")
      }
    ["Float", f] =>
      match f.as_number() {
        Some(f) => Double(f)
        None => fail!("invalid json: should contain a number as float")
      }
    ["Not", e] => Not(e |> Syntax::from_json!())
    ["Neg", e] => Neg(e |> Syntax::from_json!(), kind=None)
    ["FNeg", e] => Neg(e |> Syntax::from_json!(), kind=Some(Double))
    ["Add", e1, e2] =>
      Prim(
        e1 |> Syntax::from_json!(),
        e2 |> Syntax::from_json!(),
        Add,
        kind=None,
      )
    ["Sub", e1, e2] =>
      Prim(
        e1 |> Syntax::from_json!(),
        e2 |> Syntax::from_json!(),
        Sub,
        kind=None,
      )
    ["Mul", e1, e2] =>
      Prim(
        e1 |> Syntax::from_json!(),
        e2 |> Syntax::from_json!(),
        Mul,
        kind=None,
      )
    ["Div", e1, e2] =>
      Prim(
        e1 |> Syntax::from_json!(),
        e2 |> Syntax::from_json!(),
        Div,
        kind=None,
      )
    ["FAdd", e1, e2] =>
      Syntax::Prim(
        e1 |> Syntax::from_json!(),
        e2 |> Syntax::from_json!(),
        Add,
        kind=Some(Double),
      )
    ["FSub", e1, e2] =>
      Prim(
        e1 |> Syntax::from_json!(),
        e2 |> Syntax::from_json!(),
        Sub,
        kind=Some(Double),
      )
    ["FMul", e1, e2] =>
      Prim(
        e1 |> Syntax::from_json!(),
        e2 |> Syntax::from_json!(),
        Mul,
        kind=Some(Double),
      )
    ["FDiv", e1, e2] =>
      Prim(
        e1 |> Syntax::from_json!(),
        e2 |> Syntax::from_json!(),
        Div,
        kind=Some(Kind::Double),
      )
    ["Eq", e1, e2] => Eq(e1 |> Syntax::from_json!(), e2 |> Syntax::from_json!())
    ["LE", e1, e2] => LE(e1 |> Syntax::from_json!(), e2 |> Syntax::from_json!())
    ["If", e1, e2, e3] =>
      If(
        e1 |> Syntax::from_json!(),
        e2 |> Syntax::from_json!(),
        e3 |> Syntax::from_json!(),
      )
    ["Let", [x, t], e1, e2] =>
      Let(
        (
          match x.as_string() {
            Some(x) => x
            None => fail!("invalid json: let should contain a string as name")
          },
          t |> Type::from_json!(),
        ),
        e1 |> Syntax::from_json!(),
        e2 |> Syntax::from_json!(),
      )
    ["Var", id] =>
      match id.as_string() {
        Some(id) => Var(id)
        None => fail!("invalid json: should contain a string as id")
      }
    ["LetRec", funcdef, e] =>
      LetRec(funcdef |> Fundef::from_json!(), e |> Syntax::from_json!())
    ["App", e, [.. as es]] => {
      fn from_json(values : ArrayView[Json]) -> Array[Syntax]! {
        let array = []
        for i = 0; i < values.length(); i = i + 1 {
          array.push(values[i] |> Syntax::from_json!())
        }
        array
      }

      App(e |> Syntax::from_json!(), from_json!(es))
    }
    ["Tuple", [.. as es]] => {
      fn from_json(values : ArrayView[Json]) -> Array[Syntax]! {
        let array = []
        for i = 0; i < values.length(); i = i + 1 {
          array.push(values[i] |> Syntax::from_json!())
        }
        array
      }

      Tuple(from_json!(es))
    }
    ["LetTuple", [.. as def], value, body] => {
      fn from_json(values : ArrayView[Json]) -> Array[(String, Type)]! {
        let array = []
        for i = 0; i < values.length(); i = i + 1 {
          match values[i] {
            [x, t] => {
              let x = match x.as_string() {
                Some(x) => x
                None =>
                  fail!(
                    "invalid json: let tuple should contain a string as name",
                  )
              }
              let t = t |> Type::from_json!()
              array.push((x, t))
            }
            _ =>
              fail!(
                "invalid json: let tuple should contain an array of name and type",
              )
          }
        }
        array
      }

      LetTuple(
        from_json!(def),
        value |> Syntax::from_json!(),
        body |> Syntax::from_json!(),
      )
    }
    ["Array", size, init] =>
      Array(size |> Syntax::from_json!(), init |> Syntax::from_json!())
    ["Get", arr, idx] =>
      Get(arr |> Syntax::from_json!(), idx |> Syntax::from_json!())
    ["Put", arr, idx, value] =>
      Put(
        arr |> Syntax::from_json!(),
        idx |> Syntax::from_json!(),
        value |> Syntax::from_json!(),
      )
    _ => fail!("invalid json: should contain an operator")
  }
}

test {
  inspect!(
    Syntax::App(Syntax::Var("f"), []).to_json().stringify(),
    content=
      #|["App",["Var","f"],[]]
    ,
  )
  inspect!(
    Syntax::App(Syntax::Var("f"), [Syntax::Int(1)]).to_json().stringify(),
    content=
      #|["App",["Var","f"],[["Int",1]]]
    ,
  )
  inspect!(
    Syntax::Array(Syntax::Int(1), Syntax::Int(2)).to_json().stringify(),
    content=
      #|["Array",["Int",1],["Int",2]]
    ,
  )
  inspect!(
    Syntax::Bool(true).to_json().stringify(),
    content=
      #|["Bool",true]
    ,
  )
  inspect!(
    Syntax::Double(1.0).to_json().stringify(),
    content=
      #|["Float",1]
    ,
  )
  inspect!(
    Syntax::Eq(Syntax::Int(1), Syntax::Int(2)).to_json().stringify(),
    content=
      #|["Eq",["Int",1],["Int",2]]
    ,
  )
  inspect!(
    Syntax::Get(Syntax::Int(1), Syntax::Int(2)).to_json().stringify(),
    content=
      #|["Get",["Int",1],["Int",2]]
    ,
  )
  inspect!(
    Syntax::If(Syntax::Bool(true), Syntax::Int(1), Syntax::Int(2))
    .to_json()
    .stringify(),
    content=
      #|["If",["Bool",true],["Int",1],["Int",2]]
    ,
  )
}

test {
  inspect!(Syntax::from_json!("Unit"), content="Unit")
  inspect!(Syntax::from_json!(["Bool", true]), content="Bool(true)")
  inspect!(Syntax::from_json!(["Bool", false]), content="Bool(false)")
  inspect!(Syntax::from_json!(["Int", 1]), content="Int(1)")
  inspect!(Syntax::from_json!(["Float", 1.0]), content="Double(1)")
  inspect!(
    Syntax::from_json!(["Not", ["Bool", true]]),
    content="Not(Bool(true))",
  )
  inspect!(
    Syntax::from_json!(["Neg", ["Int", 1]]),
    content="Neg(Int(1), kind=None)",
  )
  inspect!(
    Syntax::from_json!(["Add", ["Int", 1], ["Int", 2]]),
    content="Prim(Int(1), Int(2), Add, kind=None)",
  )
  inspect!(
    Syntax::from_json!(["Sub", ["Int", 1], ["Int", 2]]),
    content="Prim(Int(1), Int(2), Sub, kind=None)",
  )
  inspect!(
    Syntax::from_json!(["Mul", ["Int", 1], ["Int", 2]]),
    content="Prim(Int(1), Int(2), Mul, kind=None)",
  )
  inspect!(
    Syntax::from_json!(["Div", ["Int", 1], ["Int", 2]]),
    content="Prim(Int(1), Int(2), Div, kind=None)",
  )
  inspect!(
    Syntax::from_json!(["FAdd", ["Float", 1.0], ["Float", 2.0]]),
    content="Prim(Double(1), Double(2), Add, kind=Some(Double))",
  )
  inspect!(
    Syntax::from_json!(["FSub", ["Float", 1.0], ["Float", 2.0]]),
    content="Prim(Double(1), Double(2), Sub, kind=Some(Double))",
  )
  inspect!(
    Syntax::from_json!(["FMul", ["Float", 1.0], ["Float", 2.0]]),
    content="Prim(Double(1), Double(2), Mul, kind=Some(Double))",
  )
  inspect!(
    Syntax::from_json!(["FDiv", ["Float", 1.0], ["Float", 2.0]]),
    content="Prim(Double(1), Double(2), Div, kind=Some(Double))",
  )
  inspect!(
    Syntax::from_json!(["Eq", ["Int", 1], ["Int", 2]]),
    content="Eq(Int(1), Int(2))",
  )
  inspect!(
    Syntax::from_json!(["LE", ["Int", 1], ["Int", 2]]),
    content="LE(Int(1), Int(2))",
  )
  inspect!(
    Syntax::from_json!(["If", ["Bool", true], ["Int", 1], ["Int", 2]]),
    content="If(Bool(true), Int(1), Int(2))",
  )
  inspect!(
    Syntax::from_json!(["Let", ["x", "Int"], ["Int", 1], ["Int", 2]]),
    content=
      #|Let(("x", Int), Int(1), Int(2))
    ,
  )
  inspect!(
    Syntax::from_json!(["Var", "x"]),
    content=
      #|Var("x")
    ,
  )
}
