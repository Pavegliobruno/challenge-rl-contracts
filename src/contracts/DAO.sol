// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DAO {

    struct Proposal {
        string title;
        string description;
        uint256 deadline;
        uint256 minimumVotes;
        uint256 votesForA;
        uint256 votesForB;
        mapping(address => bool) hasVoted;
        string optionAMeaning;
        string optionBMeaning;
        bool closed;
        bool finished;
    }

    Proposal[] public proposals;
    address public owner;
    mapping(address => bool) public admins;
    address public tokenAddress;
    IERC20 private tokenContract;

    constructor() {
        owner = msg.sender;
        admins[owner] = true;
    }

    function createProposal(
            string memory _title,
            string memory _description,
            uint256 _deadline,
            uint256 _minimumVotes,
            string memory _optionAMeaning,
            string memory _optionBMeaning
        ) public onlyAdmin {
            Proposal storage newProposal = proposals.push();
            newProposal.title = _title;
            newProposal.description = _description;
            newProposal.deadline = _deadline;
            newProposal.minimumVotes = _minimumVotes;
            newProposal.votesForA = 0;
            newProposal.votesForB = 0;
            newProposal.optionAMeaning = _optionAMeaning;
            newProposal.optionBMeaning = _optionBMeaning;
            newProposal.closed = false;
            newProposal.finished = false;
        }

    function vote(uint256 proposalIndex, uint256 option) external {
        require(proposalIndex < proposals.length, "Invalid proposal index");
        Proposal storage proposal = proposals[proposalIndex];

        require(
            option == 0 || option == 1,
            "Invalid option. Use 0 for Option A or 1 for Option B"
        );

        require(!proposal.hasVoted[msg.sender], "You have already voted");
    
        require(!proposal.closed, "Proposal is closed");

        if (block.timestamp >= proposal.deadline) {
        proposal.closed = true;
        revert("Voting deadline has passed");
        }

        require(
            tokenContract.balanceOf(msg.sender) > 0,
            "Voter has no tokens"
        );


        if (option == 0) {
            proposal.votesForA++;
        } else if (option == 1) {
            proposal.votesForB++;
        }

        proposal.hasVoted[msg.sender] = true;

        if (
           proposal.votesForA > proposal.minimumVotes ||
                proposal.votesForB > proposal.minimumVotes
        ) {
            proposal.closed = true;

            if (proposal.votesForA > proposal.votesForB) {
                proposal.finished = true;
                // Perform necessary actions for Option A winning
            } else {
                proposal.finished = true;
                // Perform necessary actions for Option B winning
            }
        }
    }

    function setTokenAddress(address _tokenAddress) public onlyAdmin {
        require(_tokenAddress != address(0), "Invalid token address");
        tokenAddress = _tokenAddress;
        tokenContract = IERC20(_tokenAddress);
    }

    function checkProposalResult(uint256 proposalIndex)
        public
        view
        returns (bool proposalPassed, uint256 votesForA, uint256 votesForB)
    {
        require(proposalIndex < proposals.length, "Invalid proposal index");
        Proposal storage proposal = proposals[proposalIndex];
        require(
            block.timestamp >= proposal.deadline,
            "Voting deadline has not passed yet"
        );

        return (
            proposal.votesForA > proposal.minimumVotes ||
                proposal.votesForB > proposal.minimumVotes,
            proposal.votesForA,
            proposal.votesForB
        );
    }

    function hasVoted(uint256 proposalIndex, address voter) public view returns (bool) {
        require(proposalIndex < proposals.length, "Invalid proposal index");
        Proposal storage proposal = proposals[proposalIndex];
        return proposal.hasVoted[voter];
    }

    function getProposalCount() public view returns (uint256) {
        return proposals.length;
    }

    function setAdmin(address _admin) public onlyOwner {
        admins[_admin] = true;
    }

    modifier onlyAdmin() {
        require(admins[msg.sender], "Only an admin can call this function");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
}