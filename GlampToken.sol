// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@5.0.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@5.0.0/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts@5.0.0/access/Ownable.sol";

/// @title GLAMP - IBITI Glamping Loyalty Token
/// @notice Utility token de fidelidade: mint controlado pela IBITI (owner),
/// hospede pode transferir e queimar (resgate de beneficios).
contract GlampToken is ERC20, ERC20Burnable, Ownable {

    // Supply maximo: 10.000.000 GLAMP (com 18 casas decimais)
    uint256 public constant MAX_SUPPLY = 10_000_000 * 10 ** 18;

    constructor(address initialOwner)
        ERC20("IBITI Glamping Token", "GLAMP")
        Ownable(initialOwner)
    {}

    /// @notice Cunha novos tokens (ex: cashback de reserva confirmada).
    /// @dev Restrito ao owner (carteira administrativa da IBITI).
    function mint(address to, uint256 amount) public onlyOwner {
        require(totalSupply() + amount <= MAX_SUPPLY, "GLAMP: excede supply maximo");
        _mint(to, amount);
    }
}