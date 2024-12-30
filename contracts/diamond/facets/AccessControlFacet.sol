// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/core/IAccessControlFacet.sol";
import "../storage/LibAccessStorage.sol";
import "../libraries/LibDiamond.sol";

contract AccessControlFacet is IAccessControlFacet {
    function hasRole(bytes32 role, address account) external view returns (bool) {
        return LibAccessStorage.accessStorage().roles[role][account];
    }

    function grantRole(bytes32 role, address account) external {
        LibDiamond.enforceIsContractOwner();
        AccessStorage storage as = LibAccessStorage.accessStorage();
        
        require(!as.roles[role][account], "Role already granted");
        as.roles[role][account] = true;
        
        emit RoleGranted(role, account);
    }

    function revokeRole(bytes32 role, address account) external {
        LibDiamond.enforceIsContractOwner();
        AccessStorage storage as = LibAccessStorage.accessStorage();
        
        require(as.roles[role][account], "Role not granted");
        as.roles[role][account] = false;
        
        emit RoleRevoked(role, account);
    }

    function updateKYCStatus(address account, bool status) external {
        AccessStorage storage as = LibAccessStorage.accessStorage();
        require(as.roles[LibAccessStorage.KYC_MANAGER_ROLE][msg.sender], "Not KYC manager");
        
        as.kycVerified[account] = status;
        emit KYCStatusUpdated(account, status);
    }

    function isKYCVerified(address account) external view returns (bool) {
        return LibAccessStorage.accessStorage().kycVerified[account];
    }
} 