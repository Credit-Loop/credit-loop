// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../interfaces/services/IAIAnalysisService.sol";
import "../../storage/services/LibServicesStorage.sol";
import "../../libraries/LibDiamond.sol";

contract AIAnalysisFacet is IAIAnalysisService {
    using LibServicesStorage for LibServicesStorage.ServicesStorage;

    modifier onlyAuthorizedAnalyzer() {
        require(
            LibServicesStorage.servicesStorage().authorizedAnalyzers[msg.sender],
            "Not authorized analyzer"
        );
        _;
    }

    function requestAnalysis(
        bytes32 documentHash,
        bytes calldata documentMetadata
    ) external override returns (bytes32) {
        bytes32 requestId = keccak256(abi.encodePacked(
            documentHash,
            msg.sender,
            block.timestamp,
            "AI_ANALYSIS"
        ));
        
        LibServicesStorage.ServicesStorage storage ss = LibServicesStorage.servicesStorage();
        ss.analysisRequests[requestId] = AnalysisRequest({
            documentHash: documentHash,
            submitter: msg.sender,
            timestamp: block.timestamp,
            isProcessed: false,
            documentMetadata: documentMetadata,
            resultHash: bytes32(0)
        });
        
        ss.documentToRequestId[documentHash] = requestId;
        
        emit AnalysisRequested(requestId, documentHash, msg.sender);
        return requestId;
    }

    function submitAnalysisResult(
        bytes32 requestId,
        bytes calldata termsData,
        bytes32 termsHash,
        string[] calldata extractedFields
    ) external override onlyAuthorizedAnalyzer {
        LibServicesStorage.ServicesStorage storage ss = LibServicesStorage.servicesStorage();
        AnalysisRequest storage request = ss.analysisRequests[requestId];
        
        require(!request.isProcessed, "Analysis already processed");
        require(block.timestamp <= request.timestamp + ss.analysisTimeout, "Analysis timeout");
        
        // Validate extracted fields against supported fields
        for (uint i = 0; i < extractedFields.length; i++) {
            require(
                _isFieldSupported(request.documentHash, extractedFields[i]),
                "Unsupported field extracted"
            );
        }
        
        // Store analysis result
        ss.analysisResults[request.documentHash] = AnalysisResult({
            documentHash: request.documentHash,
            termsData: termsData,
            termsHash: termsHash,
            timestamp: block.timestamp,
            isValid: true,
            extractedFields: extractedFields
        });
        
        request.isProcessed = true;
        request.resultHash = termsHash;
        
        emit AnalysisCompleted(requestId, request.documentHash, termsData);
    }

    function getAnalysisResult(
        bytes32 documentHash
    ) external view override returns (AnalysisResult memory) {
        return LibServicesStorage.servicesStorage().analysisResults[documentHash];
    }

    function getAnalysisRequest(
        bytes32 requestId
    ) external view override returns (AnalysisRequest memory) {
        return LibServicesStorage.servicesStorage().analysisRequests[requestId];
    }

    function isAnalysisValid(
        bytes32 documentHash
    ) external view override returns (bool) {
        LibServicesStorage.ServicesStorage storage ss = LibServicesStorage.servicesStorage();
        AnalysisResult memory result = ss.analysisResults[documentHash];
        return result.isValid && result.timestamp > 0;
    }

    function _isFieldSupported(
        bytes32 documentHash,
        string memory field
    ) internal view returns (bool) {
        LibServicesStorage.ServicesStorage storage ss = LibServicesStorage.servicesStorage();
        string[] memory supported = ss.supportedFields[documentHash];
        
        for (uint i = 0; i < supported.length; i++) {
            if (keccak256(bytes(supported[i])) == keccak256(bytes(field))) {
                return true;
            }
        }
        return false;
    }
} 