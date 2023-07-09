# What is the repo for ?

It's the final project for [Appworks Blockchain Program #2](https://school.appworks.tw/blockchain-program-2/).

## On chain NFT Market place

This project is a marketplace that supports NFTs (ERC721/ERC1155). Users can list NFTs for trading on this platform. It's developed by referencing the source code of LooksRare, but with some functionalities simplified or modified (self-implemented) for the purpose of learning.

## Flow Chart
<img width="868" alt="Screenshot 2023-07-09 at 11 45 01 PM" src="https://github.com/moojing/Appworks-Final-Project-NFT-Order-Market/assets/11360957/bc039d7f-2801-4bca-bd17-942df08fa566">




### Backend (smart contract)

- [x] User can sign an ask/bid order about selling/buying a NFT.
- [x] User can fulfill the tx that other users have signed.
- [x] User can buy a token order with erc20 token.
- [x] USer can cancel an order by revoking the order nonce.
- [ ] User can buy a token order with native token (not implemented yet).
- [ ] User can sign an bundle order about selling a token and a nft at the same time (not implemented yet).
- [ ] ERC1155 Supported is not implement yet (not implemented yet).

### Frontend ( not implemented at the moment )

- [ ] User can see all the order on the page
- [ ] User can filter order by token
- [ ] User can search the order by its name.

## Development

- copy the file `.env.example`, and rename it to `.env`.
- set your testing private key (if your need to deploy contract on testnet) in the `.env` with `SCRIPT_PRIVATE_KEY`.
- set your `NET_RPC_URL` in the .env depends on what network you are going to use.
- execute the command `forge install` in your command line.

## Testing

- `forge test --mc OrderFulfillTest` to run the test.
- `forge test --mc OrderFulfillTest --mt testCancelOrderNonce` to run a specific test case.

## Usage

### 1. Create an order

``` solidity
  import {OrderStructs} from "../src/lib/OrderStructs.sol";
  ...
  // create a bid order (Bob bid a NFT for 200USD)
        uint256[] memory itemIds = new uint256[](1);
        itemIds[0] = 1;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 1;

        makerOrder = OrderStructs.Maker({
            orderType: OrderType.Bid,
            globalNonce: 1,
            subsetNonce: 1,
            orderNonce: 1,
            strategyId: 0,
            collectionType: CollectionType.ERC721,
            collection: ONCHAIN_MONKEY,
            currency: USDC,
            price: 200 * 10 ** 6, // 200U
            signer: bob,
            startTime: 1672444800, //20230101
            endTime: 1703980800, // 20231231
            itemIds: itemIds,
            amounts: amounts
        });

   // create a ask order (Alice sell a NFT for 200USD)
        uint256[] memory itemIds = new uint256[](1);
        itemIds[0] = 1;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 1;

        makerOrder = OrderStructs.Maker({
            orderType: OrderType.Ask,
            globalNonce: 1,
            subsetNonce: 1,
            orderNonce: 1,
            strategyId: 0,
            collectionType: CollectionType.ERC721,
            collection: ONCHAIN_MONKEY,
            currency: USDC,
            price: 200 * 10 ** 6, // 200U
            signer: alice,
            startTime: 1672444800, //20230101
            endTime: 1703980800, // 20231231
            itemIds: itemIds,
            amounts: amounts
        })
```

### 2. Sign the order

- The order need to be signed off-chain by ERC-721(e.g. use with metamask).

### 3. fulfill the order with a taker order

- You can fulfill the order by calling `fulfillMakerOrder`.

``` solidity

OrderStructs.Taker memory takerOrder = OrderStructs.Taker({
    recipient: alice,
    additionalParameters: "0x0"
});

testOrderBook.fulfillMakerOrder(takerOrder, makerOrder, makerSignature);
```

### 4. Cancel an order

You can cancel an order by revoke an order nonce.

``` solidity
uint256[] memory nonces = new uint256[](1);
nonces[0] = 1; // nonce
testOrderBook.cancelOrderNonces(nonces);
```

## Resources for development

- <https://learnblockchain.cn/docs/foundry/i18n/zh/cheatcodes/expect-revert.html>
- <https://github.com/foundry-rs/foundry/blob/master/forge/README.md>
- <https://forum.openzeppelin.com/t/can-not-call-the-function-approve-of-the-usdt-contract/2130/2>
- <https://etherscan.io/address/0xdac17f958d2ee523a2206206994597c13d831ec7#code>
- <https://github.com/LooksRare/contracts-exchange-v2/blob/9b91be619dca8ea403abc9787bac122f1846160c/contracts/LooksRareProtocol.sol>
- <https://news.cnyes.com/news/id/5213973>
