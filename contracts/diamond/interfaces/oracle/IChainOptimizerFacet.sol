// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IChainOptimizerFacet {
    event ChainOptimizationRequested(bytes32 requestId, bytes32 chainId);
    event OptimizationResponseReceived(bytes32 requestId, address[] route);
    event OptimizationValidated(bytes32 chainId, bool isValid);

    struct OptimizationRequest {
        bytes32 chainId;
        uint256 timestamp;
        bool fulfilled;
        address[] optimizedRoute;
        uint256 totalValue;
    }

    function requestOptimization(bytes32 chainId) external returns (bytes32 requestId);
    function updateOptimizedRoute(bytes32 requestId, address[] calldata route, uint256 totalValue) external;
    function getOptimizedRoute(bytes32 chainId) external view returns (address[] memory);
    function validateOptimizedRoute(bytes32 chainId) external view returns (bool);
    function getLastOptimization(bytes32 chainId) external view returns (OptimizationRequest memory);
} 