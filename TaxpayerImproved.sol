pragma solidity ^0.8.22;

import "./Lottery.sol";

/// @notice Improved Taxpayer contract with automatic bidirectional marriage
/// @dev This version automatically updates both parties in marriage/divorce
contract TaxpayerImproved {

 uint public age; 
 bool public isMarried; 
 bool iscontract;
 address public spouse; 
 address public parent1; 
 address public parent2; 

 uint constant DEFAULT_ALLOWANCE = 5000;
 uint constant ALLOWANCE_OAP = 7000;
 uint tax_allowance; 
 uint income; 
 uint256 rev;

 // Track if we're in a recursive call to prevent infinite loops
 bool private inMarriageUpdate;

 constructor(address p1, address p2) {
   age = 0;
   isMarried = false;
   parent1 = p1;
   parent2 = p2;
   spouse = address(0);
   income = 0;
   tax_allowance = DEFAULT_ALLOWANCE;
   iscontract = true;
   inMarriageUpdate = false;
 } 

 /// @notice Marry another taxpayer with automatic bidirectional update
 /// @param new_spouse The address of the person to marry
 function marry(address new_spouse) public {
  require(new_spouse != address(0), "Cannot marry null address");
  require(!isMarried, "Already married");
  require(spouse == address(0), "Spouse already set");
  require(new_spouse != address(this), "Cannot marry yourself");
  
  spouse = new_spouse;
  isMarried = true;
  
  // Automatically update the spouse's record if not already in a recursive call
  if (!inMarriageUpdate) {
    inMarriageUpdate = true;
    TaxpayerImproved(new_spouse).marryInternal(address(this));
    inMarriageUpdate = false;
  }
 }
 
 /// @notice Internal function called by spouse's marry() function
 /// @param new_spouse The address of the person marrying this taxpayer
 function marryInternal(address new_spouse) external {
  require(new_spouse != address(0), "Cannot marry null address");
  require(!isMarried, "Already married");
  require(spouse == address(0), "Spouse already set");
  
  spouse = new_spouse;
  isMarried = true;
 }
 
 /// @notice Divorce with automatic bidirectional update
 function divorce() public {
  require(isMarried, "Not married");
  require(spouse != address(0), "No spouse to divorce");
  
  address ex_spouse = spouse;
  spouse = address(0);
  isMarried = false;
  
  // Automatically update the ex-spouse's record if not already in a recursive call
  if (!inMarriageUpdate && ex_spouse != address(0)) {
    inMarriageUpdate = true;
    TaxpayerImproved(ex_spouse).divorceInternal();
    inMarriageUpdate = false;
  }
 }
 
 /// @notice Internal function called by spouse's divorce() function
 function divorceInternal() external {
  require(isMarried, "Not married");
  spouse = address(0);
  isMarried = false;
 }

 /// @notice Transfer part of tax allowance to own spouse
 function transferAllowance(uint change) public {
  require(isMarried, "Must be married to transfer allowance");
  require(spouse != address(0), "No spouse");
  require(change <= tax_allowance, "Insufficient allowance");
  
  tax_allowance = tax_allowance - change;
  TaxpayerImproved sp = TaxpayerImproved(address(spouse));
  sp.setTaxAllowance(sp.getTaxAllowance()+change);
 }

 function haveBirthday() public {
  age++;
 }
 
 function setTaxAllowance(uint ta) public {
    require(TaxpayerImproved(msg.sender).isContract() || Lottery(msg.sender).isContract());
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
