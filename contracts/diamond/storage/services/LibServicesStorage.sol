// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../interfaces/services/IAIAnalysisService.sol";
import "../../interfaces/services/IZKProofService.sol";

library LibServicesStorage {
    bytes32 constant STORAGE_POSITION = keccak256("debtchain.services.storage");

    struct ServicesStorage {
        // AI Analysis
        mapping(bytes32 => IAIAnalysisService.AnalysisRequest) analysisRequests;
        mapping(bytes32 => IAIAnalysisService.AnalysisResult) analysisResults;
        mapping(bytes32 => bytes32) documentToRequestId;
        mapping(address => bool) authorizedAnalyzers;
        
        // ZK Proof
        mapping(bytes32 => IZKProofService.ProofRequest) proofRequests;
        mapping(bytes32 => IZKProofService.ProofData) proofData;
        mapping(bytes32 => bytes32) documentToProofId;
        mapping(address => bool) authorizedProvers;
        
        // System Parameters
        uint256 analysisTimeout;
        uint256 proofTimeout;
        bytes currentVerifierKey;
        mapping(bytes32 => string[]) supportedFields;
    }

    function servicesStorage() internal pure returns (ServicesStorage storage ss) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            ss.slot := position
        }
    }
} 