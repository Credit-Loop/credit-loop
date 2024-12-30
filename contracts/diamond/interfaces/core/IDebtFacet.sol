// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDebtFacet {
    event DebtCreated(bytes32 indexed debtId, address indexed debtor, address indexed creditor, uint256 amount);
    event DebtUpdated(bytes32 indexed debtId, uint256 newAmount, DebtStatus status);
    event DebtSettled(bytes32 indexed debtId);

    function createDebt(address creditor, uint256 amount) external returns (bytes32 debtId);
    function getDebt(bytes32 debtId) external view returns (Debt memory);
    function updateDebtStatus(bytes32 debtId, DebtStatus status) external;
    function getDebtsBetween(address debtor, address creditor) external view returns (bytes32[] memory);
    function validateDebt(bytes32 debtId) external view returns (bool);
} 