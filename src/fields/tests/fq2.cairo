use bn::traits::{FieldOps, FieldUtils};
use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use bn::fields::{Fq2, fq2, Fq2Ops};
use debug::PrintTrait;

#[test]
#[available_gas(2000000)]
fn add_sub() {
    let a = fq2(34, 645);
    let b = fq2(25, 45);
    let c = fq2(9, 600);
    assert(a == b + c, 'incorrect add');
    assert(b == a - c, 'incorrect sub');
}

#[test]
#[available_gas(2000000)]
fn mul() {
    let a = fq2(34, 645);
    let b = fq2(25, 45);
    let c = fq2(9, 600);
    assert((a * b) * c == a * (b * c), 'incorrect mul');
}

#[test]
#[available_gas(2000000)]
fn div() {
    let a = fq2(34, 645);
    let b = fq2(25, 45);
    let c = a / b;
    assert(c * b == a, 'incorrect div');
}

#[test]
#[available_gas(2000000)]
fn inv() {
    let a = fq2(34, 645);
    let b = fq2(25, 45);
    let a_inv = FieldOps::inv(a);
    let c = a * a_inv;
    let d = b * a_inv;
    assert(c == FieldUtils::one(), 'incorrect inv');
    assert(d * a == b, 'incorrect inv');
}

#[test]
#[available_gas(0xf0000)]
fn inv_one() {
    let one: Fq2 = FieldUtils::one();
    let one_inv = one.inv();
    assert(one_inv == one, 'incorrect inverse of one');
}

#[test]
#[available_gas(5000000)]
fn sqr() {
    let a = fq2(34, 645);
    assert(a * a == a.sqr(), 'incorrect mul');
}
