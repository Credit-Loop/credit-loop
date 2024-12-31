// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IZKProofService {
    // Events
    event ProofRequested(
        bytes32 indexed requestId,
        bytes32 indexed documentHash,
        address indexed submitter
    );
    
    event ProofGenerated(
        bytes32 indexed requestId,
        bytes32 indexed documentHash,
        bytes proof
    );
    
    event ProofVerified(
        bytes32 indexed requestId,
        bytes32 indexed documentHash,
        bool isValid
    );
    
    event ProofGenerationFailed(
        bytes32 indexed requestId,
        bytes32 indexed documentHash,
        string reason
    );

    // Structs
    struct ProofRequest {
        bytes32 documentHash;
        address submitter;
        uint256 timestamp;
        bool isProcessed;
        bytes publicInputs;
        bytes privateInputs;
    }

    struct ProofData {
        bytes32 documentHash;
        bytes proof;
        bytes32 publicInputHash;
        uint256 timestamp;
        bool isValid;
        bytes verifierKey;
    }

    // Core Functions
    function requestProof(
        bytes32 documentHash,
        bytes calldata publicInputs,
        bytes calldata privateInputs
    ) external returns (bytes32 requestId);

    function submitProof(
        bytes32 requestId,
        bytes calldata proof,
        bytes32 publicInputHash
    ) external;

    function verifyProof(
        bytes32 documentHash,
        bytes calldata proof,
        bytes calldata publicInputs
    ) external view returns (bool);

    function getProofData(
        bytes32 documentHash
    ) external view returns (ProofData memory);

    function getProofRequest(
        bytes32 requestId
    ) external view returns (ProofRequest memory);

    function isProofValid(
        bytes32 documentHash
    ) external view returns (bool);

    function updateVerifierKey(
        bytes calldata newKey
    ) external;
} 