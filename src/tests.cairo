// test bn::tests::miller_bench ... ok (gas usage est.: 4663756470)
// test bn::tests::pairing_bench ... ok (gas usage est.: 6578295960)

use bn::curve::groups::ECOperations;
use bn::g::{Affine, AffineG1Impl, AffineG2Impl, g1, g2};
use bn::fields::{Fq, Fq2, print::Fq12Display};
use bn::curve::pairing::bkls_tate::{tate_pairing, tate_miller_loop};

fn p(n: u8) -> Affine<Fq> {
    if n == 1 {
        AffineG1Impl::one()
    } else if n == 2 {
        g1(
            0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd3,
            0x15ed738c0e0a7c92e7845f96b2ae9c0a68a6a449e3538fc7ff3ebf7a5a18a2c4
        )
    } else if n == 3 {
        g1(
            0x769bf9ac56bea3ff40232bcb1b6bd159315d84715b8e679f2d355961915abf0,
            0x2ab799bee0489429554fdb7c8d086475319e63b40b9c5b57cdf1ff3dd9fe2261
        )
    } else if n == 5 {
        g1(
            0x17c139df0efee0f766bc0204762b774362e4ded88953a39ce849a8a7fa163fa9,
            0x1e0559bacb160664764a357af8a9fe70baa9258e0b959273ffc5718c6d4cc7c
        )
    } else {
        assert(false, 'unimplemented');
        AffineG1Impl::one()
    }
}

fn q(n: u8) -> Affine<Fq2> {
    if n == 1 {
        AffineG2Impl::one()
    } else if n == 2 {
        g2(
            0x27dc7234fd11d3e8c36c59277c3e6f149d5cd3cfa9a62aee49f8130962b4b3b9,
            0x203e205db4f19b37b60121b83a7333706db86431c6d835849957ed8c3928ad79,
            0x4bb53b8977e5f92a0bc372742c4830944a59b4fe6b1c0466e2a6dad122b5d2e,
            0x195e8aa5b7827463722b8c153931579d3505566b4edf48d498e185f0509de152,
        )
    } else if n == 3 {
        g2(
            0x6064e784db10e9051e52826e192715e8d7e478cb09a5e0012defa0694fbc7f5,
            0x1014772f57bb9742735191cd5dcfe4ebbc04156b6878a0a7c9824f32ffb66e85,
            0x58e1d5681b5b9e0074b0f9c8d2c68a069b920d74521e79765036d57666c5597,
            0x21e2335f3354bb7922ffcc2f38d3323dd9453ac49b55441452aeaca147711b2,
        )
    } else if n == 5 {
        g2(
            0x2e539c423b302d13f4e5773c603948eaf5db5df8ae8a9a9113708390a06410d8,
            0xa09ccf561b55fd99d1c1208dee1162457b57ac5af3759d50671e510e428b2a1,
            0x2f8d9f9ab83727c77a2fec063cb7b6e5eb23044ccf535ad49d46d394fb6f6bf6,
            0x19b763513924a736e4eebd0d78c91c1bc1d657fee4214057d21414011cfcc763,
        )
    } else {
        assert(false, 'unimplemented');
        AffineG2Impl::one()
    }
}

#[test]
#[available_gas(20000000000)]
fn miller_bench() {
    tate_miller_loop(p(5), q(3));
}

#[test]
#[available_gas(20000000000)]
fn pairing_bench() {
    tate_pairing(p(5), q(3));
}

// In tests below, P is G1 generator and Q is G2 generator

// Tests bilinearity in G1,
// e(nP + mP, xQ) == e(nP, xQ) * e(mP, xQ)
#[test]
#[available_gas(20000000000)]
fn bilinearity_g1() {
    assert(
        tate_pairing(p(5), q(3)) == tate_pairing(p(2), q(3)) * tate_pairing(p(3), q(3)),
        'e([2+3]g1,[3]g2) failed'
    )
}

// Tests bilinearity in G2,
// e(xP, nQ + mQ) == e(xP, nQ) * e(xP, mQ)
#[test]
#[available_gas(20000000000)]
fn bilinearity_g2() {
    assert(
        tate_pairing(p(2), q(5)) == tate_pairing(p(2), q(2)) * tate_pairing(p(2), q(3)),
        'e([2]g1,[2+3]g2) failed'
    )
}

// Tests quadratic constraints,
// e(xP, mQ) == e(P, mxQ)
#[test]
#[available_gas(20000000000)]
fn quadratic_constraints() {
    assert(tate_pairing(p(3), q(2)) == tate_pairing(p(1), q(5).add(q(1))), 'e([3]g1,[2]g2) failed')
}

