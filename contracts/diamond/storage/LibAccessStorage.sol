// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct AccessStorage {
    mapping(bytes32 => mapping(address => bool)) roles;
    mapping(bytes32 => address) roleAdmins;
    mapping(address => bool) kycVerified;
}

library LibAccessStorage {
    bytes32 constant ACCESS_STORAGE_POSITION = keccak256("debtchain.access.storage");
    bytes32 constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 constant TAX_MANAGER_ROLE = keccak256("TAX_MANAGER_ROLE");
    bytes32 constant KYC_MANAGER_ROLE = keccak256("KYC_MANAGER_ROLE");

    function accessStorage() internal pure returns (AccessStorage storage as) {
        bytes32 position = ACCESS_STORAGE_POSITION;
        assembly {
            as.slot := position
        }
    }
} 