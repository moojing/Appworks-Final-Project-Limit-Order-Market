// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {OrderSignature} from "../src/lib/OrderSignature.sol";
import {OrderStructs} from "../src/lib/OrderStructs.sol";
import {CollectionType} from "../src/enums/CollectionType.sol";
import {OrderType} from "../src/enums/OrderType.sol";

contract OrderSignatureTest is Test {
    OrderStructs.Maker makerOrder;

    function setUp() public {
        uint256[] memory itemIds = new uint256[](3);
        itemIds[0] = 1;
        itemIds[1] = 2;
        itemIds[2] = 3;
        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 1;
        amounts[1] = 1;
        amounts[2] = 1;
        makerOrder = OrderStructs.Maker({
            orderType: OrderType.Ask,
            isFulfilled: false,
            globalNonce: 1,
            subsetNonce: 2,
            orderNonce: 3,
            collectionType: CollectionType.ERC721,
            collection: 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,
            currency: 0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c,
            signer: 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db,
            startTime: 1672444800, //20230101
            endTime: 1703980800, // 20231231
            price: 1000000000000000000, //1 ETH
            itemIds: itemIds,
            amounts: amounts
        });
    }

    function testMessageHash() public {
        bytes32 message = OrderSignature.getMessageHash(makerOrder);
        assertEq(
            message,
            0x98497dd969d0f78b12c01d1f88d1a194fe415c405c5e9b904adfb5cb3f4760e7
        );
        bytes32 ethSignedMessageHash = OrderSignature.getEthSignedMessageHash(
            message
        );

        assertEq(
            ethSignedMessageHash,
            0xd4d6a7b74e4ba6f989db9706fe72e9dd67917d5090cd1d21fd846fd148f8926d
        );
        console.logBytes32(ethSignedMessageHash);
        // bytes
        // memory sig = 0xc23a9f49f0ee334403d4f4cd83c35e0a9372018a60eeb60d0321cb7339cd25df7121bbdf4597eb39efaf3e55ef9de6458a38cfd89deaa337aa022be12ce0443b1b;
        bytes
            memory sig = hex"c23a9f49f0ee334403d4f4cd83c35e0a9372018a60eeb60d0321cb7339cd25df7121bbdf4597eb39efaf3e55ef9de6458a38cfd89deaa337aa022be12ce0443b1b";

        address signer = OrderSignature.recoverSigner(
            0xd4d6a7b74e4ba6f989db9706fe72e9dd67917d5090cd1d21fd846fd148f8926d,
            sig
        );

        console.log("addr", signer);
    }
}
