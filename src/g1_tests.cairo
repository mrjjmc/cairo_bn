use bn::traits::ECOperations;
use bn::{g1, g2};
use debug::PrintTrait;

const dbl_x: u256 = 1368015179489954701390400359078579693043519447331113978918064868415326638035;
const dbl_y: u256 = 9918110051302171585080402603319702774565515993150576347155970296011118125764;


#[test]
#[available_gas(100000000)]
fn g1_dbl() {
    // g1_double ... ok (gas: 413280)

    let doubled = g1::one().double();
    assert(doubled.x == dbl_x, 'wrong double x');
    assert(doubled.y == dbl_y, 'wrong double y');
}

#[test]
#[available_gas(100000000)]
fn g1_add() {
    // g1_add ... ok (gas: 364320)

    let g_3x = g1::one().add(g1::pt(dbl_x, dbl_y));

    assert(
        g_3x.x == 3353031288059533942658390886683067124040920775575537747144343083137631628272,
        'wrong add x'
    );
    assert(
        g_3x.y == 19321533766552368860946552437480515441416830039777911637913418824951667761761,
        'wrong add y'
    );
}

#[test]
#[available_gas(100000000)]
fn g1_mul() {
    // g1_add ... ok (gas: 364320)

    let g_3x = g1::one().multiply(3);

    assert(
        g_3x.x == 3353031288059533942658390886683067124040920775575537747144343083137631628272,
        'wrong add x'
    );
    assert(
        g_3x.y == 19321533766552368860946552437480515441416830039777911637913418824951667761761,
        'wrong add y'
    );
}