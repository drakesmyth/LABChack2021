// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "./imports/utils/Counters.sol";
import "./imports/token/ERC721/ERC721.sol";
import "./imports/access/AccessControl.sol";

/**
 * @dev {ERC721} token, including:
 *
 *  - a minter role that allows for token minting (creation)
 *
 * This contract uses {AccessControl} to lock permissioned functions using the
 * different roles - head to its documentation for details.
 *
 * The account that deploys the contract will be granted the minter and pauser
 * roles, as well as the default admin role, which will let it grant both minter
 * and pauser roles to other accounts.
 */
contract DID is Context, AccessControl, ERC721 {
    using Counters for Counters.Counter;
    using Strings for uint256;
    bytes32 public constant CONTRACT_ADMIN_ROLE =
        keccak256("CONTRACT_ADMIN_ROLE");

    constructor() ERC721("DID", "DID") {
        _setupRole(CONTRACT_ADMIN_ROLE, _msgSender());
    }

    //---------------------------------------Modifiers-------------------------------

    /**
     * @dev Verify user credentials
     * Originating Address:
     *      has CONTRACT_ADMIN_ROLE
     */
    modifier isContractAdmin() {
        require(
            hasRole(CONTRACT_ADMIN_ROLE, _msgSender()),
            "MOD:Calling address does not belong to a contract admin"
        );
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     * @return supported interfaceId
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControl, ERC721)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Transfers the ownership of a given token ID to another address.
     * Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     * Requires the _msgSender() to be the owner, approved, or operator.
     * @param _from current owner of the token
     * @param _to address to receive the ownership of the given token ID
     * @param _tokenId uint256 ID of the token to be transferred
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public override {
        require(1 == 0, "Transfers disabled for DID(s)");
        //^^^^^^^checks^^^^^^^^
        _transfer(_from, _to, _tokenId);
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement {IERC721Receiver-onERC721Received},
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the _msgSender() to be the owner, approved, or operator
     * @param _from current owner of the token
     * @param _to address to receive the ownership of the given token ID
     * @param _tokenId uint256 ID of the token to be transferred
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public override {
        //^^^^^^^checks^^^^^^^^

        require(1 == 0, "Transfers disabled for DID(s)");
        safeTransferFrom(_from, _to, _tokenId);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement {IERC721Receiver-onERC721Received},
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the _msgSender() to be the owner, approved, or operator
     * @param _from current owner of the token
     * @param _to address to receive the ownership of the given token ID
     * @param _tokenId uint256 ID of the token to be transferred
     * @param _data bytes data to send along with a safe transfer check
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) public virtual override {
        require(1 == 0, "Transfers disabled for DID(s)");

        _safeTransfer(_from, _to, _tokenId, _data);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Mint an Asset token (may mint only to node holder depending on flags)
     * @param _recipientAddress - Address to mint token into
     * @param _tokenId - Token ID to mint
     * @return Token ID of minted token
     */
    function mintDID(address _recipientAddress, uint256 _tokenId)
        external
        isContractAdmin
        returns (uint256)
    {
        //^^^^^^^checks^^^^^^^^^

        require(balanceOf(_msgSender()) == 0, "user already has DID");

        _safeMint(_recipientAddress, _tokenId);
        //^^^^^^^effects^^^^^^^^^

        return (_tokenId);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev all paused functions are blocked here (inside ERC720Pausable.sol)
     * @param _from - from address
     * @param _to - to address
     * @param _tokenId - token ID to transfer
     */
    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal virtual override(ERC721) {
        super._beforeTokenTransfer(_from, _to, _tokenId);
    }
}
