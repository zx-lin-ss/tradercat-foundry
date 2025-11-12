// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {Tradercat} from "../src/Tradercat.sol";

contract TradercatTest is Test {
    Tradercat tradercat;
    address owner;
    address user1;
    address user2;

    function setUp() public {
        owner = address(this);
        user1 = address(0x1);
        user2 = address(0x2);

        tradercat = new Tradercat(owner);
    }

    // ============ Deployment Tests ============

    function testNameIsTradercat() public view {
        assertEq(tradercat.name(), "Tradercat");
    }

    function testSymbolIsTDC() public view {
        assertEq(tradercat.symbol(), "TDC");
    }

    function testOwnerIsSetCorrectly() public view {
        assertEq(tradercat.owner(), owner);
    }

    // ============ Minting Tests ============

    function testMintingNFTs() public {
        tradercat.safeMint(user1, "tradercat1.json");

        assertEq(tradercat.ownerOf(0), user1);
        assertEq(tradercat.balanceOf(user1), 1);
    }

    function testTokenURI() public {
        tradercat.safeMint(user1, "tradercat1.json");

        string memory expectedURI =
            "https://raw.githubusercontent.com/zx-lin-ss/trader-cat-nft/refs/heads/main/trader_cat_NFT/metadata/tradercat1.json";
        assertEq(tradercat.tokenURI(0), expectedURI);
    }

    function testMultipleMints() public {
        tradercat.safeMint(user1, "tradercat1.json");
        tradercat.safeMint(user2, "tradercat2.json");
        tradercat.safeMint(user1, "tradercat3.json");

        assertEq(tradercat.ownerOf(0), user1);
        assertEq(tradercat.ownerOf(1), user2);
        assertEq(tradercat.ownerOf(2), user1);
        assertEq(tradercat.balanceOf(user1), 2);
    }

    function testMintReturnsTokenId() public {
        uint256 tokenId = tradercat.safeMint(user1, "tradercat1.json");
        assertEq(tokenId, 0);

        tokenId = tradercat.safeMint(user2, "tradercat2.json");
        assertEq(tokenId, 1);
    }

    // ============ Access Control Tests ============

    function testNonOwnerCannotMint() public {
        vm.prank(user1);
        vm.expectRevert();
        tradercat.safeMint(user2, "tradercat1.json");
    }

    function testOwnerCanTransferOwnership() public {
        tradercat.transferOwnership(user1);
        assertEq(tradercat.owner(), user1);
    }

    function testNewOwnerCanMint() public {
        tradercat.transferOwnership(user1);

        vm.prank(user1);
        tradercat.safeMint(user2, "tradercat1.json");

        assertEq(tradercat.ownerOf(0), user2);
    }

    function testOldOwnerCannotMintAfterTransfer() public {
        tradercat.transferOwnership(user1);

        vm.expectRevert();
        tradercat.safeMint(user2, "tradercat1.json");
    }

    // ============ Transfer Tests ============

    function testTransferNFT() public {
        tradercat.safeMint(user1, "tradercat1.json");

        vm.prank(user1);
        tradercat.transferFrom(user1, user2, 0);

        assertEq(tradercat.ownerOf(0), user2);
        assertEq(tradercat.balanceOf(user1), 0);
        assertEq(tradercat.balanceOf(user2), 1);
    }

    function testUnauthorizedTransfer() public {
        tradercat.safeMint(user1, "tradercat1.json");

        vm.prank(user2);
        vm.expectRevert();
        tradercat.transferFrom(user1, user2, 0);
    }

    function testSafeTransferFrom() public {
        tradercat.safeMint(user1, "tradercat1.json");

        vm.prank(user1);
        tradercat.safeTransferFrom(user1, user2, 0);

        assertEq(tradercat.ownerOf(0), user2);
    }

    // ============ Token URI Tests ============

    function testTokenURIWithDifferentFiles() public {
        tradercat.safeMint(user1, "cat_legendary.json");

        string memory expectedURI =
            "https://raw.githubusercontent.com/zx-lin-ss/trader-cat-nft/refs/heads/main/trader_cat_NFT/metadata/cat_legendary.json";
        assertEq(tradercat.tokenURI(0), expectedURI);
    }

    function testTokenURIRevertsForNonexistentToken() public {
        vm.expectRevert();
        tradercat.tokenURI(999);
    }

    // ============ Event Tests ============

    function testMintEmitsTransferEvent() public {
        vm.expectEmit(true, true, true, false);
        emit IERC721.Transfer(address(0), user1, 0);

        tradercat.safeMint(user1, "tradercat1.json");
    }

    // ============ Console.log Example ============
}

// Import IERC721 for event testing
import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
