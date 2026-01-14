pragma solidity ^0.8.22;

import "./Lottery.sol";
import "./Taxpayer.sol";

/// @notice A more original Echidna harness for the provided Lottery contract.
/// It focuses on safety (no double-commit, correct phase ordering), basic honesty
/// (no reveal without commit) and simple winner-checks.
contract LotteryProbe {
    Lottery public lottery;
    Taxpayer public alice;
    Taxpayer public bob;

    constructor() {
        // short period for convenient testing; Echidna controls calls not time
        lottery = new Lottery(1);
        alice = new Taxpayer(address(0), address(0));
        bob = new Taxpayer(address(0), address(0));
    }

    // Invariant: a participant should not be able to submit two commitments
    // in the same round. We try to commit twice from `alice`; a correct
    // implementation should reject the second attempt.
    function echidna_no_repeat_commit() public returns (bool) {
        // first attempt: best-effort (may revert if lottery not started)
        try alice.joinLottery(address(lottery), uint256(0x01)) {
        } catch {
        }

        // second attempt must fail on a correct contract
        try alice.joinLottery(address(lottery), uint256(0x02)) {
            return false; // second commit unexpectedly succeeded
        } catch {
            return true; // second commit reverted as expected
        }
    }

    // Invariant: revealing without a prior matching commit must be rejected.
    function echidna_reveal_requires_commit() public returns (bool) {
        // if alice never committed, her reveal must revert
        try alice.revealLottery(address(lottery), uint256(42)) {
            return false; // unexpected successful reveal
        } catch {
            return true; // reveal correctly reverted
        }
    }

    // Note: direct time fields are not exposed by the contract; instead we
    // validate phase behavior by attempting operations in different phases.

    // Invariant: at most one winner gets the upgraded allowance after a round
    function echidna_one_winner_only() public returns (bool) {
        // try to close the lottery gracefully; failing is acceptable
        try lottery.endLottery() {
        } catch {
        }

        uint count = 0;
        if (alice.getTaxAllowance() > 5000) count++;
        if (bob.getTaxAllowance() > 5000) count++;
        return count <= 1;
    }

    // Helper operations for fuzz sequences
    function startLottery() public { lottery.startLottery(); }
    function commitAlice(uint r) public { alice.joinLottery(address(lottery), r); }
    function commitBob(uint r) public { bob.joinLottery(address(lottery), r); }
    function revealAlice(uint r) public { alice.revealLottery(address(lottery), r); }
    function revealBob(uint r) public { bob.revealLottery(address(lottery), r); }
    function birthdayAlice() public { alice.haveBirthday(); }
    function birthdayBob() public { bob.haveBirthday(); }
}
