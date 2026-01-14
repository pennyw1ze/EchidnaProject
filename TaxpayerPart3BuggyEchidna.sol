pragma solidity ^0.8.22;

import "./Taxpayer.sol";

/// @notice Echidna harness to find faults in the original Taxpayer contract for Part 3
contract TaxpayerPart3BuggyEchidna {
    Taxpayer public person1;
    Taxpayer public person2;

    uint constant BASE = 5000;
    uint constant OAP = 7000;

    constructor() {
        person1 = new Taxpayer(address(0), address(0));
        person2 = new Taxpayer(address(0), address(0));
    }

    // Invariant A: If unmarried, allowance equals personal default (age-based)
    function echidna_personal_default_unmarried() public view returns (bool) {
        if (!person1.isMarried()) {
            uint expected = person1.age() >= 65 ? OAP : BASE;
            if (person1.getTaxAllowance() != expected) return false;
        }
        if (!person2.isMarried()) {
            uint expected2 = person2.age() >= 65 ? OAP : BASE;
            if (person2.getTaxAllowance() != expected2) return false;
        }
        return true;
    }

    // Invariant B: If married, pooled allowance equals sum of each partner's personal default
    function echidna_pooled_equals_defaults() public view returns (bool) {
        if (person1.isMarried()) {
            Taxpayer sp = Taxpayer(person1.spouse());
            uint expected1 = (person1.age() >= 65 ? OAP : BASE) + (sp.age() >= 65 ? OAP : BASE);
            uint pooled = person1.getTaxAllowance() + sp.getTaxAllowance();
            if (pooled != expected1) return false;
        }
        if (person2.isMarried()) {
            Taxpayer sp2 = Taxpayer(person2.spouse());
            uint expected2 = (person2.age() >= 65 ? OAP : BASE) + (sp2.age() >= 65 ? OAP : BASE);
            uint pooled2 = person2.getTaxAllowance() + sp2.getTaxAllowance();
            if (pooled2 != expected2) return false;
        }
        return true;
    }

    // Invariant C: Allowances never go negative (uint) - sanity
    function echidna_allowance_non_negative() public view returns (bool) {
        return person1.getTaxAllowance() >= 0 && person2.getTaxAllowance() >= 0;
    }

    // Invariant D: Total allowance in the two-person system equals sum of personal defaults
    function echidna_total_matches_defaults() public view returns (bool) {
        uint expected = (person1.age() >= 65 ? OAP : BASE) + (person2.age() >= 65 ? OAP : BASE);
        uint total = person1.getTaxAllowance() + person2.getTaxAllowance();
        return total == expected;
    }

    // Helpers to mutate state
    function marry12() public { person1.marry(address(person2)); }
    function marry21() public { person2.marry(address(person1)); }
    function divorce1() public { person1.divorce(); }
    function divorce2() public { person2.divorce(); }
    function age1() public { person1.haveBirthday(); }
    function age2() public { person2.haveBirthday(); }
    function transfer1(uint v) public { person1.transferAllowance(v); }
    function transfer2(uint v) public { person2.transferAllowance(v); }

    // fast-forward to 65
    function make65_1() public { while (person1.age() < 65) person1.haveBirthday(); }
    function make65_2() public { while (person2.age() < 65) person2.haveBirthday(); }
}
