// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../interfaces/oracle/ITaxOracleFacet.sol";
import "../../storage/LibOracleStorage.sol";
import "../../libraries/LibDiamond.sol";

contract TaxOracleFacet is ITaxOracleFacet {
    function requestTaxRate(address taxpayer, uint256 amount) external returns (bytes32 requestId) {
        OracleStorage storage os = LibOracleStorage.oracleStorage();
        
        requestId = keccak256(abi.encodePacked(taxpayer, amount, block.timestamp));
        
        os.taxRequests[requestId] = TaxRateRequest({
            taxpayer: taxpayer,
            amount: amount,
            timestamp: block.timestamp,
            fulfilled: false,
            result: 0
        });
        
        emit TaxCalculationRequested(requestId, taxpayer, amount);
        return requestId;
    }

    function updateTaxRate(bytes32 requestId, uint256 rate) external {
        OracleStorage storage os = LibOracleStorage.oracleStorage();
        require(LibOracleStorage.isOperator(msg.sender, keccak256("TAX_ORACLE")), "Not authorized");
        
        TaxRateRequest storage request = os.taxRequests[requestId];
        require(!request.fulfilled, "Request already fulfilled");
        
        request.fulfilled = true;
        request.result = rate;
        os.taxRates[request.taxpayer] = rate;
        os.lastTaxUpdate[request.taxpayer] = block.timestamp;
        
        emit TaxRateUpdated(rate, block.timestamp);
        emit TaxServiceResponseReceived(requestId, rate);
    }

    function getTaxRate(address taxpayer) external view returns (uint256) {
        return LibOracleStorage.oracleStorage().taxRates[taxpayer];
    }

    function getLastTaxCalculation(address taxpayer) external view returns (TaxRateRequest memory) {
        OracleStorage storage os = LibOracleStorage.oracleStorage();
        bytes32 lastRequestId;
        uint256 lastTimestamp = 0;
        
        // Note: In a production environment, we would maintain a mapping of
        // taxpayer to their last request ID for efficient lookup
        for (uint i = 0; i < 100; i++) { // Limit loop to prevent DOS
            bytes32 potentialId = keccak256(abi.encodePacked(taxpayer, i));
            TaxRateRequest storage request = os.taxRequests[potentialId];
            if (request.timestamp > lastTimestamp && request.taxpayer == taxpayer) {
                lastRequestId = potentialId;
                lastTimestamp = request.timestamp;
            }
        }
        
        require(lastTimestamp > 0, "No tax calculations found");
        return os.taxRequests[lastRequestId];
    }

    function isTaxRateStale(address taxpayer) external view returns (bool) {
        OracleStorage storage os = LibOracleStorage.oracleStorage();
        uint256 lastUpdate = os.lastTaxUpdate[taxpayer];
        return block.timestamp > lastUpdate + os.taxRateValidityPeriod;
    }
} 