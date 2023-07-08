// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// LooksRare unopinionated libraries
import {CurrencyManager} from "./CurrencyManager.sol";

// Interfaces
import {IStrategy} from "./interfaces/IStrategy.sol";
import {IStrategyManager} from "./interfaces/IStrategyManager.sol";

/**
 * @title StrategyManager
 * @notice This contract handles the addition and the update of execution strategies.
 * @author LooksRare protocol team (👀,💎)
 */
contract StrategyManager is IStrategyManager, CurrencyManager {
    /**
     * @notice This variable keeps the count of how many strategies exist.
     *         It includes strategies that have been removed.
     */
    uint256 private _countStrategies = 1;

    /**
     * @notice This returns the strategy information for a strategy id.
     */
    mapping(uint256 => Strategy) public strategyInfo;

    /**
     * @notice Constructor
     * @param _owner Owner address
     */
    constructor(address _owner) CurrencyManager(_owner) {
        // Indexes start from 1.
        strategyInfo[0] = Strategy({
            isActive: true,
            selector: bytes4(0),
            isMakerBid: false,
            implementation: address(0)
        });

        emit NewStrategy(0, bytes4(0), false, address(0));
    }

    /**
     * @notice This function allows the owner to add a new execution strategy to the protocol.
     * @param selector Function selector for the strategy
     * @param isMakerBid Whether the function selector is for maker bid
     * @param implementation Implementation address
     * @dev Strategies have an id that is incremental.
     *      Only callable by owner.
     */
    function addStrategy(
        bytes4 selector,
        bool isMakerBid,
        address implementation
    ) external onlyOwner {
        if (selector == bytes4(0)) {
            revert StrategyHasNoSelector();
        }

        if (!IStrategy(implementation).isOrderBookStrategy()) {
            revert NotAStrategy();
        }

        strategyInfo[_countStrategies] = Strategy({
            isActive: true,
            selector: selector,
            isMakerBid: isMakerBid,
            implementation: implementation
        });

        emit NewStrategy(
            _countStrategies++,
            selector,
            isMakerBid,
            implementation
        );
    }

    /**
     * @notice This function allows the owner to update parameters for an existing execution strategy.
     * @param strategyId Strategy id
     * @param isActive Whether the strategy must be active
     * @dev Only callable by owner.
     */
    function updateStrategy(
        uint256 strategyId,
        bool isActive
    ) external onlyOwner {
        if (strategyId >= _countStrategies) {
            revert StrategyNotUsed();
        }

        strategyInfo[strategyId].isActive = isActive;

        emit StrategyUpdated(strategyId, isActive);
    }
}
