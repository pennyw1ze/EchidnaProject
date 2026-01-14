pragma solidity ^0.8.22;

import "./Lottery.sol";

/// @notice Refactored taxpayer contract for Part 3 (retirement allowance)
contract TaxpayerRetirementFixed {

    uint public age;
    bool public isMarried;
    bool internal _isContractFlag;
    address public spouse;
    address public parent1;
    address public parent2;

    uint private constant _BASE_ALLOWANCE = 5000;
    uint private constant _OAP_ALLOWANCE = 7000;

    uint public tax_allowance;
    uint income;
    uint256 rev;

    constructor(address p1, address p2) {
        age = 0;
        isMarried = false;
        parent1 = p1;
        parent2 = p2;
        spouse = address(0);
        income = 0;
        tax_allowance = _BASE_ALLOWANCE;
        _isContractFlag = true;
    }

    /// @notice Two-way marriage with basic sanity checks
    function tieKnot(address partner) public {
        require(partner != address(0), "null partner");
        require(!isMarried, "already married");
        require(spouse == address(0), "spouse set");
        require(partner != address(this), "self-marry");

        _establishMarriage(partner);
        TaxpayerRetirementFixed(partner)._establishMarriage(address(this));
    }

    function _establishMarriage(address partner) public {
        require(partner != address(0), "null partner");
        require(!isMarried, "already married");
        spouse = partner;
        isMarried = true;
    }

    /// @notice Two-way separation; both parties must have normalized allowance
    function separate() public {
        require(isMarried, "not married");
        require(spouse != address(0), "no spouse");

        // Require current allowance equals the personal default before separation
        require(tax_allowance == personalDefault(), "allowance not normalized");
        require(TaxpayerRetirementFixed(spouse).tax_allowance() == TaxpayerRetirementFixed(spouse).personalDefault(), "partner allowance not normalized");

        address ex = spouse;
        _breakMarriage();
        TaxpayerRetirementFixed(ex)._breakMarriage();
    }

    function _breakMarriage() public {
        require(isMarried, "not married");
        require(spouse != address(0), "no spouse");
        spouse = address(0);
        isMarried = false;
    }

    /// @notice Move part of your allowance to spouse
    function moveAllowance(uint amount) public {
        require(isMarried, "must be married");
        require(spouse != address(0), "no spouse");
        require(amount <= tax_allowance, "insufficient funds");

        tax_allowance -= amount;
        TaxpayerRetirementFixed sp = TaxpayerRetirementFixed(spouse);
        sp.setTaxAllowance(sp.getTaxAllowance() + amount);
    }

    /// @notice Increment age and apply retirement adjustment when turning 65
    function celebrateBirthday() public {
        age += 1;
        if (age == 65) {
            _updateForRetirement();
        }
    }

    function _updateForRetirement() internal {
        // Increase current allowance by the difference between OAP and base
        // This preserves any prior transfers and keeps pooled sums consistent
        if (_OAP_ALLOWANCE > _BASE_ALLOWANCE) {
            tax_allowance += (_OAP_ALLOWANCE - _BASE_ALLOWANCE);
        }
    }

    /// @notice Restrict direct allowance set to contracts (Lottery or other contract callers)
    function setTaxAllowance(uint ta) public {
        // Prefer checking code size of caller instead of unsafe type casts
        require(msg.sender.code.length > 0, "caller must be contract");
        tax_allowance = ta;
    }

    function getTaxAllowance() public view returns (uint) {
        return tax_allowance;
    }

    /// @notice personal default based on age group
    function personalDefault() public view returns (uint) {
        if (age >= 65) return _OAP_ALLOWANCE;
        return _BASE_ALLOWANCE;
    }

    /// @notice helper to satisfy earlier interface expectations
    function isContract() public view returns (bool) {
        return _isContractFlag;
    }

    function joinLottery(address lot, uint256 r) public {
        Lottery l = Lottery(lot);
        l.commit(keccak256(abi.encode(r)));
        rev = r;
    }

    function revealLottery(address lot, uint256 r) public {
        Lottery l = Lottery(lot);
        l.reveal(r);
        rev = 0;
    }
}
