// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract GoldVault {
    mapping(address => uint256) public goldBalance;
    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED_ = 2;

     constructor(){
        _status = _NOT_ENTERED;//初始状态
    }

     modifier nonReentrant(){
        require(_status != _ENTERED_, "Reentrant call blocked");
        _status = _ENTERED_;//上锁
        _;
        _status = _NOT_ENTERED;//解锁
    }

    function deposit() external payable {
        require(msg.value > 0, "Deposit must be more than 0");
        goldBalance[msg.sender] += msg.value;
    }

    function vulnerableWithdraw() external {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "ETH transfer failed");

        goldBalance[msg.sender] = 0;
    }

    function safeWithdraw() external nonReentrant {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        goldBalance[msg.sender] = 0;
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "ETH transfer failed");
    }

}
