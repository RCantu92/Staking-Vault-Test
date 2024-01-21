// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "./utils/OperatorFeeUtils.sol";
import "./interfaces/IFortaStaking.sol";

contract RedemptionReceiver is OwnableUpgradeable, ERC1155Holder {
    uint256[] subjects;
    mapping(uint256 => uint256) subjectsPending;

    IFortaStaking _staking;

    function initialize(address owner_, IFortaStaking staking_) public initializer {
        __Ownable_init(owner_);
        _staking = staking_;
    }

    function addUndelegations(uint256[] memory newUndelegations, uint256[] memory shares) public onlyOwner {
        for (uint256 i = 0; i < newUndelegations.length; ++i) {
            uint256 subject = newUndelegations[i];
            if (subjectsPending[subject] == 0) {
                subjects.push(subject);
            }
            subjectsPending[subject] = _staking.initiateWithdrawal(DELEGATOR_SCANNER_POOL_SUBJECT, subject, shares[i]);
        }
    }

    function claim(
        address receiver,
        uint256 feeInBasisPoints,
        address feeTreasury
    )
        public
        onlyOwner
        returns (uint256)
    {
        uint256 stake;
        for (uint256 i = 0; i < subjects.length;) {
            uint256 subject = subjects[i];
            if (
                (subjectsPending[subject] < block.timestamp)
                    && !_staking.isFrozen(DELEGATOR_SCANNER_POOL_SUBJECT, subject)
            ) {
                stake += _staking.withdraw(DELEGATOR_SCANNER_POOL_SUBJECT, subject);
                subjects[i] = subjects[subjects.length - 1];
                subjects.pop();
            } else {
                ++i;
            }
        }
        uint256 userStake = OperatorFeeUtils.deductAndTransferFee(
            stake, feeInBasisPoints, feeTreasury, IERC20(_staking.stakedToken())
        );
        IERC20(_staking.stakedToken()).transfer(receiver, userStake);
        return stake;
    }
}
