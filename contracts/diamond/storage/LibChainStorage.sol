// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct ChainStorage {
    mapping(bytes32 => Chain) chains;
    mapping(bytes32 => address[]) chainParticipants;
    mapping(bytes32 => mapping(address => bool)) chainConsents;
}

struct Chain {
    bytes32 id;
    address[] participants;
    uint256 amount;
    ChainStatus status;
    uint256 timestamp;
}

enum ChainStatus {
    PENDING,
    ACTIVE,
    COMPLETED,
    CANCELLED
}

library LibChainStorage {
    bytes32 constant CHAIN_STORAGE_POSITION = keccak256("debtchain.chain.storage");

    function chainStorage() internal pure returns (ChainStorage storage cs) {
        bytes32 position = CHAIN_STORAGE_POSITION;
        assembly {
            cs.slot := position
        }
    }
} 