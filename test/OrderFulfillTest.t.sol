// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";
// import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {OrderVerifier} from "../src/lib/OrderVerifier.sol";
import {Orderbook} from "../src/Orderbook.sol";
import {OrderStructs} from "../src/lib/OrderStructs.sol";
import {CollectionType} from "../src/enums/CollectionType.sol";
import {OrderType} from "../src/enums/OrderType.sol";

address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
address constant ONCHAIN_MONKEY = 0x960b7a6BCD451c9968473f7bbFd9Be826EFd549A;

contract OrderFulfillTestTest is Test {
    using OrderVerifier for OrderStructs.Maker;
    Orderbook testOrderBook;
    OrderStructs.Maker makerOrder;

    address alice;
    uint256 alicePrivateKey;
    address bob;
    uint256 bobPrivateKey;

    bytes32 public constant MAGIC_VALUE_ORDER_NONCE_EXECUTED =
        keccak256("ORDER_NONCE_EXECUTED");

    // Orderbook orderbook;

    function setUp() public {
        string memory rpc = vm.envString("NET_RPC_URL");
        vm.createSelectFork(rpc);

        // set account
        string
            memory mnemonic = "test test test test test test test test test test test junk";
        alicePrivateKey = vm.deriveKey(mnemonic, 0);
        alice = vm.addr(alicePrivateKey);
        bob = vm.addr(vm.deriveKey(mnemonic, 1));
        bobPrivateKey = vm.deriveKey(mnemonic, 1);

        uint256 initialBalance = 50_000 * 10 ** 6;
        dealERC721(ONCHAIN_MONKEY, alice, 1);
        deal(USDC, bob, initialBalance);

        // create a maker order
        uint256[] memory itemIds = new uint256[](3);
        // itemIds[0] = 1;
        // itemIds[1] = 2;
        // itemIds[2] = 3;
        uint256[] memory amounts = new uint256[](3);
        // amounts[0] = 1;
        // amounts[1] = 1;
        // amounts[2] = 1;

        makerOrder = OrderStructs.Maker({
            orderType: OrderType.Ask,
            globalNonce: 1,
            subsetNonce: 1,
            orderNonce: 1,
            collectionType: CollectionType.ERC721,
            collection: ONCHAIN_MONKEY,
            currency: USDC,
            signer: alice,
            startTime: 1672444800, //20230101
            endTime: 1703980800, // 20231231
            price: 100 * 10 ** 6, //1 ETH
            itemIds: itemIds,
            amounts: amounts
        });

        testOrderBook = new Orderbook();
    }

    // from seaport
    function getSignatureComponents(
        // ConsiderationInterface _consideration,
        uint256 _pkOfSigner,
        bytes32 _orderHash
    ) internal view returns (bytes32, bytes32, uint8) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            _pkOfSigner,
            keccak256(
                abi.encodePacked(
                    bytes2(0x1901),
                    testOrderBook.DOMAIN_SEPARATOR(),
                    _orderHash
                )
            )
        );
        return (r, s, v);
    }

    function signOrder(
        uint256 _pkOfSigner,
        bytes32 _orderHash
    ) internal view returns (bytes memory) {
        (bytes32 r, bytes32 s, uint8 v) = getSignatureComponents(
            _pkOfSigner,
            _orderHash
        );
        return abi.encodePacked(r, s, v);
    }

    function testSignOrder() public {
        bytes memory signature = signOrder(alicePrivateKey, makerOrder.hash());
        // console.log("HASH:");
        // console.logBytes32(makerOrder.hash());
        // console.log("ALICE");
        // console.logAddress(alice);
        // console.log("SIGNATURE");
        // console.logBytes(signature);
        bool result = testOrderBook._computeDigestAndVerify(
            makerOrder.hash(),
            signature,
            alice
        );

        assertEq(result, true, "signature should be valid");
    }

    function testFufillOrder() public {
        OrderStructs.Taker memory takerOrder = OrderStructs.Taker({
            recipient: bob
        });
        bytes memory makerSignature = signOrder(
            alicePrivateKey,
            makerOrder.hash()
        );

        testOrderBook.fulfillMakerOrderBid(
            takerOrder,
            makerOrder,
            makerSignature
        );
        console.logBytes32(
            testOrderBook.userOrderNonce(alice, makerOrder.orderNonce)
        );
        assertEq(
            testOrderBook.userOrderNonce(alice, makerOrder.orderNonce),
            MAGIC_VALUE_ORDER_NONCE_EXECUTED,
            "maker order should be fulfilled"
        );
    }
}
