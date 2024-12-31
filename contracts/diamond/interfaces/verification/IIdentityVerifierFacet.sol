// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IIdentityVerifierFacet {
    // Events
    event IdentityVerificationRequested(address indexed account, bytes32 requestId);
    event IdentityVerified(address indexed account, uint256 timestamp);
    event IdentityExpired(address indexed account, uint256 timestamp);
    event IdentityRevoked(address indexed account, string reason);

    // Structs
    struct IdentityStatus {
        bool isVerified;
        uint256 verificationTimestamp;
        uint256 expiryTimestamp;
        bytes32 lastRequestId;
    }

    // Core Functions
    function requestIdentityVerification() external returns (bytes32 requestId);
    
    function updateIdentityStatus(
        address account, 
        bool status, 
        uint256 expiryTimestamp
    ) external;
    
    function isIdentityValid(address account) external view returns (bool);
    
    function getIdentityStatus(address account) external view returns (IdentityStatus memory);
    
    function revokeIdentity(address account, string calldata reason) external;
} 