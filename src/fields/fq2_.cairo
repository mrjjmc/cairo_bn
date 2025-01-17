use bn::traits::{FieldUtils, FieldOps, FieldShortcuts};
use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use bn::fields::{Fq, fq,};
use debug::PrintTrait;

#[derive(Copy, Drop, Serde, Debug)]
struct Fq2 {
    c0: Fq,
    c1: Fq,
}

// Extension field is represented as two number with X (a root of an polynomial in Fq which doesn't exist in Fq).
// X for field extension is equivalent to imaginary i for real numbers.
// number a: Fq2 = (a0, a1), mathematically, a = a0 + a1 * X

#[inline(always)]
fn fq2(c0: u256, c1: u256) -> Fq2 {
    Fq2 { c0: fq(c0), c1: fq(c1), }
}

#[generate_trait]
impl Fq2Frobenius of Fq2FrobeniusTrait {
    #[inline(always)]
    fn frob0(self: Fq2) -> Fq2 {
        self
    }

    #[inline(always)]
    fn frob1(self: Fq2) -> Fq2 {
        self.conjugate()
    }
}

impl Fq2Utils of FieldUtils<Fq2, Fq> {
    #[inline(always)]
    fn one() -> Fq2 {
        fq2(1, 0)
    }

    #[inline(always)]
    fn zero() -> Fq2 {
        fq2(0, 0)
    }

    #[inline(always)]
    fn scale(self: Fq2, by: Fq) -> Fq2 {
        Fq2 { c0: self.c0 * by, c1: self.c1 * by, }
    }

    #[inline(always)]
    fn conjugate(self: Fq2) -> Fq2 {
        Fq2 { c0: self.c0, c1: -self.c1, }
    }

    #[inline(always)]
    fn mul_by_nonresidue(self: Fq2,) -> Fq2 {
        // fq2(9, 1)
        let Fq2{c0: a0, c1: a1 } = self;
        Fq2 { //
         //  a0 * b0 + a1 * βb1,
        c0: a0.scale(9) - a1, //
         //  c1: a0 * b1 + a1 * b0,
        c1: a0 + a1.scale(9), //
         }
    }

    #[inline(always)]
    fn frobenius_map(self: Fq2, power: usize) -> Fq2 {
        if power % 2 == 0 {
            self
        } else {
            // Fq2 { c0: self.c0, c1: self.c1.mul_by_nonresidue(), }
            self.conjugate()
        }
    }
}

impl Fq2Short of FieldShortcuts<Fq2> {
    #[inline(always)]
    fn x_add(self: Fq2, rhs: Fq2) -> Fq2 {
        // Operation without modding can only be done like 4 times
        Fq2 { //
         c0: fq(self.c0.c0 + rhs.c0.c0), //
         c1: fq(self.c1.c0 + rhs.c1.c0), //
         }
    }

    #[inline(always)]
    fn fix_mod(self: Fq2) -> Fq2 {
        // Operation without modding can only be done like 4 times
        Fq2 { //
         c0: self.c0.fix_mod(), //
         c1: self.c1.fix_mod(), //
         }
    }
}

impl Fq2Ops of FieldOps<Fq2> {
    #[inline(always)]
    fn add(self: Fq2, rhs: Fq2) -> Fq2 {
        Fq2 { c0: self.c0 + rhs.c0, c1: self.c1 + rhs.c1, }
    }

    #[inline(always)]
    fn sub(self: Fq2, rhs: Fq2) -> Fq2 {
        Fq2 { c0: self.c0 - rhs.c0, c1: self.c1 - rhs.c1, }
    }

    #[inline(always)]
    fn mul(self: Fq2, rhs: Fq2) -> Fq2 {
        // Karatsuba
        let Fq2{c0: a0, c1: a1 } = self;
        let Fq2{c0: b0, c1: b1 } = rhs;
        let v0 = a0 * b0;
        let v1 = a1 * b1;
        // v0 + βv1, β = -1
        let c0 = v0 - v1;
        // (a0 + a1) * (b0 + b1) - v0 - v1
        let c1 = a0.x_add(a1) * b0.x_add(b1) - v0 - v1;
        Fq2 { c0, c1 }
    // Derived
    // let Fq2{c0: a0, c1: a1 } = self;
    // let Fq2{c0: b0, c1: b1 } = rhs;
    // // Multiplying ab in Fq2 mod X^2 + BETA
    // // c = ab = a0*b0 + a0*b1*X + a1*b0*X + a0*b0*BETA
    // // c = a0*b0 + a0*b0*BETA + (a0*b1 + a1*b0)*X
    // // or c = (a0*b0 + a0*b0*BETA, a0*b1 + a1*b0)
    // Fq2 { //
    //  c0: a0 * b0 + a1 * b1.mul_by_nonresidue(), //
    //  c1: a0 * b1 + a1 * b0, //
    //  }
    }

    #[inline(always)]
    fn div(self: Fq2, rhs: Fq2) -> Fq2 {
        self.mul(rhs.inv())
    }

    #[inline(always)]
    fn neg(self: Fq2) -> Fq2 {
        Fq2 { c0: -self.c0, c1: -self.c1, }
    }

    #[inline(always)]
    fn eq(lhs: @Fq2, rhs: @Fq2) -> bool {
        lhs.c0 == rhs.c0 && lhs.c1 == rhs.c1
    }

    #[inline(always)]
    fn sqr(self: Fq2) -> Fq2 {
        let Fq2{c0: a0, c1: a1 } = self;
        // Complex squaring
        let v = a0 * a1;
        // (a0 + a1) * (a0 + βa1) - v - βv, β = -1
        let c0 = a0.x_add(a1) * a0.x_add(-a1);
        // 2v
        let c1 = v + v;
        Fq2 { c0, c1 }
    }

    #[inline(always)]
    fn inv(self: Fq2) -> Fq2 {
        // "High-Speed Software Implementation of the Optimal Ate Pairing
        // over Barreto–Naehrig Curves"; Algorithm 8
        if self.c0.c0 + self.c1.c0 == 0 {
            return Fq2 { c0: fq(0), c1: fq(0), };
        }
        // let t = (self.c0.sqr() - (self.c1.sqr().mul_by_nonresidue())).inv();
        // Mul by non residue -1 makes negative
        let t = (self.c0.sqr() + self.c1.sqr()).inv();

        Fq2 { c0: self.c0 * t, c1: self.c1 * -t, }
    }
}
