// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/core/IPaymentFacet.sol";
import "../storage/LibDebtStorage.sol";
import "../storage/LibChainStorage.sol";
import "../storage/LibAccessStorage.sol";

contract PaymentFacet is IPaymentFacet {
    function initiatePayment(bytes32 debtId, uint256 amount) external {
        DebtStorage storage ds = LibDebtStorage.debtStorage();
        AccessStorage storage as = LibAccessStorage.accessStorage();
        
        Debt storage debt = ds.debts[debtId];
        require(debt.debtor == msg.sender, "Not the debtor");
        require(debt.status != DebtStatus.FULLY_PAID, "Debt already paid");
        require(amount <= debt.remainingAmount, "Amount exceeds remaining debt");
        require(as.kycVerified[msg.sender], "Debtor not KYC verified");
        
        // Create payment record
        Payment memory payment = Payment({
            debtId: debtId,
            from: msg.sender,
            to: debt.creditor,
            amount: amount,
            timestamp: block.timestamp,
            isTaxed: debt.isTaxable,
            taxAmount: debt.isTaxable ? calculateTax(amount) : 0
        });
        
        ds.debtPayments[debtId].push(payment);
        ds.userPayments[msg.sender].push(payment);
        
        // Update debt status
        debt.remainingAmount -= amount;
        if (debt.remainingAmount == 0) {
            debt.status = DebtStatus.FULLY_PAID;
        } else {
            debt.status = DebtStatus.PARTIALLY_PAID;
        }
        
        emit PaymentInitiated(debtId, amount);
    }

    function getTaxAmount(address taxpayer, uint256 amount) external view returns (uint256) {
        return calculateTax(amount);
    }

    function getPaymentHistory(bytes32 debtId) external view returns (Payment[] memory) {
        return LibDebtStorage.debtStorage().debtPayments[debtId];
    }

    // Internal helper function
    function calculateTax(uint256 amount) internal pure returns (uint256) {
        // Implement tax calculation logic here
        return amount * 10 / 100; // Example: 10% tax
    }
} 