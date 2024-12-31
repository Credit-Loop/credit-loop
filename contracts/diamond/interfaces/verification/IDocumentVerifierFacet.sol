// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDocumentVerifierFacet {
    // Events
    event DocumentVerificationRequested(
        bytes32 indexed requestId,
        address indexed submitter,
        bytes32 documentHash
    );
    
    event DocumentVerified(
        bytes32 indexed requestId,
        bytes32 documentHash,
        bool isValid
    );
    
    event TermsExtracted(
        bytes32 indexed requestId,
        bytes32 documentHash,
        bytes termsProof
    );
    
    event DocumentVerificationFailed(
        bytes32 indexed requestId,
        bytes32 documentHash,
        string reason
    );
    
    event DocumentRevoked(
        bytes32 indexed documentHash,
        address indexed revoker,
        string reason,
        uint256 timestamp
    );
    
    event DocumentReplaced(
        bytes32 indexed oldDocumentHash,
        bytes32 indexed newDocumentHash,
        address indexed submitter,
        uint256 timestamp
    );

    // Structs
    struct DocumentVerification {
        bytes32 documentHash;
        address submitter;
        uint256 timestamp;
        bool isVerified;
        bytes zkProof;
        bytes32 termsHash;
        uint256 expiryTimestamp;
    }

    struct VerificationRequest {
        bytes32 documentHash;
        address submitter;
        uint256 timestamp;
        bool isProcessed;
        bytes aiAnalysisResult;
        bytes zkProofRequest;
    }

    struct VerificationStatus {
        bool isVerified;
        bool isRevoked;
        bytes32 replacedBy;  // If document was replaced
        string failureReason;
        uint256 lastUpdateTimestamp;
    }

    // Core Functions
    function requestDocumentVerification(
        bytes32 documentHash,
        bytes calldata metadata
    ) external returns (bytes32 requestId);

    function submitVerificationResult(
        bytes32 requestId,
        bool isValid,
        bytes calldata zkProof,
        bytes32 termsHash
    ) external;

    function isDocumentValid(bytes32 documentHash) external view returns (bool);
    
    function getDocumentVerification(
        bytes32 documentHash
    ) external view returns (DocumentVerification memory);

    function revokeDocument(
        bytes32 documentHash,
        string calldata reason
    ) external;

    function replaceDocument(
        bytes32 oldDocumentHash,
        bytes32 newDocumentHash,
        bytes calldata metadata
    ) external returns (bytes32 requestId);

    function getVerificationStatus(
        bytes32 documentHash
    ) external view returns (VerificationStatus memory);
} 