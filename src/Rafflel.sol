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
    enum RaffleState {
        OPEN,
        CALCULATING
    }

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
    address private s_recentWinner;
    RaffleState private s_raffleState;

    /* Events */
    event playerEntred(address indexed player);
    event playerWon(address indexed winner);

    /* Errors */
    error Raffle__NotEnoghEth();
    error Raffle__IntervalNotPassed();
    error Raffle__TransferFailed();
    error Raffle__RaffleNotOpen();

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
        i_keyHash = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;

        s_lastTimestamp = block.timestamp;
        s_raffleState = RaffleState.OPEN;
    }

    /*  Functions */
    function enterRaffle() public payable {
        if (msg.value <= i_entranceFee) {
            revert Raffle__NotEnoghEth();
        }
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__RaffleNotOpen();
        }

        s_players.push(payable(msg.sender));
        emit playerEntred(msg.sender);
    }

    function pickWinner() public {
        if ((block.timestamp - s_lastTimestamp) < i_interval) {
            revert Raffle__IntervalNotPassed();
        }

        s_raffleState = RaffleState.CALCULATING;

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

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        s_recentWinner = payable(s_players[indexOfWinner]);
        emit playerWon(s_recentWinner);
        s_raffleState = RaffleState.OPEN;

        (bool success,) = s_recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransferFailed();
        }
    }

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
