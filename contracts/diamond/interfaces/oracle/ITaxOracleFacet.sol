// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITaxOracleFacet {
    event TaxRateUpdated(uint256 newRate, uint256 timestamp);
    event TaxServiceResponseReceived(bytes32 requestId, uint256 rate);
    event TaxCalculationRequested(bytes32 requestId, address taxpayer, uint256 amount);

    struct TaxRateRequest {
        address taxpayer;
        uint256 amount;
        uint256 timestamp;
        bool fulfilled;
        uint256 result;
    }

    function requestTaxRate(address taxpayer, uint256 amount) external returns (bytes32 requestId);
    function updateTaxRate(bytes32 requestId, uint256 rate) external;
    function getTaxRate(address taxpayer) external view returns (uint256);
    function getLastTaxCalculation(address taxpayer) external view returns (TaxRateRequest memory);
    function isTaxRateStale(address taxpayer) external view returns (bool);
} 