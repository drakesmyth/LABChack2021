
/*-----------------------------------------------------------------
 *  TO DO
 *-----------------------------------------------------------------
 * TOKEN CONTRACT
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./Imports/access/AccessControl.sol";
import "./Imports/token/ERC20/ERC20.sol";

/**
 * @dev {ERC20} token, including:
 *
 *  - a MINTER_ROLE that allows for token minting (creation)
 *
 * This contract uses {AccessControl} to lock permissioned functions using the
 * different roles - head to its documentation for details.
 *
 * The account that deploys the contract will be granted the minter 
 * roles, as well as the default admin role, which will let it grant minter roles
 * to external parties
 */
contract TOKEN is
    Context,
    AccessControl,
    ERC20
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    //using SafeMath for uint256;

    uint256 private _cap = 100000000000000000000000000; //100 million max supply

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, and `MINTER_ROLE` to the
     * account that deploys the contract.
     *
     * See {ERC20-constructor}.
     */
    constructor() ERC20("TOKEN NAME", "TICKER") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    }

    //------------------------------------------------------------------------MODIFIERS

    /**
     * @dev Verify user credentials
     * Originating Address:
     *      has DEFAULT_ADMIN_ROLE --- NOT!!  Contract admin role (legacy)
     */
    modifier isAdmin() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "MOD: must have DEFAULT_ADMIN_ROLE"
        );
        _;
    }

    /**
     * @dev Verify user credentials
     * Originating Address:
     *      has MINTER_ROLE
     */
    modifier isMinter() {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "MOD: must have MINTER_ROLE"
        );
        _;
    }

    /**
     * @dev Creates `_amount` new tokens for `to`.
     *
     * See {ERC20-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     * @param _to - Address to send tokens to
     * @param _amount - amount of tokens to mint
     */
    function mint(address _to, uint256 _amount) external virtual {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "MOD: must have MINTER_ROLE"
        );
        //^^^^^^^checks^^^^^^^^^

        _mint(_to, _amount);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Returns the cap on the token's total supply.
     * returns total cap
     */
    function cap() external view returns (uint256) {
        return _cap;
    }

    /**
     * @dev 
     * @param _from - Address from which to send tokens
     * @param _to - Address to send tokens to
     * @param _amount - amount of tokens to transfer
     */
    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal virtual override(ERC20) {
        super._beforeTokenTransfer(_from, _to, _amount);
        if (_from == address(0)) {
            // When minting tokens
            require(
                totalSupply() + (_amount) <= _cap,
                "ERC20Capped: cap exceeded"
            );
        }
    }
}
