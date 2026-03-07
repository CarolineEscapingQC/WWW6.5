// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract auctionHouse{
    address public owner;
    string public item;
    uint public auctionEndTime;//拍卖结束时间
    address private highestBidder;//目前出价最高的人
    uint private highestBid;//目前最高出价

    bool public ended;//布尔函数，有true of false（拍卖是否结束）

    mapping(address => uint) public bids;//记录每个人的出价
    address[] public bidders;//所有参与出价的人列表

    constructor(string memory _item, uint _biddingTime){
        owner = msg.sender;//店主是谁
        item = _item;//拍卖什么东西
        auctionEndTime = block.timestamp + _biddingTime;
    }
    //以下是出价函数：别人来出价时调用
    function bid(uint amount)external{
        //require为检查规则，不满足就报错，不让操作
        require(block.timestamp < auctionEndTime, "Auction has already ended.");
        require(amount > 0, "Bid amount must be greater than zero.");
        require(amount > bids[msg.sender], "new bid must be higher than your current bid.");
        
        if (bids[msg.sender] == 0){
            // 如果这个人是第一次出价，就把他加入"出价人列表"
    
            bidders.push(msg.sender);
        }
        bids[msg.sender] = amount;//更新这个人的最新出价

        if (amount > highestBid){
            highestBid = amount;
            highestBidder = msg.sender;
        }
    }

        function endAuction()external{
            require(block.timestamp >= auctionEndTime,"Auction hasn't ended yet.");
            require(!ended, "Auction end already called.");
            ended = true;
        }
        function getWinner()external view returns (address, uint){
            require(ended, "Auction has not ended yet.");
            return(highestBidder, highestBid);
        }
        
        function getAllBidders()external view returns(address[] memory){
            return bidders;
        }

}