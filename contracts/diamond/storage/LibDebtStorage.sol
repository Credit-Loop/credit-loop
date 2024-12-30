// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct DebtStorage {
    // Core debt mappings
    mapping(bytes32 => Debt) debts;
    mapping(address => mapping(address => bytes32[])) debtorToCreditorDebts;
    
    // Debt-specific data structures
    mapping(bytes32 => Payment[]) debtPayments;
    mapping(address => Payment[]) userPayments;
}

struct Debt {
    address debtor;
    address creditor;
    uint256 amount;
    uint256 remainingAmount;
    DebtStatus status;
    uint256 timestamp;
    bool isTaxable;
}

struct Payment {
    bytes32 debtId;
    address from;
    address to;
    uint256 amount;
    uint256 timestamp;
    bool isTaxed;
    uint256 taxAmount;
}

enum DebtStatus {
    ACTIVE,
    PARTIALLY_PAID,
    FULLY_PAID,
    CANCELLED
}

library LibDebtStorage {
    bytes32 constant DEBT_STORAGE_POSITION = keccak256("debtchain.debt.storage");

    function debtStorage() internal pure returns (DebtStorage storage ds) {
        bytes32 position = DEBT_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
} 