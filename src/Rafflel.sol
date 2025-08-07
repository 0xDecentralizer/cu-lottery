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
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/dev/vrf/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/dev/vrf/libraries/VRFV2PlusClient.sol";

/* Interfaces */

/**
 * @title A Sample Raffle Contract
 * @author Mohammad Mahdi Keshavarz (AKA Dicentralizer)
 * @notice This contract is for creating a sample raffle
 * @dev Implements Chainlink VRFv2.5
 */
contract Raffle is VRFConsumerBaseV2Plus {
    /* State variables */
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORD = 1;
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    uint256 private immutable i_subscriptionId;
    bytes32 private immutable i_keyHash;
    uint32 private immutable i_callbackGasLimit;
    address payable[] private s_players;
    uint256 private s_lastTimestamp;

    /* Events */
    event playerEntred(address indexed player);

    /* Errors */
    error Raffle__notEnoghEth();
    error Raffle__intervalNotPassed();

    /* Modifiers */

    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint256 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimestamp = block.timestamp;
        i_keyHash = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
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

        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient.RandomWordsRequest({
            keyHash: i_keyHash,
            subId: i_subscriptionId,
            requestConfirmations: REQUEST_CONFIRMATIONS,
            callbackGasLimit: i_callbackGasLimit,
            numWords: NUM_WORD,
            extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
        });

        uint256 requestId = s_vrfCoordinator.requestRandomWords(request);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {}

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
