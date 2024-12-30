// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITaxFacet {
    event TaxRateUpdated(uint256 newRate);
    event TaxCollected(address indexed taxpayer, uint256 amount);
    event TaxWithdrawn(address indexed to, uint256 amount);

    function setTaxRate(uint256 newRate) external;
    function calculateTax(uint256 amount) external view returns (uint256);
    function collectTax(address taxpayer, uint256 amount) external;
    function withdrawTax(address to, uint256 amount) external;
    function getTaxBalance(address taxpayer) external view returns (uint256);
} 