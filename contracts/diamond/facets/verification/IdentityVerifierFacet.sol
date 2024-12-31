// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../interfaces/verification/IIdentityVerifierFacet.sol";
import "../../storage/verification/LibVerificationStorage.sol";
import "../../libraries/LibDiamond.sol";

contract IdentityVerifierFacet is IIdentityVerifierFacet {
    using LibVerificationStorage for LibVerificationStorage.VerificationStorage;

    modifier onlyAuthorizedVerifier() {
        require(
            LibVerificationStorage.verificationStorage().authorizedVerifiers[msg.sender],
            "Not authorized verifier"
        );
        _;
    }

    function requestIdentityVerification() external override returns (bytes32) {
        require(!isIdentityValid(msg.sender), "Identity already verified");
        
        bytes32 requestId = keccak256(abi.encodePacked(
            msg.sender,
            block.timestamp,
            "IDENTITY_VERIFICATION"
        ));
        
        LibVerificationStorage.VerificationStorage storage vs = LibVerificationStorage.verificationStorage();
        vs.identityRequests[requestId] = LibVerificationStorage.IdentityRequest({
            account: msg.sender,
            timestamp: block.timestamp,
            isProcessed: false
        });
        vs.currentRequestId[msg.sender] = requestId;
        
        emit IdentityVerificationRequested(msg.sender, requestId);
        return requestId;
    }

    function updateIdentityStatus(
        address account,
        bool status,
        uint256 expiryTimestamp
    ) external override onlyAuthorizedVerifier {
        require(expiryTimestamp > block.timestamp, "Invalid expiry");
        
        LibVerificationStorage.VerificationStorage storage vs = LibVerificationStorage.verificationStorage();
        vs.identityStatus[account] = IdentityStatus({
            isVerified: status,
            verificationTimestamp: block.timestamp,
            expiryTimestamp: expiryTimestamp,
            lastRequestId: vs.currentRequestId[account]
        });
        
        emit IdentityVerified(account, block.timestamp);
    }

    function isIdentityValid(address account) public view override returns (bool) {
        LibVerificationStorage.VerificationStorage storage vs = LibVerificationStorage.verificationStorage();
        IdentityStatus memory status = vs.identityStatus[account];
        
        return status.isVerified &&
               status.expiryTimestamp > block.timestamp;
    }

    function getIdentityStatus(
        address account
    ) external view override returns (IdentityStatus memory) {
        return LibVerificationStorage.verificationStorage().identityStatus[account];
    }

    function revokeIdentity(
        address account,
        string calldata reason
    ) external override onlyAuthorizedVerifier {
        LibVerificationStorage.VerificationStorage storage vs = LibVerificationStorage.verificationStorage();
        require(vs.identityStatus[account].isVerified, "Identity not verified");
        
        vs.identityStatus[account].isVerified = false;
        emit IdentityRevoked(account, reason);
    }
} 