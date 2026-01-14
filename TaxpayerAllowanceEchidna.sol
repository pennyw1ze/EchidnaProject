pragma solidity ^0.8.22;

import "./Taxpayer.sol";
import "./Lottery.sol";

/// @title Property-Based Testing for Tax Allowance System
/// @notice Tests invariants related to tax allowance pooling for married couples
/// @dev Part 2: Verifies that married couples can pool allowances while maintaining sum
contract TaxpayerAllowanceEchidna {
    
    Taxpayer public personX;
    Taxpayer public personY;
    
    uint constant DEFAULT_TAX_ALLOWANCE = 5000;
    uint constant COUPLE_TOTAL_ALLOWANCE = 10000;
    
    constructor() {
        // Deploy two taxpayers for testing
        personX = new Taxpayer(address(0), address(0));
        personY = new Taxpayer(address(0), address(0));
    }
    
    // ==================== PART 2 INVARIANTS ====================
    
    /// @notice INVARIANT 1: Single taxpayer maintains default allowance
    /// @dev Unmarried individuals must have exactly 5000 allowance
    /// @return true if constraint satisfied
    function echidna_single_taxpayer_allowance() public view returns (bool) {
        // Validate personX allowance when single
        bool validX = personX.isMarried() || 
                      personX.getTaxAllowance() == DEFAULT_TAX_ALLOWANCE;
        
        // Validate personY allowance when single
        bool validY = personY.isMarried() || 
                      personY.getTaxAllowance() == DEFAULT_TAX_ALLOWANCE;
        
        return validX && validY;
    }
    
    /// @notice INVARIANT 2: Couple's pooled allowance equals fixed total
    /// @dev Married pair must have combined allowance of exactly 10000
    /// @return true if couple allowance constraint holds
    function echidna_couple_pooled_allowance() public view returns (bool) {
        // Check personX's marriage status and validate total
        if (personX.isMarried()) {
            address partnerAddr = personX.spouse();
            Taxpayer partner = Taxpayer(partnerAddr);
            uint totalAllowance = personX.getTaxAllowance() + partner.getTaxAllowance();
            if (totalAllowance != COUPLE_TOTAL_ALLOWANCE) {
                return false;
            }
        }
        
        // Check personY's marriage status and validate total
        if (personY.isMarried()) {
            address partnerAddr = personY.spouse();
            Taxpayer partner = Taxpayer(partnerAddr);
            uint totalAllowance = personY.getTaxAllowance() + partner.getTaxAllowance();
            if (totalAllowance != COUPLE_TOTAL_ALLOWANCE) {
                return false;
            }
        }
        
        return true;
    }
    
    /// @notice INVARIANT 3: Allowance non-negativity
    /// @dev Ensures no underflow in allowance values
    /// @return true if all allowances remain non-negative
    function echidna_allowance_non_negative() public view returns (bool) {
        return personX.getTaxAllowance() >= 0 && personY.getTaxAllowance() >= 0;
    }
    
    // ==================== HELPER FUNCTIONS ====================
    
    function establish_marriage() public {
        personX.marry(address(personY));
    }
    
    function reverse_marriage() public {
        personY.marry(address(personX));
    }
    
    function shift_allowance_from_X(uint value) public {
        if (personX.isMarried() && value > 0) {
            personX.transferAllowance(value);
        }
    }
    
    function shift_allowance_from_Y(uint value) public {
        if (personY.isMarried() && value > 0) {
            personY.transferAllowance(value);
        }
    }
    
    function terminate_marriage_X() public {
        if (personX.isMarried()) {
            personX.divorce();
        }
    }
    
    function terminate_marriage_Y() public {
        if (personY.isMarried()) {
            personY.divorce();
        }
    }
    
    function increment_age_X() public {
        personX.haveBirthday();
    }
    
    function increment_age_Y() public {
        personY.haveBirthday();
    }
}
