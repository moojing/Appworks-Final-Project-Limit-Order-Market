// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {OrderVerifier} from "../src/lib/OrderVerifier.sol";
import {Orderbook} from "../src/Orderbook.sol";
import {OrderStructs} from "../src/lib/OrderStructs.sol";
import {CollectionType} from "../src/enums/CollectionType.sol";
import {OrderType} from "../src/enums/OrderType.sol";

contract OrderSignatureTest is Test {
    using OrderVerifier for OrderStructs.Maker;

    OrderStructs.Maker makerOrder;

    // Orderbook orderbook;

    function setUp() public {
        // Orderbook orderbook = new Orderbook();
        // create a maker order
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
        // bytes32 message = orderbook.hashStruct(makerOrder);
        console.log('HASH:');
        console.logBytes32(makerOrder.hash());
    }
}
