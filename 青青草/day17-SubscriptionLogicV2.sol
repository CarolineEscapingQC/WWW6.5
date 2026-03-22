// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day16-SubscriptionStorageLayout.sol";


contract SubscriptionLogicV2 is SubscriptionStorageLayout{
    function addPlan(uint8 planId, uint256 price, uint256 duration) external {
        planPrices[planId] = price;
        planDuration[planId] = duration;
    }

    function subscribe(uint8 planId) external payable{
        require(planPrices[planId] > 0, "Invalid plan");
        require(msg.value > planPrices[planId], "Insufficient payment");

        Subscription storage s = subscriptions[msg.sender];
        if (block.timestamp >= s.expiry) {
            s.expiry += planDuration[planId];
        } else {
            s.expiry = block.timestamp +planDuration[planId];
        }

        s.planId = planId;
        s.paused = false;
    }

    

    function pauseAccount(address user) external {
        subscriptions[user].paused = true;
    }//暂停

    function resumeAccount(address user)external {
        subscriptions[user].paused = false;
    }//恢复



}