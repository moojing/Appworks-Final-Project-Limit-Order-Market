// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import {OwnableTwoSteps} from "@looksrare/contracts/OwnableTwoSteps.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {ITransferManager} from "./interfaces/ITransferManager.sol";
import {CurrencyManager} from "./CurrencyManager.sol";
import {OrderStructs} from "./lib/OrderStructs.sol";
import {CollectionType} from "./enums/CollectionType.sol";
import {AmountInvalid} from "./errors/GlobalErrors.sol";

contract TransferManager is ITransferManager, ReentrancyGuard {
    constructor() {}

    function transferOrderNFT(
        address _from,
        address _to,
        uint256[] memory itemIds,
        uint256[] memory amounts,
        CollectionType collectionType,
        address _contractAddress
    ) internal {
        if (collectionType == CollectionType.ERC721) {
            // transfer amount must be 1
            for (uint256 i; i < itemIds.length; ) {
                if (amounts[i] != 1) {
                    revert AmountInvalid();
                }

                executeTransferERC721(_from, _to, itemIds[i], _contractAddress);

                unchecked {
                    ++i;
                }
            }
        } else {
            // @todo support erc 1155
            revert("Not supported");
        }
    }

    function transferOrderERC20(
        address _from,
        address _to,
        uint _amount,
        address _tokenAddress
    ) internal {
        // USDT does not comply with ERC20 standard, so we need to use low lv call
        uint toBalanceBefore = IERC20(_tokenAddress).balanceOf(_to);

        (bool status, ) = _tokenAddress.call(
            abi.encodeCall(IERC20.transferFrom, (_from, _to, _amount))
        );

        uint toBalanceAfter = IERC20(_tokenAddress).balanceOf(_to);

        // check the result by comparing the balance, bceause of the bloody USDT.
        require(
            toBalanceAfter - toBalanceBefore == _amount,
            "Transfer ERC20 failed"
        );
        emit ERC20Transferred(_from, _to, _amount, _tokenAddress);
    }

    function executeTransferERC721(
        address _from,
        address _to,
        uint256 _tokenId,
        address _contractAddress
    ) public nonReentrant {
        IERC721(_contractAddress).transferFrom(_from, _to, _tokenId);
        emit ERC721Transferred(_from, _to, _tokenId, _contractAddress);
    }
}
