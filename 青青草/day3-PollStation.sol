// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract PollStation{

    string[] public candidateNames;
    mapping(string => uint256) voteCount;

    function addCandidateNames(string memory _candidateNames) public{
        candidateNames.push(_candidateNames);
         //把新候选人名字加到"候选人名单"的末尾
        voteCount[_candidateNames] = 0; // 初始化这个候选人的得票数为0（刚加入还没人投票）

    }
    

 // 获取所有候选人名单：只能看不能改（view），返回所有候选人名字
    function getcandidateNames() public view returns (string[] memory){
        return candidateNames;
    }
 // 投票函数：给指定候选人投票（比如你选小明，就调用这个函数填"小明"）
    function vote(string memory _candidateNames) public{
        voteCount[_candidateNames] += 1;
    }

    function getVote(string memory _candidateNames) public view returns (uint256){
        return voteCount[_candidateNames];
    }

}