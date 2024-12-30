// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/core/ITaxFacet.sol";
import "../storage/LibTaxStorage.sol";
import "../storage/LibAccessStorage.sol";
import "../libraries/LibDiamond.sol";

contract TaxFacet is ITaxFacet {
    function setTaxRate(uint256 newRate) external {
        AccessStorage storage as = LibAccessStorage.accessStorage();
        require(as.roles[LibAccessStorage.TAX_MANAGER_ROLE][msg.sender], "Not tax manager");
        require(newRate <= 10000, "Tax rate exceeds maximum"); // Max 100%
        
        TaxStorage storage ts = LibTaxStorage.taxStorage();
        ts.taxRate = newRate;
        
        emit TaxRateUpdated(newRate);
    }

    function calculateTax(uint256 amount) external view returns (uint256) {
        TaxStorage storage ts = LibTaxStorage.taxStorage();
        return (amount * ts.taxRate) / 10000;
    }

    function collectTax(address taxpayer, uint256 amount) external {
        AccessStorage storage as = LibAccessStorage.accessStorage();
        require(as.roles[LibAccessStorage.TAX_MANAGER_ROLE][msg.sender], "Not tax manager");
        
        TaxStorage storage ts = LibTaxStorage.taxStorage();
        ts.taxBalances[taxpayer] += amount;
        ts.totalTaxCollected += amount;
        
        emit TaxCollected(taxpayer, amount);
    }

    function withdrawTax(address to, uint256 amount) external {
        LibDiamond.enforceIsContractOwner();
        TaxStorage storage ts = LibTaxStorage.taxStorage();
        require(amount <= ts.totalTaxCollected, "Insufficient tax balance");
        
        ts.totalTaxCollected -= amount;
        // Transfer implementation would go here
        // This would typically involve a call to transfer ETH or tokens
        
        emit TaxWithdrawn(to, amount);
    }

    function getTaxBalance(address taxpayer) external view returns (uint256) {
        return LibTaxStorage.taxStorage().taxBalances[taxpayer];
    }
} 