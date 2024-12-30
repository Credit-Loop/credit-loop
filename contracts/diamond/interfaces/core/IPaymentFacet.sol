// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPaymentFacet {
    event PaymentInitiated(bytes32 indexed debtId, uint256 amount);
    event PaymentRouted(bytes32 indexed chainId, address indexed from, address indexed to, uint256 amount);
    event TaxDeducted(address indexed taxpayer, uint256 amount);

    function initiatePayment(bytes32 debtId, uint256 amount) external;
    function routePayment(bytes32 chainId, uint256 amount) external;
    function getTaxAmount(address taxpayer, uint256 amount) external view returns (uint256);
    function getPaymentHistory(bytes32 debtId) external view returns (Payment[] memory);
} 