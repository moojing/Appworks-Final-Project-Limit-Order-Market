// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
 * @notice OrderType is used in OrderStructs.Maker's quoteType to determine whether the maker order is a bid or an ask.
 */
enum OrderType {
    Bid,
    Ask
}
