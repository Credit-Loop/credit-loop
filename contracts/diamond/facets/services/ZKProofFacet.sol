// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../interfaces/services/IZKProofService.sol";
import "../../storage/services/LibServicesStorage.sol";
import "../../libraries/LibDiamond.sol";

contract ZKProofFacet is IZKProofService {
    using LibServicesStorage for LibServicesStorage.ServicesStorage;

    modifier onlyAuthorizedProver() {
        require(
            LibServicesStorage.servicesStorage().authorizedProvers[msg.sender],
            "Not authorized prover"
        );
        _;
    }

    function requestProof(
        bytes32 documentHash,
        bytes calldata publicInputs,
        bytes calldata privateInputs
    ) external override returns (bytes32) {
        bytes32 requestId = keccak256(abi.encodePacked(
            documentHash,
            msg.sender,
            block.timestamp,
            "ZK_PROOF"
        ));
        
        LibServicesStorage.ServicesStorage storage ss = LibServicesStorage.servicesStorage();
        ss.proofRequests[requestId] = ProofRequest({
            documentHash: documentHash,
            submitter: msg.sender,
            timestamp: block.timestamp,
            isProcessed: false,
            publicInputs: publicInputs,
            privateInputs: privateInputs
        });
        
        ss.documentToProofId[documentHash] = requestId;
        
        emit ProofRequested(requestId, documentHash, msg.sender);
        return requestId;
    }

    function submitProof(
        bytes32 requestId,
        bytes calldata proof,
        bytes32 publicInputHash
    ) external override onlyAuthorizedProver {
        LibServicesStorage.ServicesStorage storage ss = LibServicesStorage.servicesStorage();
        ProofRequest storage request = ss.proofRequests[requestId];
        
        require(!request.isProcessed, "Proof already processed");
        require(block.timestamp <= request.timestamp + ss.proofTimeout, "Proof generation timeout");
        
        // Store proof data
        ss.proofData[request.documentHash] = ProofData({
            documentHash: request.documentHash,
            proof: proof,
            publicInputHash: publicInputHash,
            timestamp: block.timestamp,
            isValid: true,
            verifierKey: ss.currentVerifierKey
        });
        
        request.isProcessed = true;
        
        emit ProofGenerated(requestId, request.documentHash, proof);
        emit ProofVerified(requestId, request.documentHash, true);
    }

    function verifyProof(
        bytes32 documentHash,
        bytes calldata proof,
        bytes calldata publicInputs
    ) external view override returns (bool) {
        LibServicesStorage.ServicesStorage storage ss = LibServicesStorage.servicesStorage();
        ProofData storage proofData = ss.proofData[documentHash];
        
        require(proofData.timestamp > 0, "Proof not found");
        require(proofData.verifierKey.length > 0, "Verifier key not set");
        
        // In a real implementation, this would use a ZK verification circuit
        // For now, we just check if the proof exists and is marked as valid
        return proofData.isValid &&
               keccak256(proof) == keccak256(proofData.proof) &&
               keccak256(publicInputs) == proofData.publicInputHash;
    }

    function getProofData(
        bytes32 documentHash
    ) external view override returns (ProofData memory) {
        return LibServicesStorage.servicesStorage().proofData[documentHash];
    }

    function getProofRequest(
        bytes32 requestId
    ) external view override returns (ProofRequest memory) {
        return LibServicesStorage.servicesStorage().proofRequests[requestId];
    }

    function isProofValid(
        bytes32 documentHash
    ) external view override returns (bool) {
        LibServicesStorage.ServicesStorage storage ss = LibServicesStorage.servicesStorage();
        ProofData memory data = ss.proofData[documentHash];
        return data.isValid && 
               data.timestamp > 0 && 
               keccak256(data.verifierKey) == keccak256(ss.currentVerifierKey);
    }

    function updateVerifierKey(
        bytes calldata newKey
    ) external override onlyAuthorizedProver {
        LibServicesStorage.servicesStorage().currentVerifierKey = newKey;
    }
} 