/**
 * Type declarations
 * 	State variables
 * 	Events
 * 	Errors
 * 	Modifiers
 * 	Functions
 */

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

/* Imports */
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts@1.4.0/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";

/* Interfaces */

/**
 * @title A Sample Raffle Contract
 * @author Mohammad Mahdi Keshavarz (AKA Dicentralizer)
 * @notice This contract is for creating a sample raffle
 * @dev Implements Chainlink VRFv2.5
 */
contract Raffle {
    /* State variables */
    uint256 private immutable i_entranceFee;
    /**
     * @dev The interval is the time between two lottery.
     */
    uint256 private i_interval;
    address payable[] private s_players;
    uint256 private s_lastTimestamp;

    /* Events */
    event playerEntred(address indexed player);

    /* Errors */
    error Raffle__notEnoghEth();
    error Raffle__intervalNotPassed();

    /* Modifiers */

    constructor(uint256 entranceFee, uint256 interval) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimestamp = block.timestamp;
    }

    /*  Functions */
    function enterRaffle() public payable {
        if (msg.value <= i_entranceFee) {
            revert Raffle__notEnoghEth();
        }
        s_players.push(payable(msg.sender));
        emit playerEntred(msg.sender);
    }

    function pickWinner() public {
        if ((block.timestamp - s_lastTimestamp) < i_interval) {
            revert Raffle__intervalNotPassed();
        }
        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: enableNativePayment}))
            })
        );
    }

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
