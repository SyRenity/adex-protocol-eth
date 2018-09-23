pragma solidity 0.4.25;

library BidLibrary {
	// @TODO: schema hash
	enum BidState { 
		// Unknown means it does not exist on-chain, i.e. there's never been a DeliveryCommitment for it
		Unknown,

		Active,

		// fail states
		Canceled,
		// the following 2 states MUST unlock the reward amount (return to advertiser)
		DeliveryTimedOut,
		DeliveryFailed,

		// success states
		DeliverySucceeded
	}

	struct Bid {
		address advertiser;
		bytes32 adUnit;

		// Requirements
		bytes32 goal;
		uint timeout;

		// Reward
		address tokenAddr;
		uint tokenAmount;

		// @TODO: should this be 'nonce'?
		uint openedTime;

		address[] validators;
		uint[] validatorRewards;
	}

	function fromValues(bytes32[7] values, address[] validators, uint[] validatorRewards)
		internal
		pure
		returns (Bid memory)
	{
		return Bid({
			advertiser: address(values[0]),
			adUnit: values[1],
			goal: values[2],
			timeout: uint(values[3]),
			tokenAddr: address(values[4]),
			tokenAmount: uint(values[5]),
			openedTime: uint(values[6]),
			validators: validators,
			validatorRewards: validatorRewards
		});
	}

	// The addr of the SC is part of the hash, cause otherwise we might replay bids on newer versions
	function hash(Bid memory bid) internal view returns (bytes32) {
		// In this version of solidity, we can no longer keccak256() directly
		return keccak256(abi.encodePacked(
			address(this),
			bid.advertiser,
			bid.adUnit,
			bid.goal,
			bid.timeout,
			bid.tokenAddr,
			bid.tokenAmount,
			bid.openedTime,
			bid.validators,
			bid.validatorRewards
		));
	}
}