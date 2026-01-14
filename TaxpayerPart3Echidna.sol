pragma solidity ^0.8.22;

import "./Originale_ecc.. FIXED VERSION.sol";

contract RetirementEchidna {
    TaxpayerRetirementFixed public p1;
    TaxpayerRetirementFixed public p2;

    constructor() {
        p1 = new TaxpayerRetirementFixed(address(0), address(0));
        p2 = new TaxpayerRetirementFixed(address(0), address(0));
    }

    // Unmarried users must hold their personal default allowance
    function prop_unmarried_default() public view returns (bool) {
        if (!p1.isMarried()) {
            if (p1.getTaxAllowance() != p1.personalDefault()) return false;
        }
        if (!p2.isMarried()) {
            if (p2.getTaxAllowance() != p2.personalDefault()) return false;
        }
        return true;
    }

    // Echidna wrapper for above property
    function echidna_unmarried_default() public view returns (bool) {
        return prop_unmarried_default();
    }

    // Married couples: pooled allowance equals sum of each partner's personal default
    function prop_couple_pooled_default() public view returns (bool) {
        if (p1.isMarried()) {
            TaxpayerRetirementFixed sp = TaxpayerRetirementFixed(p1.spouse());
            uint pooled = p1.getTaxAllowance() + sp.getTaxAllowance();
            uint expect = p1.personalDefault() + sp.personalDefault();
            if (pooled != expect) return false;
        }
        if (p2.isMarried()) {
            TaxpayerRetirementFixed sp2 = TaxpayerRetirementFixed(p2.spouse());
            uint pooled2 = p2.getTaxAllowance() + sp2.getTaxAllowance();
            uint expect2 = p2.personalDefault() + sp2.personalDefault();
            if (pooled2 != expect2) return false;
        }
        return true;
    }

    // Echidna wrapper for couple pooled check
    function echidna_couple_pooled_default() public view returns (bool) {
        return prop_couple_pooled_default();
    }

    // Mutators with different names
    function linkP1P2() public { p1.tieKnot(address(p2)); }
    function linkP2P1() public { p2.tieKnot(address(p1)); }
    function unlinkP1() public { p1.separate(); }
    function unlinkP2() public { p2.separate(); }
    function giveP1(uint v) public { p1.moveAllowance(v); }
    function giveP2(uint v) public { p2.moveAllowance(v); }
    function bdayP1() public { p1.celebrateBirthday(); }
    function bdayP2() public { p2.celebrateBirthday(); }

    function retireP1() public { while (p1.age() < 65) p1.celebrateBirthday(); }
    function retireP2() public { while (p2.age() < 65) p2.celebrateBirthday(); }
}
