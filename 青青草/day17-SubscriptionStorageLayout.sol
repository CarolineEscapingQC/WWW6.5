// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SubscriptionStorageLayout {
    address public logicContract;
    address public owner;//合约的管理员或部署者——唯一可以升级到新逻辑版本的人

    struct Subscription{
        uint planId;
        uint256 expiry;//一个时间戳，指示订阅何时到期
        bool paused;//一个开关，用于**在不删除的情况下**临时停用用户的订阅。可用于允许用户暂停或恢复他们的套餐。
    }

    mapping(address => Subscription) public subscriptions;
    mapping(uint8 => uint256) public planPrices;//每个套餐需要多少 ETH。
    mapping(uint8 => uint256)public planDuration;
}