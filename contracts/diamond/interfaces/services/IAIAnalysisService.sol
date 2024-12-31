// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAIAnalysisService {
    // Events
    event AnalysisRequested(
        bytes32 indexed requestId,
        bytes32 indexed documentHash,
        address indexed submitter
    );
    
    event AnalysisCompleted(
        bytes32 indexed requestId,
        bytes32 indexed documentHash,
        bytes termsData
    );
    
    event AnalysisFailed(
        bytes32 indexed requestId,
        bytes32 indexed documentHash,
        string reason
    );

    // Structs
    struct AnalysisRequest {
        bytes32 documentHash;
        address submitter;
        uint256 timestamp;
        bool isProcessed;
        bytes documentMetadata;
        bytes32 resultHash;
    }

    struct AnalysisResult {
        bytes32 documentHash;
        bytes termsData;
        bytes32 termsHash;
        uint256 timestamp;
        bool isValid;
        string[] extractedFields;
    }

    // Core Functions
    function requestAnalysis(
        bytes32 documentHash,
        bytes calldata documentMetadata
    ) external returns (bytes32 requestId);

    function submitAnalysisResult(
        bytes32 requestId,
        bytes calldata termsData,
        bytes32 termsHash,
        string[] calldata extractedFields
    ) external;

    function getAnalysisResult(
        bytes32 documentHash
    ) external view returns (AnalysisResult memory);

    function getAnalysisRequest(
        bytes32 requestId
    ) external view returns (AnalysisRequest memory);

    function isAnalysisValid(
        bytes32 documentHash
    ) external view returns (bool);
} 