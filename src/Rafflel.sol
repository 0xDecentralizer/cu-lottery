/** 
	Type declarations
	State variables
	Events
	Errors
	Modifiers
	Functions
*/ 

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

/* Imports */
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
	address payable [] private s_players;

	/* Events */
	event playerEntred(address indexed player);

	
	/* Errors */
	error Raffle__notEnoghEth();

	/* Modifiers */

	/*  Functions */
    function enterRaffle() public payable {
		if (msg.value <= i_entranceFee) {
			revert Raffle__notEnoghEth();
		}
		s_players.push(payable(msg.sender));
		emit playerEntred(msg.sender);
	}

    function pickWinner() public {}


	function getEntranceFee() external view returns (uint256) {
		return i_entranceFee;
	}
}