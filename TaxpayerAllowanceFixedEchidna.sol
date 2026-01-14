pragma solidity ^0.8.22;

import "./TaxpayerFixed.sol";
import "./Lottery.sol";

/// @title Property-Based Testing for Tax Allowance System (Fixed Version)
/// @notice Tests invariants related to tax allowance pooling for married couples
/// @dev Part 2: Verifies that married couples can pool allowances while maintaining sum
contract TaxpayerAllowanceFixedEchidna {
    
    TaxpayerFixed public personA;
    TaxpayerFixed public personB;
    TaxpayerFixed public personC;
    
    uint constant DEFAULT_ALLOWANCE = 5000;
    
    constructor() {
        // Deploy three taxpayers for testing
        personA = new TaxpayerFixed(address(0), address(0));
        personB = new TaxpayerFixed(address(0), address(0));
        personC = new TaxpayerFixed(address(0), address(0));
    }
    
    // ==================== PART 2 INVARIANTS ====================
    
    /// @notice INVARIANT: Married couple's combined allowance equals 2 * DEFAULT
    /// @dev If A and B are married, A.allowance + B.allowance == 10000
    /// @return true if allowance pooling is conserved for all married couples
    function echidna_married_allowance_sum() public view returns (bool) {
        // Check if personA is married to personB
        if (personA.isMarried() && personA.spouse() == address(personB)) {
            uint sumAllowance = personA.getTaxAllowance() + personB.getTaxAllowance();
            if (sumAllowance != 2 * DEFAULT_ALLOWANCE) {
                return false;
            }
        }
        
        // Check if personA is married to personC
        if (personA.isMarried() && personA.spouse() == address(personC)) {
            uint sumAllowance = personA.getTaxAllowance() + personC.getTaxAllowance();
            if (sumAllowance != 2 * DEFAULT_ALLOWANCE) {
                return false;
            }
        }
        
        // Check if personB is married to personC
        if (personB.isMarried() && personB.spouse() == address(personC)) {
            uint sumAllowance = personB.getTaxAllowance() + personC.getTaxAllowance();
            if (sumAllowance != 2 * DEFAULT_ALLOWANCE) {
                return false;
            }
        }
        
        return true;
    }
    
    /// @notice INVARIANT: No individual exceeds maximum allowance
    /// @dev No one should have more than 2 * DEFAULT_ALLOWANCE
    /// @return true if all allowances remain within valid bounds
    function echidna_allowance_bounds() public view returns (bool) {
        uint allowanceA = personA.getTaxAllowance();
        uint allowanceB = personB.getTaxAllowance();
        uint allowanceC = personC.getTaxAllowance();
        
        // Check upper bound (no more than 2x default)
        if (allowanceA > 2 * DEFAULT_ALLOWANCE) return false;
        if (allowanceB > 2 * DEFAULT_ALLOWANCE) return false;
        if (allowanceC > 2 * DEFAULT_ALLOWANCE) return false;
        
        return true;
    }
    
    /// @notice INVARIANT: Total allowance in system remains constant
    /// @dev Sum of all allowances should equal 3 * DEFAULT_ALLOWANCE
    /// @return true if total allowance is conserved
    function echidna_total_allowance_conservation() public view returns (bool) {
        uint totalAllowance = personA.getTaxAllowance() + 
                              personB.getTaxAllowance() + 
                              personC.getTaxAllowance();
        
        // Total should always be 3 * DEFAULT_ALLOWANCE (15000)
        return totalAllowance == 3 * DEFAULT_ALLOWANCE;
    }
    
    /// @notice INVARIANT: Unmarried persons have default allowance
    /// @dev After divorce or when never married, allowance should be DEFAULT
    /// @return true if single persons have correct allowance
    function echidna_single_default_allowance() public view returns (bool) {
        // PersonA: if unmarried, should have DEFAULT allowance
        if (!personA.isMarried() && personA.spouse() == address(0)) {
            if (personA.getTaxAllowance() != DEFAULT_ALLOWANCE) {
                return false;
            }
        }
        
        // PersonB: if unmarried, should have DEFAULT allowance
        if (!personB.isMarried() && personB.spouse() == address(0)) {
            if (personB.getTaxAllowance() != DEFAULT_ALLOWANCE) {
                return false;
            }
        }
        
        // PersonC: if unmarried, should have DEFAULT allowance
        if (!personC.isMarried() && personC.spouse() == address(0)) {
            if (personC.getTaxAllowance() != DEFAULT_ALLOWANCE) {
                return false;
            }
        }
        
        return true;
    }
    
    // ==================== HELPER FUNCTIONS ====================
    
    /// @notice Marry personA to personB
    function marryAtoB() public {
        if (!personA.isMarried() && !personB.isMarried()) {
            // Age them if needed
            while (personA.age() < 18) personA.haveBirthday();
            while (personB.age() < 18) personB.haveBirthday();
            personA.marry(address(personB));
        }
    }
    
    /// @notice Marry personB to personC
    function marryBtoC() public {
        if (!personB.isMarried() && !personC.isMarried()) {
            while (personB.age() < 18) personB.haveBirthday();
            while (personC.age() < 18) personC.haveBirthday();
            personB.marry(address(personC));
        }
    }
    
    /// @notice Marry personA to personC
    function marryAtoC() public {
        if (!personA.isMarried() && !personC.isMarried()) {
            while (personA.age() < 18) personA.haveBirthday();
            while (personC.age() < 18) personC.haveBirthday();
            personA.marry(address(personC));
        }
    }
    
    /// @notice Transfer allowance from personA to spouse
    /// @param amount Amount to transfer (0-5000)
    function transferFromA(uint amount) public {
        if (personA.isMarried() && amount > 0 && amount <= personA.getTaxAllowance()) {
            personA.transferAllowance(amount);
        }
    }
    
    /// @notice Transfer allowance from personB to spouse
    /// @param amount Amount to transfer (0-5000)
    function transferFromB(uint amount) public {
        if (personB.isMarried() && amount > 0 && amount <= personB.getTaxAllowance()) {
            personB.transferAllowance(amount);
        }
    }
    
    /// @notice Transfer allowance from personC to spouse
    /// @param amount Amount to transfer (0-5000)
    function transferFromC(uint amount) public {
        if (personC.isMarried() && amount > 0 && amount <= personC.getTaxAllowance()) {
            personC.transferAllowance(amount);
        }
    }
    
    /// @notice Divorce personA
    function divorceA() public {
        if (personA.isMarried()) {
            personA.divorce();
        }
    }
    
    /// @notice Divorce personB
    function divorceB() public {
        if (personB.isMarried()) {
            personB.divorce();
        }
    }
    
    /// @notice Divorce personC
    function divorceC() public {
        if (personC.isMarried()) {
            personC.divorce();
        }
    }
    
    /// @notice Age personA
    function ageA() public {
        personA.haveBirthday();
    }
    
    /// @notice Age personB
    function ageB() public {
        personB.haveBirthday();
    }
    
    /// @notice Age personC
    function ageC() public {
        personC.haveBirthday();
    }
}
