
/*-----------------------------------------------------------------
 *  TO DO
 *-----------------------------------------------------------------
 * VOTING CONTRACT
 *---------------------------------------------------------------*/

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
    uint256 public airdrop = 10000; // amount to be airdropped to people upon minting of DID
    uint256 public weekInSeconds = 604800; //week in seconds
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
            "MOD: Caller !CONTRACT_ADMIN_ROLE"
        );
        _;
    }

    /**
     * @dev Set DID contract to interface with
     * @param _DIDaddress - DID contract address
     */
    function setDIDcontract(address _DIDaddress) external isContractAdmin {
        require(_DIDaddress != address(0), "DID address = 0");
        //^^^^^^^checks^^^^^^^^^

        DID = DID_Interface(_DIDaddress);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Set token contract to interface with
     * @param _TOKENaddress - DID contract address
     */
    function setTOKENcontract(address _TOKENaddress) external isContractAdmin {
        require(_TOKENaddress != address(0), "TOKEN address = 0");
        //^^^^^^^checks^^^^^^^^^
        TOKEN = TOKEN_Interface(_TOKENaddress);
        //^^^^^^effects^^^^^^^^^
    }


    /**
     * @dev Mints DID to msgSender address, along with airdrop allotment
     */
    function getDID() external {
        tokenId++;
        DID.mintDID(_msgSender(), tokenId);
        TOKEN.mint(_msgSender(), airdrop);
    }

    /**
     * @dev Mints DID to msgSender address, along with airdrop allotment
     * @param _proposal - hash of proposal information (IPFS)?
     */
    function createProposal(bytes32 _proposal) external {
        uint256 expiration = block.timestamp + weekInSeconds;
        require(DID.balanceOf(_msgSender()) == 1, "caller !hold DID");
        proposalNum++;
        proposals[proposalNum].mutableStorage = _proposal;
        proposals[proposalNum].expiry = expiration;
    }


    /**
     * @dev End current proposal, set proposal reward based on voting data
     * @param _proposalNum - index of proposal
     */
    function endProposal(uint256 _proposalNum) external {
        uint256 calculatedReward = 0; //@dev change to new calculated value

        require(
            proposals[_proposalNum].expiry >= block.timestamp,
            "Proposal !expired"
        );

        require(proposals[_proposalNum].reward == 0, "Proposal already ended");

        proposals[_proposalNum].reward = calculatedReward;
    }

    /**
     * @dev Applies vote of user balance to either yes or no in proposal[_proposalNum].
     * @param _proposalNum - index of proposal
     * @param _vote - 0 = no, 1 = yes
     */
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


    /**
     * @dev Claims rewards based on vote allotment on given proposal
     * @param _proposalNum - index of proposal
     */
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

    /**
     * @dev Retrieves proposal struct @ index
     * @param _proposalNum - index of proposal
     */
    function getProposal(uint256 _proposalNum) public view returns(Proposal memory) {
        return(proposals[_proposalNum]);
    }

}
