// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "forge-std/Test.sol";

import "../src/MyToken721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyTokenTest is Test {
    MyToken721 internal token;

    address internal owner = address(0xABCD);
    address internal alice = address(0x1);
    address internal bob   = address(0x2);

    function setUp() public {
        // Deploy the token from the desired owner account
        vm.prank(owner);
        token = new MyToken721(owner);
    }

    function test_721MetadataAndOwner() public view {
        assertEq(token.name(),  "MyToken");
        assertEq(token.symbol(), "MTK");
        assertEq(token.owner(),  owner);
    }

    function test_721OwnerCanSafeMint() public {
        vm.prank(owner);
        token.safeMint(alice, 1);

        assertEq(token.totalSupply(), 1);
        assertEq(token.ownerOf(1),    alice);
        assertEq(token.balanceOf(alice), 1);
    }

    function test_721EnumerableFunctions() public {
        vm.startPrank(owner);
        token.safeMint(alice, 1);
        token.safeMint(bob,   2);
        vm.stopPrank();

        // Global supply & indexes
        assertEq(token.totalSupply(), 2);
        assertEq(token.tokenByIndex(0), 1);
        assertEq(token.tokenByIndex(1), 2);

        // Per-owner indexes
        assertEq(token.tokenOfOwnerByIndex(alice, 0), 1);
        assertEq(token.tokenOfOwnerByIndex(bob,   0), 2);
    }

    function test_721Interfaces() public view {
        assertTrue(
            token.supportsInterface(type(IERC721).interfaceId),
            "IERC721 not supported"
        );
        assertTrue(
            token.supportsInterface(type(IERC721Enumerable).interfaceId),
            "IERC721Enumerable not supported"
        );
    }
}
