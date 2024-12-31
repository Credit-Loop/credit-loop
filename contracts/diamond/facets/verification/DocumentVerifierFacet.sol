// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../interfaces/verification/IDocumentVerifierFacet.sol";
import "../../interfaces/verification/IIdentityVerifierFacet.sol";
import "../../storage/verification/LibVerificationStorage.sol";
import "../../libraries/LibDiamond.sol";

contract DocumentVerifierFacet is IDocumentVerifierFacet {
    using LibVerificationStorage for LibVerificationStorage.VerificationStorage;

    modifier onlyAuthorizedVerifier() {
        require(
            LibVerificationStorage.verificationStorage().authorizedVerifiers[msg.sender],
            "Not authorized verifier"
        );
        _;
    }

    modifier onlyAuthorizedAIService() {
        require(
            LibVerificationStorage.verificationStorage().authorizedAIServices[msg.sender],
            "Not authorized AI service"
        );
        _;
    }

    function _requestDocumentVerification(
        bytes32 documentHash,
        bytes calldata metadata,
        address submitter
    ) internal returns (bytes32) {
        require(
            IIdentityVerifierFacet(address(this)).isIdentityValid(submitter),
            "Identity not verified"
        );
        
        bytes32 requestId = keccak256(abi.encodePacked(
            documentHash,
            submitter,
            block.timestamp
        ));
        
        LibVerificationStorage.VerificationStorage storage vs = LibVerificationStorage.verificationStorage();
        vs.documentRequests[requestId] = IDocumentVerifierFacet.VerificationRequest({
            documentHash: documentHash,
            submitter: submitter,
            timestamp: block.timestamp,
            isProcessed: false,
            aiAnalysisResult: "",
            zkProofRequest: ""
        });
        
        vs.userDocuments[submitter].push(documentHash);
        
        emit DocumentVerificationRequested(requestId, submitter, documentHash);
        return requestId;
    }

    function requestDocumentVerification(
        bytes32 documentHash,
        bytes calldata metadata
    ) external override returns (bytes32) {
        return _requestDocumentVerification(documentHash, metadata, msg.sender);
    }

    function submitVerificationResult(
        bytes32 requestId,
        bool isValid,
        bytes calldata zkProof,
        bytes32 termsHash
    ) external override onlyAuthorizedVerifier {
        LibVerificationStorage.VerificationStorage storage vs = LibVerificationStorage.verificationStorage();
        IDocumentVerifierFacet.VerificationRequest storage request = vs.documentRequests[requestId];
        require(!request.isProcessed, "Already processed");
        
        // Store verification result
        vs.documentVerifications[request.documentHash] = IDocumentVerifierFacet.DocumentVerification({
            documentHash: request.documentHash,
            submitter: request.submitter,
            timestamp: block.timestamp,
            isVerified: isValid,
            zkProof: zkProof,
            termsHash: termsHash,
            expiryTimestamp: block.timestamp + vs.documentValidityPeriod
        });
        
        if (!isValid) {
            vs.verificationStatus[request.documentHash].failureReason = "Verification failed";
            emit DocumentVerificationFailed(requestId, request.documentHash, "Verification failed");
        }
        
        request.isProcessed = true;
        vs.verificationStatus[request.documentHash].isVerified = isValid;
        vs.verificationStatus[request.documentHash].lastUpdateTimestamp = block.timestamp;
        
        emit DocumentVerified(requestId, request.documentHash, isValid);
        emit TermsExtracted(requestId, request.documentHash, zkProof);
    }

    function isDocumentValid(bytes32 documentHash) external view override returns (bool) {
        LibVerificationStorage.VerificationStorage storage vs = LibVerificationStorage.verificationStorage();
        IDocumentVerifierFacet.DocumentVerification storage doc = vs.documentVerifications[documentHash];
        IDocumentVerifierFacet.VerificationStatus storage status = vs.verificationStatus[documentHash];
        
        return doc.isVerified && 
               !status.isRevoked && 
               status.replacedBy == bytes32(0) &&
               block.timestamp <= doc.expiryTimestamp;
    }

    function getDocumentVerification(
        bytes32 documentHash
    ) external view override returns (DocumentVerification memory) {
        return LibVerificationStorage.verificationStorage().documentVerifications[documentHash];
    }

    function revokeDocument(
        bytes32 documentHash,
        string calldata reason
    ) external override {
        LibVerificationStorage.VerificationStorage storage vs = LibVerificationStorage.verificationStorage();
        IDocumentVerifierFacet.DocumentVerification storage doc = vs.documentVerifications[documentHash];
        
        require(
            msg.sender == doc.submitter || vs.authorizedVerifiers[msg.sender],
            "Not authorized"
        );
        require(doc.isVerified, "Document not verified");
        require(!vs.verificationStatus[documentHash].isRevoked, "Already revoked");
        
        vs.verificationStatus[documentHash].isRevoked = true;
        vs.verificationStatus[documentHash].failureReason = reason;
        vs.verificationStatus[documentHash].lastUpdateTimestamp = block.timestamp;
        
        emit DocumentRevoked(
            documentHash,
            msg.sender,
            reason,
            block.timestamp
        );
    }

    function replaceDocument(
        bytes32 oldDocumentHash,
        bytes32 newDocumentHash,
        bytes calldata metadata
    ) external override returns (bytes32 requestId) {
        LibVerificationStorage.VerificationStorage storage vs = LibVerificationStorage.verificationStorage();
        IDocumentVerifierFacet.DocumentVerification storage oldDoc = vs.documentVerifications[oldDocumentHash];
        
        require(msg.sender == oldDoc.submitter, "Not document owner");
        require(oldDoc.isVerified, "Original document not verified");
        require(!vs.verificationStatus[oldDocumentHash].isRevoked, "Document already revoked");
        
        // Create new verification request
        requestId = _requestDocumentVerification(newDocumentHash, metadata, msg.sender);
        
        // Update old document status
        vs.verificationStatus[oldDocumentHash].replacedBy = newDocumentHash;
        vs.verificationStatus[oldDocumentHash].lastUpdateTimestamp = block.timestamp;
        
        // Track document history
        vs.documentHistory[oldDocumentHash].push(newDocumentHash);
        
        emit DocumentReplaced(
            oldDocumentHash,
            newDocumentHash,
            msg.sender,
            block.timestamp
        );
        
        return requestId;
    }

    function getVerificationStatus(
        bytes32 documentHash
    ) external view override returns (VerificationStatus memory) {
        return LibVerificationStorage.verificationStorage().verificationStatus[documentHash];
    }
} 