// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

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
import {ITransferManager} from "../src/interfaces/ITransferManager.sol";

address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
address constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
address constant ONCHAIN_MONKEY = 0x960b7a6BCD451c9968473f7bbFd9Be826EFd549A;

contract OrderFulfillTestTest is Test {
    using OrderVerifier for OrderStructs.Maker;
    Orderbook testOrderBook;
    OrderStructs.Maker makerOrder;
    uint constant INITIAL_ERC20_BALANCE = 50_000 * 10 ** 6;

    address alice;
    uint256 alicePrivateKey;
    address bob;
    uint256 bobPrivateKey;

    bytes32 public constant MAGIC_VALUE_ORDER_NONCE_EXECUTED =
        keccak256("ORDER_NONCE_EXECUTED");

    event ERC721Transferred(
        address from,
        address to,
        uint256 tokenId,
        address collectionAddress
    );

    event ERC20Transferred(
        address from,
        address to,
        uint256 amount,
        address collectionAddress
    );

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

        vm.label(alice, "alice");
        vm.label(bob, "bob");
        vm.label(USDC, "USDC");
        vm.label(USDT, "USDT");

        dealERC721(ONCHAIN_MONKEY, alice, 1);
        deal(USDC, bob, INITIAL_ERC20_BALANCE);
        deal(USDT, bob, INITIAL_ERC20_BALANCE);

        testOrderBook = new Orderbook();
        testOrderBook.updateCurrencyStatus(USDC, true);
        testOrderBook.updateCurrencyStatus(USDT, true);
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

    function testFufillMakerAskOrder() public {
        // create a maker order
        uint256[] memory itemIds = new uint256[](1);
        itemIds[0] = 1;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 1;

        // Alice list an NFT Ask (sell) order for 100 USDC
        makerOrder = OrderStructs.Maker({
            orderType: OrderType.Ask,
            globalNonce: 1,
            subsetNonce: 1,
            orderNonce: 1,
            strategyId: 0,
            collectionType: CollectionType.ERC721,
            collection: ONCHAIN_MONKEY,
            currency: USDC,
            price: 100 * 10 ** 6, // 100U
            signer: alice,
            startTime: 1672444800, //20230101
            endTime: 1703980800, // 20231231
            itemIds: itemIds,
            amounts: amounts
        });

        OrderStructs.Taker memory takerOrder = OrderStructs.Taker({
            recipient: bob,
            additionalParameters: "0x0"
        });

        bytes memory makerSignature = signOrder(
            alicePrivateKey,
            makerOrder.hash()
        );

        //Maker sure Alice own the NFT
        assertEq(IERC721(ONCHAIN_MONKEY).ownerOf(1), alice);

        // Alice approve the target nft to the orderbook
        vm.startPrank(alice);
        IERC721(ONCHAIN_MONKEY).approve(address(testOrderBook), 1);
        vm.stopPrank();

        // Bob is going to fulfill the order
        vm.startPrank(bob);

        vm.expectEmit(false, false, false, false);
        emit ERC721Transferred(alice, bob, 1, ONCHAIN_MONKEY);

        vm.expectEmit(false, false, false, false);
        emit ERC20Transferred(bob, alice, 100 * 10 ** 6, USDC);

        // Bob approve the USDC allowance to the orderbook for purchasing
        IERC20(USDC).approve(address(testOrderBook), 100 * 10 ** 6);
        testOrderBook.fulfillMakerOrder(takerOrder, makerOrder, makerSignature);
        vm.stopPrank();

        // The order should be invalidated
        assertEq(
            testOrderBook.userOrderNonce(alice, makerOrder.orderNonce),
            MAGIC_VALUE_ORDER_NONCE_EXECUTED,
            "maker order should be fulfilled"
        );

        assertEq(IERC721(ONCHAIN_MONKEY).ownerOf(1), bob);
        assertEq(IERC20(USDC).balanceOf(bob), 50_000 * 10 ** 6 - 100 * 10 ** 6);
        assertEq(IERC20(USDC).balanceOf(alice), 100 * 10 ** 6);
    }

    function testFulfillMakerBidOrder() public {
        // create a maker order
        uint256[] memory itemIds = new uint256[](1);
        itemIds[0] = 1;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 1;

        // Bob list a bid (buy) order
        makerOrder = OrderStructs.Maker({
            orderType: OrderType.Bid,
            globalNonce: 1,
            subsetNonce: 1,
            orderNonce: 1,
            strategyId: 0,
            collectionType: CollectionType.ERC721,
            collection: ONCHAIN_MONKEY,
            currency: USDT,
            price: 200 * 10 ** 6, // 200U
            signer: bob,
            startTime: 1672444800, //20230101
            endTime: 1703980800, // 20231231
            itemIds: itemIds,
            amounts: amounts
        });

        OrderStructs.Taker memory takerOrder = OrderStructs.Taker({
            recipient: alice,
            additionalParameters: "0x0"
        });

        bytes memory makerSignature = signOrder(
            bobPrivateKey,
            makerOrder.hash()
        );

        //Maker sure Alice own the NFT
        assertEq(IERC721(ONCHAIN_MONKEY).ownerOf(1), alice);

        // Alice approve the target nft to the orderbook
        vm.startPrank(alice);
        IERC721(ONCHAIN_MONKEY).approve(address(testOrderBook), 1);
        vm.stopPrank();

        vm.startPrank(bob);
        // USDT does not comply with ERC20 standard, so we need to use low lv call
        (bool result, ) = address(USDT).call(
            abi.encodeWithSignature(
                "approve(address,uint256)",
                address(testOrderBook),
                300 * 10 ** 6
            )
        );

        require(result, "approve failed");

        vm.stopPrank();

        vm.startPrank(alice);
        vm.expectEmit(false, false, false, false);
        emit ERC721Transferred(alice, bob, 1, ONCHAIN_MONKEY);

        vm.expectEmit(false, false, false, false);
        emit ERC20Transferred(bob, alice, 200 * 10 ** 6, USDT);
        testOrderBook.fulfillMakerOrder(takerOrder, makerOrder, makerSignature);
        vm.stopPrank();

        assertEq(IERC721(ONCHAIN_MONKEY).ownerOf(1), bob);
        assertEq(IERC20(USDT).balanceOf(bob), 50_000 * 10 ** 6 - 200 * 10 ** 6);
        assertEq(IERC20(USDT).balanceOf(alice), 200 * 10 ** 6);
    }

    function testUsedOrderNoceShouldFailed() public {}
}
