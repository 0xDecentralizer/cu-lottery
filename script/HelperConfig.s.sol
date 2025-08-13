// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.22;

contract HelperConfig {
    uint256 constant SEPOLIA_CHAIN_ID = 11155111;

    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint256 subscriptionId;
        uint32 callbackGasLimit;
    }

    NetworkConfig private localNetworkConfig;
    mapping (uint256 chainId => NetworkConfig) public networkConfigs;

    constructor() {
        networkConfigs[SEPOLIA_CHAIN_ID] = getSepoliaEthConfig();
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return(NetworkConfig({
            entranceFee: 0.02 ether,
            interval: 30,
            vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
            gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subscriptionId: 0,
            callbackGasLimit: 500000
        }));
    }

    function getLocalConfig() public pure returns (NetworkConfig memory) {

    }

    function getConfigByChainId(uint256 chainId) public view returns (NetworkConfig memory) {

    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {

    }
 

}