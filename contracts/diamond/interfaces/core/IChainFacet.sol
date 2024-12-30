// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IChainFacet {
    event ChainCreated(bytes32 indexed chainId, address[] participants);
    event ChainConsented(bytes32 indexed chainId, address indexed participant);
    event ChainResolved(bytes32 indexed chainId);

    function detectChain(address debtor, address creditor) external view returns (bytes32 chainId);
    function consentToChain(bytes32 chainId) external;
    function resolveChain(bytes32 chainId) external;
    function getChainParticipants(bytes32 chainId) external view returns (address[] memory);
    function validateChain(bytes32 chainId) external view returns (bool);
    function getChainStatus(bytes32 chainId) external view returns (ChainStatus);
} 