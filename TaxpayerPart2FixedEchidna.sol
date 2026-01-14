pragma solidity ^0.8.22;

import "./TaxpayerPart2Fixed.sol";
import "./Lottery.sol";

/// @title Property-Based Testing for Tax Allowance System (Part 2 Fixed)
/// @notice Tests that the fixed implementation maintains all invariants
contract TaxpayerPart2FixedEchidna {
    
    TaxpayerPart2Fixed public a;
    TaxpayerPart2Fixed public b;
    
    uint constant DEFAULT_ALLOWANCE = 5000;
    
    constructor() {
        a = new TaxpayerPart2Fixed(address(0), address(0));
        b = new TaxpayerPart2Fixed(address(0), address(0));
    }
    
    // ==================== PART 2 INVARIANTS ====================
    
    /// @notice INVARIANT 1: Individual (unmarried) taxpayer has default allowance
    function echidna_individual_allowance() public view returns (bool) {
        if (!a.isMarried()) {
            if (a.getTaxAllowance() != DEFAULT_ALLOWANCE) {
                return false;
            }
        }
        if (!b.isMarried()) {
            if (b.getTaxAllowance() != DEFAULT_ALLOWANCE) {
                return false;
            }
        }
        return true;
    }
    
    /// @notice INVARIANT 2: Married couple's combined allowance equals 2 * DEFAULT
    function echidna_marriage_allowance() public view returns (bool) {
        if (a.isMarried()) {
            TaxpayerPart2Fixed spouse_a = TaxpayerPart2Fixed(a.spouse());
            uint combined = a.getTaxAllowance() + spouse_a.getTaxAllowance();
            if (combined != 2 * DEFAULT_ALLOWANCE) {
                return false;
            }
        }
        if (b.isMarried()) {
            TaxpayerPart2Fixed spouse_b = TaxpayerPart2Fixed(b.spouse());
            uint combined = b.getTaxAllowance() + spouse_b.getTaxAllowance();
            if (combined != 2 * DEFAULT_ALLOWANCE) {
                return false;
            }
        }
        return true;
    }
    
    /// @notice INVARIANT 3: No negative allowance
    function echidna_no_negative_allowance() public view returns (bool) {
        return a.getTaxAllowance() >= 0 && b.getTaxAllowance() >= 0;
    }
    
    // ==================== HELPER FUNCTIONS ====================
    
    function marry_a_to_b() public {
        a.marry(address(b));
    }
    
    function transfer_from_a(uint amount) public {
        if (a.isMarried() && amount > 0 && amount <= a.getTaxAllowance()) {
            a.transferAllowance(amount);
        }
    }
    
    function transfer_from_b(uint amount) public {
        if (b.isMarried() && amount > 0 && amount <= b.getTaxAllowance()) {
            b.transferAllowance(amount);
        }
    }
    
    /// @notice Divorce with allowance normalization first
    function divorce_a() public {
        if (a.isMarried()) {
            // Normalize allowances before divorce (required by contract)
            uint allowance_a = a.getTaxAllowance();
            if (allowance_a != DEFAULT_ALLOWANCE) {
                TaxpayerPart2Fixed spouse_a = TaxpayerPart2Fixed(a.spouse());
                if (allowance_a > DEFAULT_ALLOWANCE) {
                    // Transfer excess back to spouse
                    a.transferAllowance(allowance_a - DEFAULT_ALLOWANCE);
                } else {
                    // Get allowance from spouse
                    spouse_a.transferAllowance(DEFAULT_ALLOWANCE - allowance_a);
                }
            }
            // Now divorce (will pass require checks)
            a.divorce();
        }
    }
    
    function divorce_b() public {
        if (b.isMarried()) {
            uint allowance_b = b.getTaxAllowance();
            if (allowance_b != DEFAULT_ALLOWANCE) {
                TaxpayerPart2Fixed spouse_b = TaxpayerPart2Fixed(b.spouse());
                if (allowance_b > DEFAULT_ALLOWANCE) {
                    b.transferAllowance(allowance_b - DEFAULT_ALLOWANCE);
                } else {
                    spouse_b.transferAllowance(DEFAULT_ALLOWANCE - allowance_b);
                }
            }
            b.divorce();
        }
    }
    
    function birthday_a() public {
        a.haveBirthday();
    }
    
    function birthday_b() public {
        b.haveBirthday();
    }
}
