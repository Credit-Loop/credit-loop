// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct TaxStorage {
    uint256 taxRate; // Base points (1/10000)
    mapping(address => uint256) taxBalances;
    uint256 totalTaxCollected;
}

library LibTaxStorage {
    bytes32 constant TAX_STORAGE_POSITION = keccak256("debtchain.tax.storage");

    function taxStorage() internal pure returns (TaxStorage storage ts) {
        bytes32 position = TAX_STORAGE_POSITION;
        assembly {
            ts.slot := position
        }
    }
} 