pragma solidity ^0.8.22;

import "./Taxpayer.sol";
import "./Lottery.sol";

/// @title Property-Based Testing Harness for Taxpayer Contract
/// @author Security Testing Framework
/// @notice Fuzzing-based invariant validation for marriage relationship constraints
contract TaxpayerEchidna {
    
    Taxpayer public alice;
    Taxpayer public bob;
    Taxpayer public charlie;
    
    constructor() {
        // Deploy test subjects with no initial lottery or spouse
        alice = new Taxpayer(address(0), address(0));
        bob = new Taxpayer(address(0), address(0));
        charlie = new Taxpayer(address(0), address(0));
    }
    
    // ==================== INVARIANT CHECKS ====================
    
    /// @notice INVARIANT 1: Marriage relationship must be bidirectional
    /// @dev Core requirement: if A.spouse == B then B.spouse == A
    /// @return true if symmetry holds for all test subjects
    function echidna_marriage_symmetry() public view returns (bool) {
        // Check Alice's marriage reciprocity
        if (alice.isMarried()) {
            address aliceSpouse = alice.spouse();
            Taxpayer alicePartner = Taxpayer(aliceSpouse);
            if (!alicePartner.isMarried() || alicePartner.spouse() != address(alice)) {
                return false; // Alice claims marriage but partner doesn't reciprocate
            }
        }
        
        // Check Bob's marriage reciprocity
        if (bob.isMarried()) {
            address bobSpouse = bob.spouse();
            Taxpayer bobPartner = Taxpayer(bobSpouse);
            if (!bobPartner.isMarried() || bobPartner.spouse() != address(bob)) {
                return false; // Bob claims marriage but partner doesn't reciprocate
            }
        }
        
        // Check Charlie's marriage reciprocity
        if (charlie.isMarried()) {
            address charlieSpouse = charlie.spouse();
            Taxpayer charliePartner = Taxpayer(charlieSpouse);
            if (!charliePartner.isMarried() || charliePartner.spouse() != address(charlie)) {
                return false; // Charlie claims marriage but partner doesn't reciprocate
            }
        }
        
        return true; // All marriages are symmetric
    }
    
    /// @notice INVARIANT 2: Married status requires valid spouse reference
    /// @dev A taxpayer marked as married must have non-zero spouse address
    /// @return true if all married taxpayers have valid spouse addresses
    function echidna_marriage_nonnull() public view returns (bool) {
        // Validate Alice's marriage state consistency
        if (alice.isMarried() && alice.spouse() == address(0)) {
            return false; // Married but spouse is null - invalid state
        }
        
        // Validate Bob's marriage state consistency
        if (bob.isMarried() && bob.spouse() == address(0)) {
            return false; // Married but spouse is null - invalid state
        }
        
        // Validate Charlie's marriage state consistency
        if (charlie.isMarried() && charlie.spouse() == address(0)) {
            return false; // Married but spouse is null - invalid state
        }
        
        return true; // All marriage states are consistent
    }
    
    /// @notice INVARIANT 3: Self-referential marriages are forbidden
    /// @dev No taxpayer can be their own spouse
    /// @return true if no taxpayer is married to themselves
    function echidna_no_self_marriage() public view returns (bool) {
        // Verify Alice is not self-married
        if (alice.isMarried() && alice.spouse() == address(alice)) {
            return false; // Alice married to herself - forbidden
        }
        
        // Verify Bob is not self-married
        if (bob.isMarried() && bob.spouse() == address(bob)) {
            return false; // Bob married to himself - forbidden
        }
        
        // Verify Charlie is not self-married
        if (charlie.isMarried() && charlie.spouse() == address(charlie)) {
            return false; // Charlie married to himself - forbidden
        }
        
        return true; // No self-marriages detected
    }
    
    /// @notice INVARIANT 4: Age restriction enforcement for marriage
    /// @dev Marriage is only valid for taxpayers aged 18 or above
    /// @return true if no minors are married
    function echidna_no_minor_marriage() public view returns (bool) {
        // Check if Alice is underage and married
        if (alice.isMarried()) {
            uint256 aliceAge = alice.age();
            if (aliceAge < 18) {
                return false; // Alice is minor but married - violation
            }
        }
        
        // Check if Bob is underage and married
        if (bob.isMarried()) {
            uint256 bobAge = bob.age();
            if (bobAge < 18) {
                return false; // Bob is minor but married - violation
            }
        }
        
        // Check if Charlie is underage and married
        if (charlie.isMarried()) {
            uint256 charlieAge = charlie.age();
            if (charlieAge < 18) {
                return false; // Charlie is minor but married - violation
            }
        }
        
        return true; // All married taxpayers meet age requirement
    }
    
    /// @notice INVARIANT 5: Divorce clears spouse reference
    /// @dev Unmarried taxpayers must have null spouse field
    /// @return true if all unmarried taxpayers have null spouse
    function echidna_divorce_consistency() public view returns (bool) {
        // Ensure Alice's divorce is complete
        if (!alice.isMarried() && alice.spouse() != address(0)) {
            return false; // Not married but still has spouse reference
        }
        
        // Ensure Bob's divorce is complete
        if (!bob.isMarried() && bob.spouse() != address(0)) {
            return false; // Not married but still has spouse reference
        }
        
        // Ensure Charlie's divorce is complete
        if (!charlie.isMarried() && charlie.spouse() != address(0)) {
            return false; // Not married but still has spouse reference
        }
        
        return true; // All divorces properly clear spouse data
    }
    
    // ==================== HELPER FUNCTIONS FOR FUZZING ====================
    
    /// @notice Attempt to marry Alice with null spouse (tests null validation)
    function attemptNullMarriage() public {
        alice.marry(address(0));
    }
    
    /// @notice Attempt self-marriage for Alice (tests self-reference validation)
    function attemptSelfMarriage() public {
        alice.marry(address(alice));
    }
    
    /// @notice Create unidirectional marriage from Bob to Alice (tests symmetry)
    function createAsymmetricMarriage() public {
        bob.marry(address(alice));
    }
    
    /// @notice Establish marriage between Alice and Bob
    function marryAliceToBob() public {
        alice.marry(address(bob));
    }
    
    /// @notice Establish marriage between Bob and Charlie
    function marryBobToCharlie() public {
        bob.marry(address(charlie));
    }
    
    /// @notice Establish marriage between Alice and Charlie
    function marryAliceToCharlie() public {
        alice.marry(address(charlie));
    }
    
    /// @notice Dissolve Alice's marriage
    function divorceAlice() public {
        alice.divorce();
    }
    
    /// @notice Dissolve Bob's marriage
    function divorceBob() public {
        bob.divorce();
    }
    
    /// @notice Dissolve Charlie's marriage
    function divorceCharlie() public {
        charlie.divorce();
    }
    
    /// @notice Age Alice by one year
    function ageAlice() public {
        alice.haveBirthday();
    }
    
    /// @notice Age Bob by one year
    function ageBob() public {
        bob.haveBirthday();
    }
    
    /// @notice Age Charlie by one year
    function ageCharlie() public {
        charlie.haveBirthday();
    }
}
