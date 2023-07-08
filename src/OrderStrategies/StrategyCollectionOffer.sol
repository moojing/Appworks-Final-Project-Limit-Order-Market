// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Libraries
import {OrderStructs} from "../lib/OrderStructs.sol";

// Enums
import {OrderType} from "../enums/OrderType.sol";
import {CollectionType} from "../enums/CollectionType.sol";

// Shared errors
import {OrderInvalid, FunctionSelectorInvalid, OrderTypeInvalid} from "../errors/GlobalErrors.sol";

/**
 * @title StrategyCollectionOffer
 * @notice This contract offers execution strategies for users to create maker bid offers for items in a collection.
 *         There are two available functions:
 *         1. executeCollectionStrategyWithTakerAsk --> it applies to all itemIds in a collection
 *         2. executeCollectionStrategyWithTakerAskWithProof --> it allows adding merkle proof criteria.
 * @notice The bidder can only bid on 1 item id at a time.
 *         1. If ERC721, the amount must be 1.
 *         2. If ERC1155, the amount can be greater than 1.
 * @dev Use cases can include trait-based offers or rarity score offers.
 *
 */
contract StrategyCollectionOffer {
    /**
     * @notice This function validates the order under the context of the chosen strategy and
     *         returns the fulfillable items/amounts/price/nonce invalidation status.
     *         This strategy executes a collection offer against a taker ask order without the need of merkle proofs.
     * @param takerAsk Taker ask struct (taker ask-specific parameters for the execution)
     * @param makerBid Maker bid struct (maker bid-specific parameters for the execution)
     */
    function executeCollectionStrategyWithTakerAsk(
        OrderStructs.Taker calldata takerAsk,
        OrderStructs.Maker calldata makerBid
    )
        external
        pure
        returns (
            uint256 price,
            uint256[] memory itemIds,
            uint256[] calldata amounts,
            bool isNonceInvalidated
        )
    {
        price = makerBid.price;
        amounts = makerBid.amounts;

        // A collection order can only be executable for 1 itemId but quantity to fill can vary
        if (amounts.length != 1) {
            revert OrderInvalid();
        }

        uint256 offeredItemId = abi.decode(
            takerAsk.additionalParameters,
            (uint256)
        );
        itemIds = new uint256[](1);
        itemIds[0] = offeredItemId;
        isNonceInvalidated = true;
    }

    function isMakerOrderValid(
        OrderStructs.Maker calldata makerOrder,
        bytes4 functionSelector
    ) external pure returns (bool isValid, bytes4 errorSelector) {
        if (
            functionSelector !=
            StrategyCollectionOffer
                .executeCollectionStrategyWithTakerAsk
                .selector
        ) {
            return (isValid, FunctionSelectorInvalid.selector);
        }

        if (makerOrder.orderType != OrderType.Bid) {
            return (isValid, OrderTypeInvalid.selector);
        }

        if (makerOrder.amounts.length != 1) {
            return (isValid, OrderInvalid.selector);
        }

        // Validate the amount of the maker order
        uint256 amount = makerOrder.amounts[0];
        if (
            amount == 0 ||
            (amount != 1 && makerOrder.collectionType == CollectionType.ERC721)
        ) {
            return (isValid, OrderInvalid.selector);
        }

        isValid = true;
    }
}
