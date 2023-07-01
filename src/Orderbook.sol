// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {OrderStructs} from "./lib/OrderStructs.sol";

// for testing
// contract Token1 is ERC20 {
//     // Constructor function that initializes the ERC20 token with a custom name, symbol, and initial supply
//     // The name, symbol, and initial supply are passed as arguments to the constructor
//     constructor(
//         string memory name,
//         string memory symbol,
//         uint256 initialSupply
//     ) ERC20(name, symbol) {
//         // Mint the initial supply of tokens to the deployer's address
//         _mint(msg.sender, initialSupply);
//     }
// }

// contract Token2 is ERC20 {
//     constructor(
//         string memory name,
//         string memory symbol,
//         uint256 initialSupply
//     ) ERC20(name, symbol) {
//         // Mint the initial supply of tokens to the deployer's address
//         _mint(msg.sender, initialSupply);
//     }
// }

contract Orderbook {
    // struct Order {
    //     uint256 id;
    //     address trader; // Address of the trader who created the order
    //     OrderType orderType;
    //     address baseToken;
    //     address quoteToken;
    //     uint256 price;
    //     uint256 quantity;
    //     bool isFilled;
    // }

    // Order[] public bidOrders;
    // Order[] public askOrders;

    function fulfillOrder(OrderStructs.Maker memory makerOrder) internal {
        // @todo the flow of fulfilling an order
        // makerOrder.isFilled = true;
    }
}
