// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./NonceManager.sol";
import "./lib/OrderVerifier.sol";
import {OrderStructs} from "./lib/OrderStructs.sol";
import {StrategyManager} from "./StrategyManager.sol";
import {ChainIdInvalid, NoncesInvalid} from "./errors/GlobalErrors.sol";

contract Orderbook is NonceManager, StrategyManager {
    using OrderVerifier for OrderStructs.Maker;

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
                address(this) // verifyingContract
            )
        );

    uint256 immutable CHAIN_ID = block.chainid;

    constructor() StrategyManager(msg.sender) {
        chainId = block.chainid;
    }

    function fulfillMakerOrder(
        OrderStructs.Taker calldata takerOrder,
        OrderStructs.Maker calldata makerOrder,
        bytes calldata makerSignature
    ) public {
        bytes32 orderHash = makerOrder.hash();
        //@todo check the currency in the order
        address currency = makerOrder.currency;
        console.log("currency", currency);

        bool result = _computeDigestAndVerify(
            makerOrder.hash(),
            makerSignature,
            makerOrder.signer
        );

        require(result, "Signature of the order is invalid");

        // Verify nonces
        address signer = makerOrder.signer;
        {
            bytes32 userOrderNonceStatus = userOrderNonce[signer][
                makerOrder.orderNonce
            ];

            if (
                // @todo : add the checking back
                // userBidAskNonces[signer].askNonce != makerAsk.globalNonce ||
                // userSubsetNonce[signer][makerAsk.subsetNonce] ||

                // if the userOrderNonceStatus is not 0, it means that the order has been fulfilled or cancelled
                (userOrderNonceStatus != bytes32(0) &&
                    userOrderNonceStatus != orderHash)
            ) {
                revert NoncesInvalid();
            }
        }

        // @todo Update the nonce of order maker/signer
        // userOrderNonce[signer][orderNonce] = (
        //     isNonceInvalidated ? MAGIC_VALUE_ORDER_NONCE_EXECUTED : orderHash
        // );
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
