pragma solidity ^0.8.22;

import "./Lottery.sol";

/// @notice Fixed Taxpayer contract - Part 2: Tax Allowance System
/// @dev Implements proper allowance management for married couples
contract TaxpayerPart2Fixed {

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

 /// @notice Marry with bidirectional update
 function marry(address new_spouse) public {
  require(new_spouse != address(0), "Cannot marry null address");
  require(!isMarried, "Already married");
  require(spouse == address(0), "Spouse already set");
  require(new_spouse != address(this), "Cannot marry yourself");
  
  // Write marriage for this taxpayer
  _writeMarriage(new_spouse);
  
  // Automatically update spouse's record
  TaxpayerPart2Fixed(new_spouse)._writeMarriage(address(this));
 }
 
 /// @notice Internal function to write marriage state
 function _writeMarriage(address new_spouse) public {
  require(new_spouse != address(0), "Cannot marry null address");
  require(!isMarried, "Already married");
  
  spouse = new_spouse;
  isMarried = true;
 }
 
 /// @notice Divorce with bidirectional update
 /// @dev PART 2 FIX: Requires both taxpayers have default allowance before divorce
 function divorce() public {
  require(isMarried, "Not married");
  require(spouse != address(0), "No spouse to divorce");
  
  // PART 2 FIX: Ensure allowances are normalized before divorce
  require(tax_allowance == DEFAULT_ALLOWANCE, "Must have default allowance to divorce");
  require(TaxpayerPart2Fixed(spouse).getTaxAllowance() == DEFAULT_ALLOWANCE, "Spouse must have default allowance");
  
  address ex_spouse = spouse;
  
  // Write divorce for this taxpayer
  _writeDivorce();
  
  // Automatically update ex-spouse's record
  TaxpayerPart2Fixed(ex_spouse)._writeDivorce();
 }
 
 /// @notice Internal function to write divorce state
 function _writeDivorce() public {
  require(isMarried, "Not married");
  require(spouse != address(0), "No spouse");
  
  spouse = address(0);
  isMarried = false;
 }

 /// @notice Transfer allowance to spouse
 /// @dev PART 2 FIX: Added preconditions for safe transfer
 function transferAllowance(uint change) public {
  require(isMarried, "Must be married to transfer allowance");
  require(spouse != address(0), "No spouse");
  require(change <= tax_allowance, "Insufficient allowance to transfer");
  
  tax_allowance = tax_allowance - change;
  TaxpayerPart2Fixed sp = TaxpayerPart2Fixed(address(spouse));
  sp.setTaxAllowance(sp.getTaxAllowance() + change);
 }

 function haveBirthday() public {
  age++;
 }
 
 function setTaxAllowance(uint ta) public {
    require(TaxpayerPart2Fixed(msg.sender).isContract() || Lottery(msg.sender).isContract(), "Unauthorized");
    tax_allowance = ta;
 }
 
 function getTaxAllowance() public view returns(uint) {
    return tax_allowance;
 }
 
 function getDefaultAllowance() public pure returns(uint) {
    return DEFAULT_ALLOWANCE;
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
