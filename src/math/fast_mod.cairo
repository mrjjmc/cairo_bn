// These mod functions are heavily optimised for < 255 bit numbers
// and may break for full 256 bit numbers

use core::option::OptionTrait;
use core::traits::TryInto;
use core::traits::Into;
use core::integer::u512;

#[inline(always)]
fn u128_wrapping_add(lhs: u128, rhs: u128) -> u128 implicits(RangeCheck) nopanic {
    match integer::u128_overflowing_add(lhs, rhs) {
        Result::Ok(x) => x,
        Result::Err(x) => x,
    }
}

#[inline(always)]
fn u128_add_with_carry(a: u128, b: u128) -> (u128, u128) nopanic {
    match integer::u128_overflowing_add(a, b) {
        Result::Ok(v) => (v, 0),
        Result::Err(v) => (v, 1),
    }
}

fn scale(a: u256, b: u128, modulo: NonZero<u256>) -> u256 {
    // (a1 + a2) * c
    let (limb1_part1, limb0) = integer::u128_wide_mul(a.low, b);
    let (limb2, limb1_part2) = integer::u128_wide_mul(a.high, b);
    let limb1 = u128_wrapping_add(limb1_part1, limb1_part2);
    let (_, rem_u256, _, _, _, _, _) = integer::u512_safe_divmod_by_u256(
        u512 { limb0, limb1, limb2, limb3: 0 }, modulo
    );
    rem_u256
}

fn mul_nz(a: u256, b: u256, modulo: NonZero<u256>) -> u256 {
    let (limb1, limb0) = integer::u128_wide_mul(a.low, b.low);
    let (limb2, limb1_part) = integer::u128_wide_mul(a.low, b.high);
    let (limb1, limb1_overflow0) = u128_add_with_carry(limb1, limb1_part);
    let (limb2_part, limb1_part) = integer::u128_wide_mul(a.high, b.low);
    let (limb1, limb1_overflow1) = u128_add_with_carry(limb1, limb1_part);
    let (limb2, limb2_overflow) = u128_add_with_carry(limb2, limb2_part);
    let (limb3, limb2_part) = integer::u128_wide_mul(a.high, b.high);
    // No overflow since no limb4.
    let limb3 = u128_wrapping_add(limb3, limb2_overflow);
    let (limb2, limb2_overflow) = u128_add_with_carry(limb2, limb2_part);
    // No overflow since no limb4.
    let limb3 = u128_wrapping_add(limb3, limb2_overflow);
    // No overflow possible in this addition since both operands are 0/1.
    let limb1_overflow = u128_wrapping_add(limb1_overflow0, limb1_overflow1);
    let (limb2, limb2_overflow) = u128_add_with_carry(limb2, limb1_overflow);
    // No overflow since no limb4.
    let limb3 = u128_wrapping_add(limb3, limb2_overflow);

    let (_, rem_u256, _, _, _, _, _) = integer::u512_safe_divmod_by_u256(
        u512 { limb0, limb1, limb2, limb3 }, modulo
    );
    rem_u256
}

fn sqr_nz(a: u256, modulo: NonZero<u256>) -> u256 {
    let (limb1, limb0) = integer::u128_wide_mul(a.low, a.low);
    let (limb2, limb1_part) = integer::u128_wide_mul(a.low, a.high);
    let (limb1, limb1_overflow0) = u128_add_with_carry(limb1, limb1_part);
    let (limb1, limb1_overflow1) = u128_add_with_carry(limb1, limb1_part);
    let (limb2, limb2_overflow) = u128_add_with_carry(limb2, limb2);
    let (limb3, limb2_part) = integer::u128_wide_mul(a.high, a.high);
    // No overflow since no limb4.
    let limb3 = u128_wrapping_add(limb3, limb2_overflow);
    let (limb2, limb2_overflow) = u128_add_with_carry(limb2, limb2_part);
    // No overflow since no limb4.
    let limb3 = u128_wrapping_add(limb3, limb2_overflow);
    // No overflow possible in this addition since both operands are 0/1.
    let limb1_overflow = u128_wrapping_add(limb1_overflow0, limb1_overflow1);
    let (limb2, limb2_overflow) = u128_add_with_carry(limb2, limb1_overflow);
    // No overflow since no limb4.
    let limb3 = u128_wrapping_add(limb3, limb2_overflow);

    let (_, rem_u256, _, _, _, _, _) = integer::u512_safe_divmod_by_u256(
        u512 { limb0, limb1, limb2, limb3 }, modulo
    );
    rem_u256
}

#[inline(always)]
fn mul(a: u256, b: u256, modulo: u256) -> u256 {
    mul_nz(a, b, modulo.try_into().unwrap())
}

#[inline(always)]
fn add_inverse(b: u256, modulo: u256) -> u256 {
    modulo - b
}

#[inline(always)]
fn add(mut a: u256, mut b: u256, modulo: u256) -> u256 {
    add_nz(a, b, modulo.try_into().unwrap())
}

#[inline(always)]
fn add_nz(mut a: u256, mut b: u256, modulo: NonZero<u256>) -> u256 {
    // Doesn't overflow coz we have at least one bit to spare
    let (q, r, _) = integer::u256_safe_divmod(a + b, modulo);
    r
}

#[inline(always)]
fn sub(mut a: u256, mut b: u256, modulo: u256) -> u256 {
    // reduce values
    if (a < b) {
        (modulo - b) + a
    } else {
        a - b
    }
}

#[inline(always)]
fn inv(b: u256, modulo: NonZero<u256>) -> u256 {
    math::u256_inv_mod(b, modulo).unwrap().into()
}

#[inline(always)]
fn div_nz(a: u256, b: u256, modulo_nz: NonZero<u256>) -> u256 {
    mul_nz(a, inv(b, modulo_nz), modulo_nz)
}

#[inline(always)]
fn div(a: u256, b: u256, modulo: u256) -> u256 {
    let modulo_nz = modulo.try_into().expect('0 modulo');
    div_nz(a, b, modulo_nz)
}
