// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/core/IDebtFacet.sol";
import "../storage/LibDebtStorage.sol";
import "../storage/LibAccessStorage.sol";

contract DebtFacet is IDebtFacet {
    using LibDebtStorage for DebtStorage;
    
    function createDebt(address creditor, uint256 amount) external returns (bytes32 debtId) {
        DebtStorage storage ds = LibDebtStorage.debtStorage();
        AccessStorage storage as = LibAccessStorage.accessStorage();
        
        require(as.kycVerified[msg.sender], "Debtor not KYC verified");
        require(as.kycVerified[creditor], "Creditor not KYC verified");
        
        debtId = keccak256(abi.encodePacked(msg.sender, creditor, amount, block.timestamp));
        
        ds.debts[debtId] = Debt({
            debtor: msg.sender,
            creditor: creditor,
            amount: amount,
            remainingAmount: amount,
            status: DebtStatus.ACTIVE,
            timestamp: block.timestamp,
            isTaxable: true
        });
        
        ds.debtorToCreditorDebts[msg.sender][creditor].push(debtId);
        
        emit DebtCreated(debtId, msg.sender, creditor, amount);
        return debtId;
    }

    function getDebt(bytes32 debtId) external view returns (Debt memory) {
        return LibDebtStorage.debtStorage().debts[debtId];
    }

    // ... implement other interface functions
} 