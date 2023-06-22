pragma solidity ^0.8.17;

import {stdStorage, StdStorage, Test} from "forge-std/Test.sol";
//import {console} from "forge-std/console.sol";
import "../../contracts/interfaces/ICurveCryptoSwap.sol";
import "../../contracts/interfaces/IWETH.sol";
import "../../contracts/interfaces/IUniswapV2Router02.sol";
import "./utils/Utils.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../../contracts/DirectUBQFarmer.sol";

contract ForkTest is Test {
    // the identifiers of the forks
    uint256 mainnetFork;
    uint256 goerli;
    Utils internal utils;
    address payable[] internal users;
    address payable internal owner;
    address payable internal dev;

    //Access variables from .env file via vm.envString("varname")
    //Replace ALCHEMY_KEY by your alchemy key or Etherscan key, change RPC url if need
    //inside your .env file e.g:
    //MAINNET_RPC_URL = 'https://eth-mainnet.g.alchemy.com//v2/ALCHEMY_KEY'
    string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");
    string GOERLI_RPC_URL = vm.envString("GOERLI_RPC_URL");
    ICurveCryptoSwap curveSwap;
    IUniswapV2Router02 uniswapRouter;
    IERC20 usdt;
    IWETH weth;
    DirectUBQFarmer ubqFarmer;

    // create two _different_ forks during setup
    function setUp() public payable {
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        //goerli = vm.createFork(GOERLI_RPC_URL);
        vm.selectFork(mainnetFork);
        curveSwap = ICurveCryptoSwap(0xD51a44d3FaE010294C616388b506AcdA1bfAAE46);
        usdt = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
        weth = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        uniswapRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        ubqFarmer = new DirectUBQFarmer();
        utils = new Utils();
        users = utils.createUsers(2);
        owner = users[0];
        vm.label(owner, "Owner");
        dev = users[1];
        vm.label(dev, "Developer");
        //vm.prank(dev);
        console.log('set up 1st phase');
        console.log(curveSwap.token());
        console.log(dev.balance);
        vm.prank(dev);
        weth.deposit{value: 1 ether}();
        vm.prank(dev);
        owner.send(1 ether);
        vm.prank(dev);
        owner.call{value: 1 ether}("");
        console.log('set up 2nd phase');
        console.log(address(this));
        console.log(dev.balance);
        vm.prank(dev);
        weth.approve(address(curveSwap), 1 ether);
        vm.prank(dev);
        weth.approve(address(uniswapRouter), 1 ether);
        console.log('set up 3rd phase');
        console.log(weth.balanceOf(dev));
        vm.prank(dev);
        address[] memory addressPath = new address[](2);
        addressPath[0] = address(weth);
        addressPath[1] = address(usdt);
        uniswapRouter.swapExactETHForTokens{value: 1 ether}(0, addressPath, dev, block.timestamp + 1 days);
        console.log('set up 4th phase');
        console.log(usdt.balanceOf(dev));
        //Exchange at Curve. At the moment, this will fail
//        vm.prank(dev);
//        curveSwap.exchange{value: 1 ether}(2, 0, 1 ether, 0, true);
//        vm.prank(dev);
//        uint256 usdtAmount = curveSwap.exchange(2, 0, 1 ether, 0, false);

        vm.prank(dev);
        usdt.approve(address(ubqFarmer), usdt.balanceOf(dev));
        console.log('FINISH');
        //ubqFarmer.

    }



    // set `block.timestamp` of a fork
    function testCanSetForkBlockTimestamp() public {
        vm.selectFork(mainnetFork);
        vm.rollFork(1_337_000);

        assertEq(block.number, 1_337_000);
    }
}
