pragma solidity ^0.8.22;

import "./Originale_ecc.. LOTTERY FIXED VERSION.sol";
import "./Originale_ecc.. FIXED VERSION.sol";

contract LotteryFixedProbe {
    LotteryFixed public lot;
    TaxpayerRetirementFixed public p1;
    TaxpayerRetirementFixed public p2;

    constructor() {
        lot = new LotteryFixed(1);
        p1 = new TaxpayerRetirementFixed(address(0), address(0));
        p2 = new TaxpayerRetirementFixed(address(0), address(0));
    }

    function echidna_no_repeat_commit() public returns (bool) {
        try p1.joinLottery(address(lot), 1) {
        } catch {}
        try p1.joinLottery(address(lot), 2) { return false; } catch { return true; }
    }

    function echidna_reveal_requires_commit() public returns (bool) {
        try p1.revealLottery(address(lot), 123) { return false; } catch { return true; }
    }

    function echidna_one_winner_only() public returns (bool) {
        try lot.endLottery() {} catch {}
        uint cnt = 0;
        if (p1.getTaxAllowance() > p1.personalDefault()) cnt++;
        if (p2.getTaxAllowance() > p2.personalDefault()) cnt++;
        return cnt <= 1;
    }

    // helpers
    function start() public { lot.startLottery(); }
    function commit1(uint r) public { p1.joinLottery(address(lot), r); }
    function commit2(uint r) public { p2.joinLottery(address(lot), r); }
    function reveal1(uint r) public { p1.revealLottery(address(lot), r); }
    function reveal2(uint r) public { p2.revealLottery(address(lot), r); }
}
