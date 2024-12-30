// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IKYCOracleFacet {
    event KYCVerificationRequested(bytes32 requestId, address account);
    event KYCStatusUpdated(bytes32 requestId, address account, bool status);
    event KYCValidityPeriodUpdated(uint256 newPeriod);

    struct KYCRequest {
        address account;
        uint256 timestamp;
        bool fulfilled;
        bool status;
        uint256 expiryTime;
    }

    function requestKYCVerification(address account) external returns (bytes32 requestId);
    function updateKYCStatus(bytes32 requestId, bool status, uint256 expiryTime) external;
    function isKYCValid(address account) external view returns (bool);
    function getKYCStatus(address account) external view returns (KYCRequest memory);
    function setKYCValidityPeriod(uint256 newPeriod) external;
    function getKYCValidityPeriod() external view returns (uint256);
} 