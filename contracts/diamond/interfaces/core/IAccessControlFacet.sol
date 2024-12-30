// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAccessControlFacet {
    event RoleGranted(bytes32 indexed role, address indexed account);
    event RoleRevoked(bytes32 indexed role, address indexed account);
    event KYCStatusUpdated(address indexed account, bool status);

    function hasRole(bytes32 role, address account) external view returns (bool);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function updateKYCStatus(address account, bool status) external;
    function isKYCVerified(address account) external view returns (bool);
} 