// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {Tradercat} from "../src/Tradercat.sol";

contract TradercatTest is Test {
    Tradercat public tradercat;
    address public owner;
    address public user1;

    function setUp() public {
        owner = address(this);
        user1 = address(0x1);
        
        tradercat = new Tradercat(owner);
    }

    function test_Deployment() public view {
        assertEq(tradercat.name(), "Tradercat");
        assertEq(tradercat.symbol(), "TDC");
        assertEq(tradercat.owner(), owner);
    }

    function test_MintToken() public {
        tradercat.safeMint(user1, "1.json");
        
        assertEq(tradercat.ownerOf(0), user1);
        assertEq(tradercat.balanceOf(user1), 1);
    }
}