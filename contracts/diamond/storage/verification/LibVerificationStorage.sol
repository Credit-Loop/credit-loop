// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../interfaces/verification/IIdentityVerifierFacet.sol";
import "../../interfaces/verification/IDocumentVerifierFacet.sol";

library LibVerificationStorage {
    bytes32 constant STORAGE_POSITION = keccak256("debtchain.verification.storage");

    struct VerificationStorage {
        // Identity verification
        mapping(address => IIdentityVerifierFacet.IdentityStatus) identityStatus;
        mapping(bytes32 => IdentityRequest) identityRequests;
        mapping(address => bytes32) currentRequestId;
        
        // Document verification
        mapping(bytes32 => IDocumentVerifierFacet.DocumentVerification) documentVerifications;
        mapping(bytes32 => IDocumentVerifierFacet.VerificationRequest) documentRequests;
        mapping(bytes32 => IDocumentVerifierFacet.VerificationStatus) verificationStatus;
        mapping(address => bytes32[]) userDocuments;
        mapping(bytes32 => bytes32[]) documentHistory; // Tracks document replacements
        
        // Access control
        mapping(address => bool) authorizedVerifiers;
        mapping(address => bool) authorizedAIServices;
        
        // System parameters
        uint256 identityValidityPeriod;
        uint256 documentValidityPeriod;
        bytes32 zkVerificationKey;
    }

    struct IdentityRequest {
        address account;
        uint256 timestamp;
        bool isProcessed;
    }

    function verificationStorage() internal pure returns (VerificationStorage storage vs) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            vs.slot := position
        }
    }
} 