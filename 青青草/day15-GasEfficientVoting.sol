// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract GasEfficientVoting{
    uint8 public proposalCount;
    struct Proposal {
        bytes32 name;
        uint32 voteCount;
        uint32 startTime;
        uint32 endTime;
        bool executed;
    }

        mapping(uint8 => Proposal) public proposals;
        mapping(address => uint256) private voterRegistry; 
        mapping(uint8 => uint32) public proposalVoterCount;

        event ProposalCreated(uint8 indexed proposalId, bytes32 name);
        event Voted(address indexed voter, uint8 indexed proposalId);
        event ProposalExecuted(uint8 indexed proposalId);

        function createProposal(bytes32 name, uint32 duration) external{
            require(duration > 0, "Duration must be > 0");
            
            uint8 proposalId = proposalCount;
            proposalCount++;

            Proposal memory newProposal = Proposal({
                name: name,
                voteCount: 0,
                startTime: uint32(block.timestamp),
                endTime: uint32(block.timestamp) + duration,
                executed: false
            });

            proposals[proposalId] = newProposal;
            emit ProposalCreated(proposalId, name);
        }

        function vote(uint8 proposalId) external{
            require(proposalId < proposalCount, "Invalid proposal");
            uint32 currentTime = uint32(block.timestamp);
            require(currentTime >= proposals[proposalId].startTime, "Voting not started");
            require(currentTime <= proposals[proposalId].endTime, "Voting has already ended");
        //首先检查是否已经投票
            uint256 voterData = voterRegistry[msg.sender];
            uint mask = 1 << proposalId;
            require((voterData & mask) == 0, "Already voted");
        //执行投票操作：
            voterRegistry[msg.sender] = voterData | mask;// 标记已投票
            proposals[proposalId].voteCount++; // 提案总票数+1
            proposalVoterCount[proposalId]++;// 提案投票人数+1

            emit Voted(msg.sender, proposalId);// 触发投票事件

        }

        function excuteProposal(uint8 proposalId) external {
            require(proposalId < proposalCount, "Invalid proposal");
            require(block.timestamp > proposals[proposalId].endTime, "Voting not ended");
            require(!proposals[proposalId].executed, "Already executed");

            proposals[proposalId].executed = true;

            emit ProposalExecuted(proposalId);
        }


        function hasVoted(address voter, uint proposalId) external view returns (bool){
            return (voterRegistry[voter] & (1 << proposalId)) != 0;
        }

        function getProposal(uint8 proposalId) external view returns (
            bytes32 name,
            uint32 voteCount,
            uint32 startTime,
            uint32 endTime,
            bool executed,
            bool active//投票当前是否正在进行，这对UI/UX很有用，让前端知道是否应该显示“投票按钮”
        ) {
            require(proposalId < proposalCount, "Invalid proposal");
            Proposal storage proposal = proposals[proposalId];

            return(
                proposal.name,
                proposal.voteCount,
                proposal.startTime,
                proposal.endTime,
                proposal.executed,
                (block.timestamp >= proposal.startTime && block.timestamp <= proposal.endTime)
            );
        }

}