trait FieldUtils<TFq, TFqChildren> {
    fn one() -> TFq;
    fn zero() -> TFq;
    fn conjugate(self: TFq) -> TFq;
    fn scale(self: TFq, by: TFqChildren) -> TFq;
    fn mul_by_nonresidue(self: TFq,) -> TFq;
    fn frobenius_map(self: TFq, power: usize) -> TFq;
}

trait FieldShortcuts<TFq> {
    fn x_add(self: TFq, rhs: TFq) -> TFq;
    fn fix_mod(self: TFq) -> TFq;
}

trait FieldOps<TFq> {
    fn add(self: TFq, rhs: TFq) -> TFq;
    fn sub(self: TFq, rhs: TFq) -> TFq;
    fn mul(self: TFq, rhs: TFq) -> TFq;
    fn div(self: TFq, rhs: TFq) -> TFq;
    fn sqr(self: TFq) -> TFq;
    fn neg(self: TFq) -> TFq;
    fn eq(lhs: @TFq, rhs: @TFq) -> bool;
    fn inv(self: TFq) -> TFq;
}
