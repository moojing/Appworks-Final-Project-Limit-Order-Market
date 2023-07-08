// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "forge-std/console.sol";
import {OrderStructs} from "./OrderStructs.sol";
import {OutsideOfTimeRange, OrderInvalid} from "../errors/GlobalErrors.sol";

library OrderVerifier {
    /**
     * @notice This is the type hash constant used to compute the maker order hash.
     */

    bytes32 internal constant _MAKER_TYPEHASH =
        keccak256(
            abi.encodePacked(
                "Maker("
                "uint8 orderType,"
                "uint256 globalNonce,"
                "uint256 subsetNonce,"
                "uint256 orderNonce,"
                "uint8 collectionType,"
                "address collection,"
                "address currency,"
                "address signer,"
                "uint256 startTime,"
                "uint256 endTime,"
                "uint256 price,"
                "uint256[] itemIds,"
                "uint256[] amounts"
                ")"
            )
        );

    /**
     * @notice This function is used to compute the order hash for a maker struct.
     * @param maker Maker order struct
     * @return makerHash Hash of the maker struct
     */
    function hash(
        OrderStructs.Maker memory maker
    ) internal view returns (bytes32) {
        return
            keccak256(
                bytes.concat(
                    abi.encode(
                        _MAKER_TYPEHASH,
                        maker.orderType,
                        maker.globalNonce,
                        maker.subsetNonce,
                        maker.orderNonce,
                        maker.collectionType,
                        maker.collection,
                        maker.currency
                    ),
                    abi.encode(
                        maker.signer,
                        maker.startTime,
                        maker.endTime,
                        maker.price,
                        keccak256(abi.encodePacked(maker.itemIds)),
                        keccak256(abi.encodePacked(maker.amounts))
                    )
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
        bytes32 orderHash,
        address signer,
        bytes calldata signature
    ) internal view returns (bool) {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);
        return ecrecover(orderHash, v, r, s) == signer;
    }

    /**
     * @notice This function is internal and is used to verify the validity of an order
     *         in the context of the current block timestamps.
     * @param startTime Start timestamp
     * @param endTime End timestamp
     */
    function _verifyOrderTimestampValidity(
        OrderStructs.Maker memory maker,
        uint256 startTime,
        uint256 endTime
    ) internal view {
        if (startTime > block.timestamp || endTime < block.timestamp)
            revert OutsideOfTimeRange();
    }

    /**
     * @notice This function is internal and is used to validate the parameters for a standard sale strategy
     *         when the standard transaction is initiated by a taker bid.
     * @param amounts Array of amounts
     * @param itemIds Array of item ids
     */

    function _verifyItemIdsAndAmountsEqualLengthsAndValidAmounts(
        OrderStructs.Maker memory maker,
        uint256[] calldata amounts,
        uint256[] calldata itemIds
    ) internal pure {
        uint256 amountsLength = amounts.length;
        uint256 itemIdsLength = itemIds.length;

        if (amountsLength == 0 || amountsLength != itemIdsLength) {
            revert OrderInvalid();
        }

        for (uint256 i = 0; i < amountsLength; i++) {
            if (amounts[i] == 0) {
                revert OrderInvalid();
            }
        }
    }
}
