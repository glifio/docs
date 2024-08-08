// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.20;

import {IERC20} from "./IERC20.sol";

interface IPool {
    /*//////////////////////////////////////////////////////////////
                      4626 DEPOSIT/WITHDRAWAL LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @dev provides native FIL liquidity to the pool
    function deposit(address receiver) external payable returns (uint256 shares);
    /// @dev provides wFIL liquidity to the pool
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);
    /// @dev specifies an amount of iFIL tokens to receive
    function mint(uint256 shares, address receiver) external returns (uint256 assets);

    /// @dev withdraws wFIL from the pool by specifying an amount of wFIL to receive
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);
    /// @dev withdraws native FIL from the pool by specifying an amount of FIL to receive
    function withdrawF(uint256 assets, address receiver, address owner) external returns (uint256 shares);
    /// @dev withdraws wFIL from the pool by specifying an amount of iFIL to burn
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);
    /// @dev withdraws native FIL from the pool by specifying an amount of iFIL to burn
    function redeemF(uint256 shares, address receiver, address owner) external returns (uint256 assets);

    /*//////////////////////////////////////////////////////////////
                    DEPRECATED DEPOSIT/WITHDRAWAL LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @dev DEPRECATED: withdraws wFIL from the pool by specifying an amount of wFIL to receive
    function withdraw(uint256 assets, address receiver, address owner, uint256) external returns (uint256 shares);
    /// @dev DEPRECATED: withdraws native FIL from the pool by specifying an amount of wFIL to receive
    function withdrawF(uint256 assets, address receiver, address owner, uint256) external returns (uint256 shares);
    /// @dev DEPRECATED: withdraws wFIL from the pool by specifying an amount of iFIL to burn
    function redeem(uint256 shares, address receiver, address owner, uint256) external returns (uint256 assets);
    /// @dev DEPRECATED: withdraws native FIL from the pool by specifying an amount of iFIL to burn
    function redeemF(uint256 shares, address receiver, address owner, uint256) external returns (uint256 assets);

    /*//////////////////////////////////////////////////////////////
                            ACCOUNTING LOGIC
    //////////////////////////////////////////////////////////////*/

    function totalAssets() external view returns (uint256);

    function convertToShares(uint256 assets) external view returns (uint256);

    function convertToAssets(uint256 shares) external view returns (uint256);

    function previewDeposit(uint256 assets) external view returns (uint256);

    function previewWithdraw(uint256 assets) external view returns (uint256);

    function previewRedeem(uint256 shares) external view returns (uint256);

    function previewMint(uint256 shares) external view returns (uint256);

    function updateAccounting() external;

    /*//////////////////////////////////////////////////////////////
                     DEPOSIT/WITHDRAWAL LIMIT LOGIC
    //////////////////////////////////////////////////////////////*/

    function maxDeposit(address) external view returns (uint256);

    function maxMint(address) external view returns (uint256);

    function maxWithdraw(address owner) external view returns (uint256);

    function maxRedeem(address owner) external view returns (uint256);
}
