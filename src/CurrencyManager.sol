// SPDX License Identifier: MIT
import {OwnableTwoSteps} from "@looksrare/contracts/OwnableTwoSteps.sol";
import {ICurrencyManager} from "./interfaces/ICurrencyManager.sol";

contract CurrencyManager is ICurrencyManager {
    /**
     * @notice It checks whether the currency is allowed for transacting.
     */
    mapping(address => bool) public isCurrencyAllowed;

    /**
     * @notice Constructor
     * @param _owner Owner address
     */
    constructor(address _owner) {}

    /**
     * @notice This function allows the owner to update the status of a currency.
     * @param currency Currency address (address(0) for ETH)
     * @param isAllowed Whether the currency should be allowed for trading
     * @dev Only callable by owner.
     */

    // @todo only owner
    function updateCurrencyStatus(address currency, bool isAllowed) external {
        isCurrencyAllowed[currency] = isAllowed;
        emit CurrencyStatusUpdated(currency, isAllowed);
    }
}
