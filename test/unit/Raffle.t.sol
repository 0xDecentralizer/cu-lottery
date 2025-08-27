// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Test, console} from "forge-std/Test.sol";
import {Raffle} from "src/Raffle.sol";
import {DeployRaffle} from "script/Raffle.s.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";

contract TestRaffle is Test {
    Raffle public raffle;
    HelperConfig public helperConfig;

    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint256 subscriptionId;
    uint32 callbackGasLimit;
    address linkToken;

    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_PLAYER_BALANCE = 10 ether;

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.deployRaffle();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        entranceFee = config.entranceFee;
        interval = config.interval;
        vrfCoordinator = config.vrfCoordinator;
        gasLane = config.gasLane;
        subscriptionId = config.subscriptionId;
        callbackGasLimit = config.callbackGasLimit;
        linkToken = config.link;

        vm.deal(PLAYER, STARTING_PLAYER_BALANCE);
    }

    /** ======================
     *  ==== Enter Raffle ====
     *  ======================
    */ 
    function test_RaffleInitialState() public view {
        assert(raffle.getState() == Raffle.RaffleState.OPEN);
    }

    function testRevert_enterWithInsufficientFund() public {
        vm.prank(PLAYER);
        vm.expectRevert(Raffle.Raffle__NotEnoghEth.selector);
        raffle.enterRaffle{value: 1}();
        // address(raffle).call{value: 1}(abi.encodeWithSignature("enterRaffle()"));
    }

    function test_RaffleRecordPlayersWhenTheyEnter() public {
        vm.prank(PLAYER);
        vm.expectEmit(true, false, false, false);
        emit Raffle.playerEntred(PLAYER);
        raffle.enterRaffle{value: 1 ether}();

        address playerRecord = raffle.getPlayer(0);
        assertEq(raffle.getPlayrsLength(), 1);
        assertEq(playerRecord, PLAYER);
    }

    function test_PlayerEnterWhenRaffleIsCalculating() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: 1 ether}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");

        vm.prank(PLAYER);
        vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector);
        raffle.enterRaffle{value: 1 ether}();
    }

    /** ======================
     *  ==== Check Upkeep ====
     *  ======================
    */
    function test_CheckUpkeepReturnsFalseWhenTheRaffleIsNotOpen() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: 1 ether}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");
        (bool upkeepNeeded,) = raffle.checkUpkeep("");

        assertFalse(upkeepNeeded);
    }

    function CheckUpkeepReturnsFalseWhenTheIntervalNotPassed() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: 1 ether}();
        (bool upkeepNeeded,) = raffle.checkUpkeep("");

        assertFalse(upkeepNeeded);
    }

    function CheckUpkeepReturnsFalseWhenBalanceIsZero() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: 1 ether}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        (bool upkeepNeeded,) = raffle.checkUpkeep("");

        assertFalse(upkeepNeeded);
    }

    /** =======================
     *  ==== Perorm Upkeep ====
     *  =======================
    */ 
    function test_PerformUpkeepCanOnlyRunIfCheckUpkeepIsTrue() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: 1 ether}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        (bool success, ) = address(raffle).call(abi.encodeWithSelector(Raffle.performUpkeep.selector, ""));
        assertTrue(success);
        // raffle.performUpkeep("");
    }

    function test_RaffleStateShouldBeCalculatingWhenCallThePerformUpkeep() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: 1 ether}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        raffle.performUpkeep("");

        uint256 rState = uint256(raffle.getState());
        assertEq(rState, 1); // 0 = OPEN , 1 = CALCULATING
    }

    function testRevert_PerformUpkeepRevertsIfCheckUpkeepIsFalse() public {
        uint256 currentBalance = 0;
        uint256 numPlayers = 0;
        Raffle.RaffleState rState = raffle.getState();

        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        vm.expectRevert(abi.encodeWithSelector(Raffle.Raffle__UpkeepNotNeeded.selector, currentBalance, numPlayers, rState));
        raffle.performUpkeep("");

    }
}
