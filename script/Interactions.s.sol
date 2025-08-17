// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.22;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";

contract CreateSubscription is Script {
    HelperConfig public helperConfig;
    
    constructor() {
        helperConfig = new HelperConfig();
    }
    
    function run() public {
        createSubscriptionUsingConfig();
    }
    
    function createSubscriptionUsingConfig() public returns (uint256) {
        // HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        return createSubscription(vrfCoordinator);
    }
    
    function createSubscription(address vrfCoordinator) public returns (uint256) {
        console.log("Creating subscription on chainIS: ", block.chainid);
        
        vm.roll(block.number + 10);
        vm.startBroadcast();
        uint256 subId = VRFCoordinatorV2_5Mock(vrfCoordinator).createSubscription();
        vm.stopBroadcast();
        
        console.log("Your sub id:", subId);
        console.log("Now UPDATE subscriptionId in HelperConfig!");
        return subId;
    }
}

contract FundSubscription is Script, HelperConfig {
    HelperConfig public helperConfig;
    
    constructor() {
        helperConfig = new HelperConfig();
    }

    function fundSubscriptionUsingConfig() public {
        // HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        uint256 subscriptionId = helperConfig.getConfig().subscriptionId;
        // VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(subscriptionId, 3 ether);
        address linkToken = helperConfig.getConfig().link;
        
        if (block.chainid == LOCAL_CHAIN_ID) {
            CreateSubscription createSub = new CreateSubscription();
            uint256 subId = createSub.createSubscription(vrfCoordinator);
            fundSubscription(vrfCoordinator, subId, linkToken);
            console.log("SSubId Created: ", subId);
        } else {
            uint256 subId = helperConfig.getConfig().subscriptionId;
            if (subId == 0) {
                CreateSubscription createSub = new CreateSubscription();
                subId = createSub.createSubscription(vrfCoordinator);
            }
            fundSubscription(vrfCoordinator, subId, linkToken);
        }
        
        
        fundSubscription(vrfCoordinator, subscriptionId, linkToken);

    }
    
    function fundSubscription(address vrfCoordinator, uint256 subscriptionId, address linkToken) public {
        console.log("Funding subscription: ", subscriptionId);
        console.log("Using vrfCoordinator: ", vrfCoordinator);
        console.log("On chainID: ", block.chainid);
        if (block.chainid == LOCAL_CHAIN_ID) {
            vm.startBroadcast();
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(subscriptionId, 3 ether);
            vm.stopBroadcast();
        } else if (block.chainid == SEPOLIA_CHAIN_ID) {
            vm.startBroadcast();
            LinkToken(linkToken).transferAndCall(vrfCoordinator, 3 ether, abi.encode(subscriptionId));
            vm.stopBroadcast();
        }
    }
    function run() public {
        fundSubscriptionUsingConfig();
    }
}