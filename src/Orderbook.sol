// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {OrderVerifier} from "./lib/OrderVerifier.sol";
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
    using OrderVerifier for OrderStructs.Maker;

    // Order[] public bidOrders;
    // Order[] public askOrders;

    // errors
    error ChainIdInvalid(uint256 chainId);

    uint immutable chainId;

    bytes32 immutable DOMAIN_SEPARATOR =
        keccak256(
            abi.encode(
                OrderVerifier.EIP712DOMAIN_TYPEHASH,
                keccak256("Orderbook-v1"),
                keccak256(bytes("1")),
                block.chainid,
                address(this)
            )
        );
    uint256 immutable CHAIN_ID = block.chainid;

    constructor() {
        chainId = block.chainid;
    }

    function fulfillOrder(OrderStructs.Maker memory makerOrder) internal {
        // @todo the flow of fulfilling an order
        // makerOrder.isFilled = true;
    }

    /**
     * @notice This function is private and used to verify the chain id, compute the digest, and verify the signature.
     * @dev If chainId is not equal to the cached chain id, it would revert.
     * @param computedHash Hash of order (maker bid or maker ask) or merkle root
     * @param makerSignature Signature of the maker
     * @param signer Signer address
     */
    function _computeDigestAndVerify(
        bytes32 computedHash,
        bytes calldata makerSignature,
        address signer
    ) private view {
        if (chainId == block.chainid) {
            //       bytes32 digest = keccak256(
            //     abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, hashStruct(maker))
            // );
            // \x19\x01 is the standard encoding prefix
            OrderVerifier.verify(
                keccak256(
                    abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, computedHash)
                ),
                signer,
                makerSignature
            );
        } else {
            revert ChainIdInvalid(block.chainid);
        }
    }
}
