// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/oracle/ITaxOracleFacet.sol";
import "../interfaces/oracle/IChainOptimizerFacet.sol";
import "../interfaces/oracle/IKYCOracleFacet.sol";

struct OracleStorage {
    // Tax Oracle Storage
    mapping(address => uint256) taxRates;
    mapping(bytes32 => ITaxOracleFacet.TaxRateRequest) taxRequests;
    mapping(address => uint256) lastTaxUpdate;
    uint256 taxRateValidityPeriod;

    // Chain Optimizer Storage
    mapping(bytes32 => IChainOptimizerFacet.OptimizationRequest) optimizationRequests;
    mapping(bytes32 => address[]) optimizedRoutes;
    mapping(bytes32 => uint256) lastOptimization;
    uint256 optimizationValidityPeriod;

    // KYC Oracle Storage
    mapping(address => IKYCOracleFacet.KYCRequest) kycRequests;
    mapping(address => bool) kycStatus;
    mapping(address => uint256) kycExpiryTime;
    uint256 kycValidityPeriod;

    // Oracle Operators
    mapping(address => bool) taxOracles;
    mapping(address => bool) chainOptimizers;
    mapping(address => bool) kycVerifiers;
}

library LibOracleStorage {
    bytes32 constant ORACLE_STORAGE_POSITION = keccak256("debtchain.oracle.storage");

    function oracleStorage() internal pure returns (OracleStorage storage os) {
        bytes32 position = ORACLE_STORAGE_POSITION;
        assembly {
            os.slot := position
        }
    }

    function isOperator(address operator, bytes32 role) internal view returns (bool) {
        OracleStorage storage os = oracleStorage();
        if (role == keccak256("TAX_ORACLE")) {
            return os.taxOracles[operator];
        } else if (role == keccak256("CHAIN_OPTIMIZER")) {
            return os.chainOptimizers[operator];
        } else if (role == keccak256("KYC_VERIFIER")) {
            return os.kycVerifiers[operator];
        }
        return false;
    }
} 