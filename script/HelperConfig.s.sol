// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.22;

contract HelperConfig {
    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint256 subscriptionId;
        uint32 callbackGasLimit;
    }
    NetworkConfig private networkConfig;

    mapping (uint256 chainId => NetworkConfig) networkConfigs;

    constructor() {}

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {

    }

    function getLocalConfig() public pure returns (NetworkConfig memory) {

    }

    function getConfigByChainId(uint256 chainId) public view returns (NetworkConfig memory) {
        
    }
 

}