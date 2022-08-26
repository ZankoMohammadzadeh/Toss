// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract CoinToss {
	// some parameter to save our variables
	// treasuryBalance show the treasury of the game
	// owner is address of creative of game(smart contract), and player is address of player
	uint public treasuryBalance;
	address payable public owner;
	address payable public player;
	/*
	 some error and events to display a better information
	 specially when this contract is called by web3 apps
	 */
	// awarn smart contract creator to pay some ether to start CoinToss game 
	error TreasuryIsZero();
    // two events have been used to show address of player 
	// and amount of ether which player sent/received
	event EtherReceived(address, uint);
    event EtherSent(address, uint);
	// show random number 
    event ShowRandomNumber(uint);
	
	// a modifier has been implemented to prevent executing play function
	// to check amount of player for paying
	modifier evaluateTreasury(uint valueParam) {
		// the amount sent should be more than 0
        require(valueParam > 0, "player value is zero"); 
		// the amount sent should not be more than half of treasury 
		// (when player win, 2*amount should be given to player. So our treasury should have enough money.)
		require(valueParam <= treasuryBalance/2, "Treasury is not enough");
		_;
	}
	
	constructor() payable {
		owner = payable(msg.sender);
		treasuryBalance = msg.value;
		
        // when smart contract has been created
        // for starting the play, some Ether is needed to pay by owner
		if (!(treasuryBalance > 0))
			revert TreasuryIsZero(); 
	}
	
	function play() external evaluateTreasury(msg.value) payable
	{
		// when modifier execute correctly this function run 
		// so we display who sent ether and how much ether has been sent 
        emit EtherReceived(msg.sender, msg.value);
        treasuryBalance += msg.value;

		player = payable(msg.sender);
		
		if( random() == 2 )
        {
            // if random() function returns 2 that means 49.9% probability has happened
            // so It is supposed to send back twice amount of player.
            treasuryBalance  -= (msg.value * 2);
            emit EtherSent(msg.sender, msg.value * 2);
            player.transfer(msg.value * 2);
        }		
	}
	
	function random() private returns (uint) {
		// get random integer numbers between 1 to 1000
		uint randomnumber = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 1000;
		randomnumber = randomnumber + 1; 
		// to display the rundom number, we will emit it
        emit ShowRandomNumber(randomnumber);

        // if condition would happen in 50.1% probability => return 0
		if(randomnumber <= 501)
			return 0;
		return 2;
	}
}
