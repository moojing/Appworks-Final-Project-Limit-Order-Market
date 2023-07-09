/**
 * @notice It is returned if the amount is invalid.
 *         For ERC721, any number that is not 1. For ERC1155, if amount is 0.
 */
error AmountInvalid();

/**
 * @notice It's returned if the chain id is invalid.
 */
error ChainIdInvalid(uint256 chainId);
/**
 * @notice It is returned if there is either a mismatch or an error in the length of the array(s).
 */
error LengthsInvalid();

/**
 * @notice It is returned if the order is permanently invalid.
 *         There may be an issue with the order formatting.
 */
error OrderInvalid();

/**
 * @notice The function selector is invalid for this strategy implementation.
 */
error FunctionSelectorInvalid();

/**
 * @notice It is returned if the maker quote type is invalid.
 */
error OrderTypeInvalid();

error NoncesInvalid();

/**
 * @notice The order is not valid for the current time.
 */
error OutsideOfTimeRange();
