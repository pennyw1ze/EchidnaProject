pragma solidity ^0.8.22;
// SPDX-License-Identifier: UNLICENSED
import "./Taxpayer.sol";

contract LotteryFixed {
    address owner;
    mapping (address => bytes32) commits;
    mapping (address => uint) reveals;
    address[] revealed;

    uint256 private startTime;
    uint256 private revealTime;
    uint256 private endTime;
    uint256 private period;
    bool iscontract;

    constructor(uint p) {
        period = p;
        startTime = 0;
        endTime = 0;
        iscontract = true;
    }

    function startLottery() public {
        require(startTime == 0, "already started");
        startTime = block.timestamp;
        revealTime = startTime + period;
        endTime = revealTime + period;
    }

    // Commit only during commit phase, only once per participant
    function commit(bytes32 y) public {
        require(startTime > 0, "Lottery not started");
        require(block.timestamp >= startTime && block.timestamp < revealTime, "Not in commit phase");
        require(commits[msg.sender] == bytes32(0), "Already committed");
        commits[msg.sender] = y;
    }

    // Reveal only during reveal phase and must match prior commit
    function reveal(uint256 rev) public {
        require(revealTime > 0 && endTime > 0, "Lottery phases not configured");
        require(block.timestamp >= revealTime && block.timestamp < endTime, "Not in reveal phase");
        require(commits[msg.sender] != bytes32(0), "No commit for sender");
        require(keccak256(abi.encode(rev)) == commits[msg.sender], "Reveal does not match commit");
        revealed.push(msg.sender);
        reveals[msg.sender] = uint(rev);
    }

    function endLottery() public {
        require(block.timestamp >= endTime, "Too early to end");
        uint total = 0;
        for (uint i = 0; i < revealed.length; i++) total += reveals[revealed[i]];
        if (revealed.length == 0) {
            // reset phases
            startTime = 0;
            revealTime = 0;
            endTime = 0;
            return;
        }
        Taxpayer(revealed[total % revealed.length]).setTaxAllowance(7000);
        startTime = 0;
        revealTime = 0;
        endTime = 0;
    }

    function isContract() public view returns (bool) {
        return iscontract;
    }

    // Expose times for testing convenience
    function getStartTime() public view returns (uint256) { return startTime; }
    function getRevealTime() public view returns (uint256) { return revealTime; }
    function getEndTime() public view returns (uint256) { return endTime; }
    function getCommit(address a) public view returns (bytes32) { return commits[a]; }
    function getRevealValue(address a) public view returns (uint) { return reveals[a]; }
}
