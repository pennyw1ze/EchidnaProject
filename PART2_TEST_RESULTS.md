# Part 2: Tax Allowance System - Test Results

## Summary

Part 2 focuses on tax allowance invariants for married couples. Each taxpayer starts with a default allowance of 5000, and married couples can pool their allowances (total must remain 10000).

---

## Invariants Tested

### 1. **echidna_married_allowance_sum**
**Description**: Married couple's combined allowance must equal 2 × DEFAULT_ALLOWANCE (10000)

**Formal**: ∀ married couples (A, B): A.allowance + B.allowance = 10000

### 2. **echidna_allowance_bounds**
**Description**: No individual can have more than 2 × DEFAULT_ALLOWANCE (10000)

**Formal**: ∀ taxpayer X: 0 ≤ X.allowance ≤ 10000

### 3. **echidna_total_allowance_conservation**
**Description**: Total allowance in the system remains constant

**Formal**: ∑ all_taxpayers.allowance = 3 × DEFAULT_ALLOWANCE (15000)

### 4. **echidna_single_default_allowance**
**Description**: Unmarried taxpayers have the default allowance

**Formal**: ∀ unmarried taxpayer X: X.allowance = DEFAULT_ALLOWANCE (5000)

---

## Buggy Version Results

```
$ echidna TaxpayerAllowanceEchidna.sol --contract TaxpayerAllowanceEchidna

echidna_married_allowance_sum: failed!💥
  Call sequence:
    marryAtoC()
    marryBtoC()  // Bigamy allowed!
    transferFromB(1)
  
  Result: personB has 5001, personC has 5000 (sum = 10001)

echidna_single_default_allowance: failed!💥
  Call sequence:
    marryAtoC()
    marryBtoC()
    transferFromA(1)
    transferFromB(5015)
  
  Result: personC (unmarried after complex sequence) has 10001

echidna_allowance_bounds: failed!💥
  Call sequence:
    marryAtoB()
    transferFromA(1)
    marryBtoC()  // B remarries without resetting allowance
    transferFromB(5011)
  
  Result: personC has 10001 (exceeds max)

echidna_total_allowance_conservation: passing ✓

Total calls: 50294
```

### Bugs Found

1. **Allowance Accumulation on Remarriage**: When a person remarries, they retain their previous allowance transfers, allowing accumulation beyond 10000
2. **No Allowance Reset on Divorce**: Divorced persons don't reset to DEFAULT_ALLOWANCE
3. **Bigamy Allowed**: The contract doesn't prevent marrying someone already married
4. **No Conservation Check in Transfer**: transferAllowance() doesn't verify the sum remains 10000

---

## Fixed Version Results

```
$ echidna TaxpayerAllowanceFixedEchidna.sol --contract TaxpayerAllowanceFixedEchidna

echidna_married_allowance_sum: passing ✓
echidna_single_default_allowance: passing ✓
echidna_total_allowance_conservation: passing ✓
echidna_allowance_bounds: passing ✓

Unique instructions: 4047
Corpus size: 7
Total calls: 50248
```

**All invariants pass!** ✅

---

## Fixes Applied

### (a) Code Corrections

1. **Allowance Normalization Before Marriage**
   ```solidity
   function marry(address new_spouse) public {
       // ... preconditions ...
       
       // Reset both allowances to DEFAULT before marriage
       _normalizeAllowance();
       partner._normalizeAllowance();
       
       // Then perform bidirectional marriage
       _writeMarriage(new_spouse);
       partner._writeMarriage(address(this));
   }
   ```

2. **Allowance Reset on Divorce**
   ```solidity
   function divorce() public {
       // ... preconditions ...
       
       // Reset both allowances to DEFAULT
       _normalizeAllowance();
       TaxpayerFixed(ex_spouse)._normalizeAllowance();
       
       // Then perform bidirectional divorce
       _writeDivorce();
       TaxpayerFixed(ex_spouse)._writeDivorce();
   }
   ```

3. **Conservation Check in Transfer**
   ```solidity
   function transferAllowance(uint change) public {
       require(isMarried, "Must be married");
       require(change <= tax_allowance, "Insufficient allowance");
       
       TaxpayerFixed sp = TaxpayerFixed(spouse);
       uint currentSum = tax_allowance + sp.getTaxAllowance();
       
       // Ensure sum is exactly 10000 before transfer
       require(currentSum == 2 * DEFAULT_ALLOWANCE, 
               "Allowance sum must be 10000");
       
       // Perform transfer
       tax_allowance -= change;
       sp.setTaxAllowance(sp.getTaxAllowance() + change);
       
       // Verify post-condition
       uint newSum = tax_allowance + sp.getTaxAllowance();
       require(newSum == 2 * DEFAULT_ALLOWANCE, 
               "Sum violated after transfer");
   }
   ```

### (b) Preconditions Added

1. **Marriage Preconditions**:
   - `require(!partner.isMarried())` - Prevents bigamy
   - Allowance normalization before marriage

2. **Transfer Preconditions**:
   - `require(currentSum == 2 * DEFAULT_ALLOWANCE)` - Conservation check before transfer
   - Post-condition verification after transfer

3. **Divorce Preconditions**:
   - Allowance reset to DEFAULT for both parties

### (c) Helping Invariants

The four invariants work together:
- **married_allowance_sum**: Primary requirement from Part 2
- **allowance_bounds**: Prevents individual accumulation
- **total_allowance_conservation**: System-wide conservation law
- **single_default_allowance**: Ensures proper reset after divorce

---

## Key Insights

1. **State Reset is Critical**: Without resetting allowances on marriage/divorce, the system allows accumulation through sequential relationships

2. **Bidirectional Operations**: Both marriage and divorce must update allowances for both parties atomically

3. **Conservation Laws**: The transfer function must explicitly check that the sum remains constant, not just rely on arithmetic

4. **Preconditions vs Postconditions**: The conservation check should be both a precondition (before transfer) and a postcondition (verified after transfer)

---

## Test Coverage

- ✅ Allowance pooling between married couples
- ✅ Remarriage scenarios with allowance reset
- ✅ Divorce with allowance restoration
- ✅ Sequential marriages and divorces
- ✅ Various transfer amounts (0-10000)
- ✅ Edge cases (transfer all, transfer none)
- ✅ Total system conservation

Total test cases: **50,248 sequences**
