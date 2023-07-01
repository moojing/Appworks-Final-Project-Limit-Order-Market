// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import {OrderType} from "../enums/OrderType.sol";
import {CollectionType} from "../enums/CollectionType.sol";

library OrderStructs {
    /**
     * 1. Maker struct
     */

    /**
     * @notice Maker is the struct for a maker order.
     * @param orderType Order type (i.e. 0 = BID, 1 = ASK)
     * @param isFulfilled Whether the order has been fulfilled
     * @param globalNonce Global user order nonce for maker orders
     * @param subsetNonce Subset nonce (shared across bid/ask maker orders)
     * @param orderNonce Order nonce (it can be shared across bid/ask maker orders)
     // param strategyId Strategy id
     * @param collectionType Collection type (i.e. 0 = ERC721, 1 = ERC1155)
     * @param collection Collection address
     * @param currency Currency address (@dev address(0) = ETH)
     * @param signer Signer address
     * @param startTime Start timestamp
     * @param endTime End timestamp
     * @param price Minimum price for maker ask, maximum price for maker bid
     * @param itemIds Array of itemIds
     * @param amounts Array of amounts
     // param additionalParameters Extra data specific for the order
     */
    struct Maker {
        OrderType orderType;
        bool isFulfilled;
        uint256 globalNonce;
        uint256 subsetNonce;
        uint256 orderNonce;
        // uint256 strategyId;
        CollectionType collectionType;
        address collection;
        address currency;
        address signer;
        uint256 startTime;
        uint256 endTime;
        uint256 price;
        uint256[] itemIds;
        uint256[] amounts;
        // bytes additionalParameters;
    }
}
