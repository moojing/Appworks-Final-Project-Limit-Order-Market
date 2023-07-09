// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface ITransferManager {
    /**
     * @notice It is emitted when a ERC721 token is transferred.
     * @param from From address
     * @param to To address
     * @param tokenId Token id
     * @param collectionAddress Contract address
     */
    event ERC721Transferred(
        address from,
        address to,
        uint256 tokenId,
        address collectionAddress
    );

    /**
     * @notice It is emitted when a ERC20 token is transferred.
     * @param from From address
     * @param to To address
     * @param amount Token amount
     * @param collectionAddress Contract address
     */
    event ERC20Transferred(
        address from,
        address to,
        uint256 amount,
        address collectionAddress
    );

    /**
     * @notice This function allows the owner to execute a transfer of an ERC721 token.
     * @param from From address
     * @param to To address
     * @param tokenId Token id
     * @param collectionAddress Contract address
     * @dev Only callable by owner.
     */
    function executeTransferERC721(
        address from,
        address to,
        uint256 tokenId,
        address collectionAddress
    ) external;
}
