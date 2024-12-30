// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/core/IChainFacet.sol";
import "../storage/LibChainStorage.sol";
import "../storage/LibDebtStorage.sol";
import "../storage/LibAccessStorage.sol";

contract ChainFacet is IChainFacet {
    function detectChain(address debtor, address creditor) external view returns (bytes32 chainId) {
        ChainStorage storage cs = LibChainStorage.chainStorage();
        DebtStorage storage ds = LibDebtStorage.debtStorage();
        
        // Get all debts between debtor and creditor
        bytes32[] memory debts = ds.debtorToCreditorDebts[debtor][creditor];
        require(debts.length > 0, "No debts found");
        
        // Create a unique chain ID
        chainId = keccak256(abi.encodePacked(debtor, creditor, block.timestamp));
        
        // Initialize chain data
        cs.chains[chainId] = Chain({
            id: chainId,
            participants: new address[](2),
            amount: ds.debts[debts[0]].amount,
            status: ChainStatus.PENDING,
            timestamp: block.timestamp
        });
        
        cs.chains[chainId].participants[0] = debtor;
        cs.chains[chainId].participants[1] = creditor;
        
        return chainId;
    }

    function consentToChain(bytes32 chainId) external {
        ChainStorage storage cs = LibChainStorage.chainStorage();
        require(cs.chains[chainId].status == ChainStatus.PENDING, "Chain not pending");
        
        bool isParticipant = false;
        for (uint i = 0; i < cs.chains[chainId].participants.length; i++) {
            if (cs.chains[chainId].participants[i] == msg.sender) {
                isParticipant = true;
                break;
            }
        }
        require(isParticipant, "Not a chain participant");
        
        cs.chainConsents[chainId][msg.sender] = true;
        emit ChainConsented(chainId, msg.sender);
        
        // Check if all participants have consented
        bool allConsented = true;
        for (uint i = 0; i < cs.chains[chainId].participants.length; i++) {
            if (!cs.chainConsents[chainId][cs.chains[chainId].participants[i]]) {
                allConsented = false;
                break;
            }
        }
        
        if (allConsented) {
            cs.chains[chainId].status = ChainStatus.ACTIVE;
        }
    }

    function getChainParticipants(bytes32 chainId) external view returns (address[] memory) {
        return LibChainStorage.chainStorage().chains[chainId].participants;
    }

    function validateChain(bytes32 chainId) external view returns (bool) {
        ChainStorage storage cs = LibChainStorage.chainStorage();
        Chain storage chain = cs.chains[chainId];
        return chain.status == ChainStatus.ACTIVE;
    }

    function getChainStatus(bytes32 chainId) external view returns (ChainStatus) {
        return LibChainStorage.chainStorage().chains[chainId].status;
    }
} 