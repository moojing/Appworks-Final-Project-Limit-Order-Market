// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./lib/OrderVerifier.sol";
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
    string constant EIP712_DOMAIN_TYPE =
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)";

    // hash to prevent signature collision
    bytes32 public immutable DOMAIN_SEPARATOR =
        keccak256(
            abi.encode(
                keccak256(abi.encodePacked(EIP712_DOMAIN_TYPE)),
                keccak256(bytes("Orderbook-v1")),
                keccak256(bytes("4")),
                block.chainid,
                // @todo: change this to the real contract, and change for testing
                0x8865d9736Ad52c6cdBbEA9bCd376108284CFd0e4 // verifyingContract
            )
        );

    uint256 immutable CHAIN_ID = block.chainid;

    constructor() {
        chainId = block.chainid;
    }

    function fulfillMakerOrder(
        OrderStructs.Taker calldata takerAsk,
        OrderStructs.Maker memory makerOrder,
        bytes calldata makerSignature
    ) internal {
        // @todo the flow of fulfilling an order
        // check the currency in the order
        address currency = makerOrder.currency;

        // makerOrder.isFilled = true;
    }

    /**
     * @notice This function is private and used to verify the chain id, compute the digest, and verify the signature.
     * @dev If chainId is not equal to the cached chain id, it would revert.
     * @param computedHash Hash of order (maker bid or maker ask) or merkle root
     * @param makerSignature Signature of the maker
     * @param signer Signer address
     */
    // @todo : change this to internal
    function _computeDigestAndVerify(
        bytes32 computedHash,
        bytes calldata makerSignature,
        address signer
    ) public returns (bool) {
        if (chainId == block.chainid) {
            // \x19\x01 is the standard encoding prefix
            return
                OrderVerifier.verify(
                    keccak256(
                        abi.encodePacked(
                            "\x19\x01",
                            DOMAIN_SEPARATOR,
                            computedHash
                        )
                    ),
                    signer,
                    makerSignature
                );
        } else {
            revert ChainIdInvalid(block.chainid);
        }
    }
}
