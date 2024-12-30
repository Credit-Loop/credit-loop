// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../interfaces/oracle/IChainOptimizerFacet.sol";
import "../../storage/LibOracleStorage.sol";
import "../../libraries/LibDiamond.sol";

contract ChainOptimizerFacet is IChainOptimizerFacet {
    function requestOptimization(bytes32 chainId) external returns (bytes32 requestId) {
        OracleStorage storage os = LibOracleStorage.oracleStorage();
        
        requestId = keccak256(abi.encodePacked(chainId, block.timestamp));
        
        os.optimizationRequests[requestId] = OptimizationRequest({
            chainId: chainId,
            timestamp: block.timestamp,
            fulfilled: false,
            optimizedRoute: new address[](0),
            totalValue: 0
        });
        
        emit ChainOptimizationRequested(requestId, chainId);
        return requestId;
    }

    function updateOptimizedRoute(bytes32 requestId, address[] calldata route, uint256 totalValue) external {
        OracleStorage storage os = LibOracleStorage.oracleStorage();
        require(LibOracleStorage.isOperator(msg.sender, keccak256("CHAIN_OPTIMIZER")), "Not authorized");
        
        OptimizationRequest storage request = os.optimizationRequests[requestId];
        require(!request.fulfilled, "Request already fulfilled");
        require(route.length > 0, "Empty route not allowed");
        
        request.fulfilled = true;
        request.optimizedRoute = route;
        request.totalValue = totalValue;
        
        os.optimizedRoutes[request.chainId] = route;
        os.lastOptimization[request.chainId] = block.timestamp;
        
        emit OptimizationResponseReceived(requestId, route);
        
        bool isValid = validateOptimizedRoute(request.chainId);
        emit OptimizationValidated(request.chainId, isValid);
    }

    function getOptimizedRoute(bytes32 chainId) external view returns (address[] memory) {
        return LibOracleStorage.oracleStorage().optimizedRoutes[chainId];
    }

    function validateOptimizedRoute(bytes32 chainId) public view returns (bool) {
        OracleStorage storage os = LibOracleStorage.oracleStorage();
        
        // Check if optimization exists
        address[] memory route = os.optimizedRoutes[chainId];
        if (route.length == 0) {
            return false;
        }

        // Check if optimization is still valid
        uint256 lastOptTime = os.lastOptimization[chainId];
        if (block.timestamp > lastOptTime + os.optimizationValidityPeriod) {
            return false;
        }

        // Additional validation could be added here:
        // - Check if all addresses in route are valid participants
        // - Verify the route forms a valid chain
        // - Ensure total values match expectations
        
        return true;
    }

    function getLastOptimization(bytes32 chainId) external view returns (OptimizationRequest memory) {
        OracleStorage storage os = LibOracleStorage.oracleStorage();
        bytes32 lastRequestId;
        uint256 lastTimestamp = 0;
        
        // Find the most recent optimization request for this chain
        // Note: In production, maintain a mapping of chainId to latest requestId
        for (uint i = 0; i < 100; i++) { // Limit loop to prevent DOS
            bytes32 potentialId = keccak256(abi.encodePacked(chainId, i));
            OptimizationRequest storage request = os.optimizationRequests[potentialId];
            if (request.timestamp > lastTimestamp && request.chainId == chainId) {
                lastRequestId = potentialId;
                lastTimestamp = request.timestamp;
            }
        }
        
        require(lastTimestamp > 0, "No optimization found");
        return os.optimizationRequests[lastRequestId];
    }
} 