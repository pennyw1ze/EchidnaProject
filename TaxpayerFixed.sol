pragma solidity ^0.8.22;

import "./Lottery.sol";

/// @notice Fixed Taxpayer contract with proper tax allowance management
/// @dev Part 2: Ensures married couples maintain allowance sum = 2 * DEFAULT
contract TaxpayerFixed {

 uint public age; 
 bool public isMarried; 
 bool iscontract;
 address public spouse; 
 address public parent1; 
 address public parent2; 

 uint constant DEFAULT_ALLOWANCE = 5000;
 uint constant ALLOWANCE_OAP = 7000;
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
   tax_allowance = DEFAULT_ALLOWANCE;
   iscontract = true;
 } 

 /// @notice Marry with bidirectional update and allowance preservation
 function marry(address new_spouse) public {
  require(new_spouse != address(0), "Cannot marry null address");
  require(!isMarried, "Already married");
  require(spouse == address(0), "Spouse already set");
  require(new_spouse != address(this), "Cannot marry yourself");
  require(age >= 18, "Must be 18 or older to marry");
  
  TaxpayerFixed partner = TaxpayerFixed(new_spouse);
  require(!partner.isMarried(), "Partner already married");
  require(partner.age() >= 18, "Partner must be 18 or older");
  
  // IMPORTANT: Before marriage, normalize both allowances to DEFAULT
  // This prevents accumulation from previous marriages
  _normalizeAllowance();
  partner._normalizeAllowance();
  
  // Now perform bidirectional marriage
  _writeMarriage(new_spouse);
  partner._writeMarriage(address(this));
 }
 
 /// @notice Reset allowance to default (called before marriage)
 function _normalizeAllowance() public {
  // Only callable by self or spouse
  require(msg.sender == address(this) || 
          (isMarried && msg.sender == spouse) ||
          TaxpayerFixed(msg.sender).isContract(),
          "Unauthorized");
  tax_allowance = DEFAULT_ALLOWANCE;
 }
 
 /// @notice Internal function to write marriage state
 function _writeMarriage(address new_spouse) public {
  require(new_spouse != address(0), "Cannot marry null address");
  require(!isMarried, "Already married");
  
  spouse = new_spouse;
  isMarried = true;
 }
 
 /// @notice Divorce with bidirectional update and allowance reset
 function divorce() public {
  require(isMarried, "Not married");
  require(spouse != address(0), "No spouse to divorce");
  
  address ex_spouse = spouse;
  
  // Reset both partners' allowances to default
  _normalizeAllowance();
  TaxpayerFixed(ex_spouse)._normalizeAllowance();
  
  // Perform bidirectional divorce
  _writeDivorce();
  TaxpayerFixed(ex_spouse)._writeDivorce();
 }
 
 /// @notice Internal function to write divorce state
 function _writeDivorce() public {
  require(isMarried, "Not married");
  require(spouse != address(0), "No spouse");
  
  spouse = address(0);
  isMarried = false;
 }

 /// @notice Transfer allowance to spouse (with conservation check)
 function transferAllowance(uint change) public {
  require(isMarried, "Must be married to transfer allowance");
  require(spouse != address(0), "No spouse");
  require(change <= tax_allowance, "Insufficient allowance");
  
  // Calculate what the sum will be after transfer
  TaxpayerFixed sp = TaxpayerFixed(address(spouse));
  uint currentSum = tax_allowance + sp.getTaxAllowance();
  
  // Ensure the sum remains 2 * DEFAULT_ALLOWANCE
  require(currentSum == 2 * DEFAULT_ALLOWANCE, "Allowance sum must be 10000");
  
  // Perform transfer
  tax_allowance = tax_allowance - change;
  sp.setTaxAllowance(sp.getTaxAllowance() + change);
  
  // Double-check post-condition
  uint newSum = tax_allowance + sp.getTaxAllowance();
  require(newSum == 2 * DEFAULT_ALLOWANCE, "Allowance sum violated after transfer");
 }

 function haveBirthday() public {
  age++;
 }
 
 function setTaxAllowance(uint ta) public {
    require(TaxpayerFixed(msg.sender).isContract() || 
            Lottery(msg.sender).isContract(), 
            "Unauthorized");
    tax_allowance = ta;
 }
 
 function getTaxAllowance() public view returns(uint) {
    return tax_allowance;
 }
 
 function isContract() public view returns(bool){
    return iscontract;
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
