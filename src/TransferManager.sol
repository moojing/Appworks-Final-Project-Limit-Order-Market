// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import {OwnableTwoSteps} from "@looksrare/contracts/OwnableTwoSteps.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {ITransferManager} from "./interfaces/ITransferManager.sol";
import {CurrencyManager} from "./CurrencyManager.sol";

contract TransferManager is ITransferManager, ReentrancyGuard {
    constructor() {}

    function executeTransferERC721(
        address _from,
        address _to,
        uint256 _tokenId,
        address _contractAddress
    ) external nonReentrant {
        IERC721(_contractAddress).transferFrom(_from, _to, _tokenId);
    }
}
