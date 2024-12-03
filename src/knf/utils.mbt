///|
pub fn knf_max_counter(knf : Knf) -> Int {
  match knf {
    Unit => 0
    Int(_) => 0
    Double(_) => 0
    Neg(x) => x.slot
    Add(x, y) => @math.maximum(x.slot, y.slot)
    Sub(x, y) => @math.maximum(x.slot, y.slot)
    Mul(x, y) => @math.maximum(x.slot, y.slot)
    Div(x, y) => @math.maximum(x.slot, y.slot)
    FNeg(x) => x.slot
    FAdd(x, y) => @math.maximum(x.slot, y.slot)
    FSub(x, y) => @math.maximum(x.slot, y.slot)
    FMul(x, y) => @math.maximum(x.slot, y.slot)
    FDiv(x, y) => @math.maximum(x.slot, y.slot)
    IfEq(x, y, e1, e2) =>
      @math.maximum(
        x.slot,
        @math.maximum(
          y.slot,
          @math.maximum(knf_max_counter(e1), knf_max_counter(e2)),
        ),
      )
    IfLe(x, y, e1, e2) =>
      @math.maximum(
        x.slot,
        @math.maximum(
          y.slot,
          @math.maximum(knf_max_counter(e1), knf_max_counter(e2)),
        ),
      )
    Let((n, _), e1, e2) =>
      @math.maximum(
        n.slot,
        @math.maximum(knf_max_counter(e1), knf_max_counter(e2)),
      )
    Var(x) => x.slot
    LetRec(f, e) =>
      @math.maximum(
        f.name.slot,
        @math.maximum(knf_max_counter(f.body), knf_max_counter(e)),
      )
    Apply(x, xs) =>
      @math.maximum(
        x.slot,
        xs.map(fn(x) { x.slot }).fold(init=0, fn(a, b) { @math.maximum(a, b) }),
      )
    Tuple(xs) =>
      xs.map(fn(x) { x.slot }).fold(init=0, fn(a, b) { @math.maximum(a, b) })
    LetTuple(xts, n, e) =>
      @math.maximum(
        n.slot,
        @math.maximum(
          xts
          .map(fn(x) { x.0.slot })
          .fold(init=0, fn(a, b) { @math.maximum(a, b) }),
          knf_max_counter(e),
        ),
      )
    Get(x, y) => @math.maximum(x.slot, y.slot)
    Put(x, y, z) => @math.maximum(x.slot, @math.maximum(y.slot, z.slot))
    ExternalFunctionApplication(_, xs) =>
      xs.map(fn(x) { x.slot }).fold(init=0, fn(a, b) { @math.maximum(a, b) })
    ExternalArray(_) => 0
  }
}
