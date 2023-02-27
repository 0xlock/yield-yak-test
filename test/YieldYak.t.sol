// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IYieldYakRouter {
    struct Trade {
        uint256 amountIn;
        uint256 amountOut;
        address[] path;
        address[] adapters;
    }

    struct FormattedOffer {
        uint[] amounts;
        address[] adapters;
        address[] path;
    }

    function findBestPath(
        uint256 _amountIn, 
        address _tokenIn, 
        address _tokenOut, 
        uint _maxSteps
    ) external view returns (FormattedOffer memory);

    function swapNoSplit(
        Trade calldata _trade,
        address _to,
        uint256 _fee
    ) external;
}

contract YieldYakTest is Test {
    address public whale = 0x9f8c163cBA728e99993ABe7495F06c0A3c8Ac8b9;
    address public usdc = 0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E;
    address public wavax = 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7;
    uint256 public amountIn = 4096461665;

    IYieldYakRouter public router = IYieldYakRouter(0xC4729E56b831d74bBc18797e0e17A295fA77488c);
    IYieldYakRouter.FormattedOffer internal offer;

    function setUp() public {
        console.log("before query");
        offer = router.findBestPath(amountIn, usdc, wavax, 3);
        console.log("after query", offer.path.length);
        for (uint i; i < offer.path.length; i++) {
            console.log(offer.path[i]);
        }
    }

    function testFail() public {
        vm.prank(whale);
        IERC20(usdc).approve(address(router), amountIn);

        IYieldYakRouter.Trade memory trade = IYieldYakRouter.Trade({
            amountIn: amountIn,
            amountOut: 0,
            path: offer.path,
            adapters: offer.adapters
        });

        vm.prank(whale);
        vm.expectRevert(bytes("Joe: K"));
        router.swapNoSplit(trade, whale, 0);
    }

    function testSuccess() public {
        vm.prank(whale);
        IERC20(usdc).approve(address(router), amountIn);

        IYieldYakRouter.Trade memory trade = IYieldYakRouter.Trade({
            amountIn: amountIn,
            amountOut: 0,
            path: offer.path,
            adapters: offer.adapters
        });

        vm.prank(whale);
        router.swapNoSplit(trade, whale, 0);
    }
}
