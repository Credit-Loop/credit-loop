// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../interfaces/oracle/IKYCOracleFacet.sol";
import "../../storage/LibOracleStorage.sol";
import "../../libraries/LibDiamond.sol";

contract KYCOracleFacet is IKYCOracleFacet {
    function requestKYCVerification(address account) external returns (bytes32 requestId) {
        OracleStorage storage os = LibOracleStorage.oracleStorage();
        
        requestId = keccak256(abi.encodePacked(account, block.timestamp));
        
        os.kycRequests[account] = KYCRequest({
            account: account,
            timestamp: block.timestamp,
            fulfilled: false,
            status: false,
            expiryTime: 0
        });
        
        emit KYCVerificationRequested(requestId, account);
        return requestId;
    }

    function updateKYCStatus(bytes32 requestId, bool status, uint256 expiryTime) external {
        OracleStorage storage os = LibOracleStorage.oracleStorage();
        require(LibOracleStorage.isOperator(msg.sender, keccak256("KYC_VERIFIER")), "Not authorized");
        
        // Extract account from requestId (first 20 bytes)
        address account = address(uint160(uint256(requestId)));
        KYCRequest storage request = os.kycRequests[account];
        
        require(!request.fulfilled, "Request already fulfilled");
        require(expiryTime > block.timestamp, "Invalid expiry time");
        
        request.fulfilled = true;
        request.status = status;
        request.expiryTime = expiryTime;
        
        os.kycStatus[account] = status;
        os.kycExpiryTime[account] = expiryTime;
        
        emit KYCStatusUpdated(requestId, account, status);
    }

    function isKYCValid(address account) external view returns (bool) {
        OracleStorage storage os = LibOracleStorage.oracleStorage();
        
        if (!os.kycStatus[account]) {
            return false;
        }
        
        // Check if KYC has expired
        if (block.timestamp > os.kycExpiryTime[account]) {
            return false;
        }
        
        return true;
    }

    function getKYCStatus(address account) external view returns (KYCRequest memory) {
        return LibOracleStorage.oracleStorage().kycRequests[account];
    }

    function setKYCValidityPeriod(uint256 newPeriod) external {
        require(LibDiamond.contractOwner() == msg.sender, "Not contract owner");
        LibOracleStorage.oracleStorage().kycValidityPeriod = newPeriod;
        emit KYCValidityPeriodUpdated(newPeriod);
    }

    function getKYCValidityPeriod() external view returns (uint256) {
        return LibOracleStorage.oracleStorage().kycValidityPeriod;
    }
} 