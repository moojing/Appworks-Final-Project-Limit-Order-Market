// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "forge-std/console.sol";
import {OrderStructs} from "../lib/OrderStructs.sol";

library OrderSignature {
    bytes32 constant EIP712DOMAIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );

    bytes32 constant MAKER_TYPEHASH =
        keccak256(
            "Maker(OrderType orderType,bool isFulfilled,uint256 globalNonce,uint256 subsetNonce,uint256 orderNonce,CollectionType collectionType,address collection,address currency,address signer,uint256 startTime,uint256 endTime,uint256 price,uint256[] itemIds,uint256[] amounts)"
        );

    bytes32 constant DOMAIN_SEPARATOR =
        keccak256(
            abi.encode(
                EIP712DOMAIN_TYPEHASH,
                keccak256("Orderbook-v1"),
                keccak256(bytes("1")),
                block.chainid,
                address(this)
            )
        );

    function hashStruct(
        OrderStructs.Maker memory maker
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    MAKER_TYPEHASH,
                    maker.orderType,
                    maker.isFulfilled,
                    maker.globalNonce,
                    maker.subsetNonce,
                    maker.orderNonce,
                    maker.collectionType,
                    maker.collection,
                    maker.currency,
                    maker.signer,
                    maker.startTime,
                    maker.endTime,
                    maker.price,
                    maker.itemIds,
                    maker.amounts
                )
            );
    }

    function splitSignature(
        bytes memory sig
    ) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(sig.length == 65);

        assembly {
            // first 32 bytes, after the length prefix.
            r := mload(add(sig, 32))
            // second 32 bytes.
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes).
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function verify(
        OrderStructs.Maker memory maker,
        address signer,
        bytes memory sig
    ) public view returns (bool) {
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, hashStruct(maker))
        );

        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);

        return ecrecover(digest, v, r, s) == signer;
    }
}
