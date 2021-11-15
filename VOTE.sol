// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.0;

import "./imports/access/AccessControl.sol";
import "./interfaces.sol";

contract VOTE is AccessControl {
    struct Proposal {
        uint256 reward;
        uint256 yes;
        uint256 no;
        bytes32 mutableStorage;
        uint256 expiry;
        uint32 participantCount;
    }

    mapping(address => mapping(uint256 => uint8)) private votingStatus;
    mapping(address => mapping(uint256 => uint8)) private claimStatus;
    mapping(uint256 => Proposal) public proposals;

    bytes32 public constant CONTRACT_ADMIN_ROLE =
        keccak256("CONTRACT_ADMIN_ROLE");
    uint256 public tokenId;
    uint256 public proposalNum;
    uint256 public airdrop = 10000;
    uint256 public weekInSeconds = 604800;
    address internal TOKEN_Address;
    TOKEN_Interface internal TOKEN;

    address internal DID_Address;
    DID_Interface internal DID;

    /**
     * @dev Verify user credentials
     * Originating Address:
     *      has CONTRACT_ADMIN_ROLE
     */
    modifier isContractAdmin() virtual {
        require(
            hasRole(CONTRACT_ADMIN_ROLE, _msgSender()),
            "B:MOD:-IADM Caller !CONTRACT_ADMIN_ROLE"
        );
        _;
    }

    /**
     * @dev Set storage contract to interface with
     * @param _DIDaddress - DID contract address
     */
    function setDIDcontract(address _DIDaddress) external isContractAdmin {
        require(_DIDaddress != address(0), "DID address = 0");
        //^^^^^^^checks^^^^^^^^^

        DID = DID_Interface(_DIDaddress);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Set storage contract to interface with
     * @param _TOKENaddress - DID contract address
     */
    function setTOKENcontract(address _TOKENaddress) external isContractAdmin {
        require(_TOKENaddress != address(0), "TOKEN address = 0");
        //^^^^^^^checks^^^^^^^^^
        TOKEN = TOKEN_Interface(_TOKENaddress);
        //^^^^^^effects^^^^^^^^^
    }

    function getDID() external {
        tokenId++;
        DID.mintDID(_msgSender(), tokenId);
        TOKEN.mint(_msgSender(), airdrop);
    }

    function createProposal(bytes32 _proposal) external {
        uint256 expiration = block.timestamp + weekInSeconds;
        require(DID.balanceOf(_msgSender()) == 1, "caller !hold DID");
        proposalNum++;
        proposals[proposalNum].mutableStorage = _proposal;
        proposals[proposalNum].expiry = expiration;
    }

    function endProposal(uint256 _proposalNum) external {
        uint256 calculatedReward = 0;

        require(
            proposals[_proposalNum].expiry >= block.timestamp,
            "Proposal !expired"
        );

        require(proposals[_proposalNum].reward == 0, "Proposal already ended");

        proposals[_proposalNum].reward = calculatedReward;
    }

    function voteOn(uint256 _proposalNum, uint8 _vote) external {
        require(DID.balanceOf(_msgSender()) == 1, "User does not hold ID");

        require(
            votingStatus[_msgSender()][_proposalNum] == 0,
            "User already voted"
        );

        require(_vote == 1 || _vote == 0, "Invalid vote");

        votingStatus[_msgSender()][_proposalNum] = 1;

        proposals[_proposalNum].participantCount++;

        if (_vote == 1) {
            proposals[_proposalNum].yes =
                proposals[_proposalNum].yes +
                TOKEN.balanceOf(_msgSender());
        } else {
            proposals[_proposalNum].no =
                proposals[_proposalNum].no +
                TOKEN.balanceOf(_msgSender());
        }
    }

    function claimReward(uint256 _proposalNum) external {
        require(votingStatus[_msgSender()][_proposalNum] == 1, "User !voted");
        require(proposals[_proposalNum].reward != 0, "Proposal !ended");
        require(
            claimStatus[_msgSender()][_proposalNum] == 0,
            "User already claimed"
        );

        claimStatus[_msgSender()][_proposalNum] = 1;

        TOKEN.mint(_msgSender(), proposals[_proposalNum].reward);
    }

    function getProposal(uint256 _proposalNum) public view returns(Proposal memory) {
        return(proposals[_proposalNum]);
    }

}
