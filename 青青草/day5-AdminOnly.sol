// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AdminOnly{
    address public owner;//存储部署该合约的账户地址
    uint256 public treasureAmount;//引入宝物
    mapping(address => uint256)public withdrawalAllowance;//为每个钱包地址（address）绑定一个数字（uint256），用来记录该地址能提取的额度
    mapping(address => bool) public hasWithdrawn;//为每个钱包地址绑定一个「布尔值（true/false）」，用来记录该地址「是否已经提取过宝藏 / 完成提现」。

    constructor(){
        owner = msg.sender;//谁部署了这个合约，谁就是合约的拥有者
    }

    // 定义一个名为onlyOwner的修饰器
    modifier onlyOwner() {
    // 核心校验逻辑：检查调用者是否是合约所有者
        require(msg.sender == owner, "Access denied: Only the owner can perform this action");
    // 下划线：表示修饰器执行完校验后，会跳回被修饰函数的执行逻辑
        _;
    }

    // 定义一个只有所有者能调用的函数，即往宝箱中添加宝物
    function addTreasure(uint256 amount)public onlyOwner{
        treasureAmount += amount;//a += b → a = a+b，加减乘除都是如此，更简洁
    }

    //合约所有者为指定地址（recipient）批准一笔可提取的额度
    function approveWithdrawal(address recipient, uint256 amount)public onlyOwner{
        require(amount <= treasureAmount, "Not enough treasure available");
        //前提是合约里的总宝藏数量足够，否则报错拒绝操作
        withdrawalAllowance[recipient] = amount;
    }

    //取宝过程：
    function withdrawTreasure(uint256 amount)public{
        //如果是拥有者自己取宝：
        if(msg.sender == owner){
            require(amount <= treasureAmount, "Not enough treasure available for this action.");
            treasureAmount -= amount;
            return;
        }

        //如果是普通用户取宝：
        uint256 allowance = withdrawalAllowance[msg.sender];
        require(allowance > 0, "You don't have any treasure allowance.");//是否被批准提取？
        require(!hasWithdrawn[msg.sender], "You have already withdrawn your treasure.");//是否已经提取过？
        require(allowance <= treasureAmount, "Not enough treasure in the chest.");//宝箱里面是否仍有足够的宝物？
        

        //完成取宝：
        hasWithdrawn[msg.sender] = true;
        treasureAmount -= allowance;
        withdrawalAllowance[msg.sender] = 0;
    }
    
    //重置用户提取状态
    function resetWithdrawalStatus(address user)public onlyOwner{
        hasWithdrawn[user] = false;
    }

    // 转移合约所有权的函数
    function transferOwnership(address newOwner) public onlyOwner {
    // 校验：新所有者地址不能是无效的空地址
        require(newOwner != address(0), "Invalid address");
    // 把合约所有者更新为新地址
        owner = newOwner;
    }

    //查看宝箱信息
    function getTreasureDetails() public view onlyOwner returns (uint256) {
        return treasureAmount;
    }