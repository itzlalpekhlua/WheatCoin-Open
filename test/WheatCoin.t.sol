// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {WheatCoin} from "../src/WheatCoin.sol";
import {ERC20Capped} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

contract WheatCoinTest is Test {
    WheatCoin internal token;
    address internal admin = makeAddr("admin");
    address internal treasury = makeAddr("treasury");
    address internal user = makeAddr("user");

    uint256 internal constant INITIAL_SUPPLY = 100_000_000 ether;

    function setUp() public {
        token = new WheatCoin(admin, treasury, INITIAL_SUPPLY);
    }

    function testMetadataAndInitialSupply() public view {
        assertEq(token.name(), "WheatCoin");
        assertEq(token.symbol(), "WHEAT");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.balanceOf(treasury), INITIAL_SUPPLY);
        assertEq(token.cap(), 1_000_000_000 ether);
    }

    function testAdminCanMint() public {
        vm.prank(admin);
        token.mint(user, 50 ether);
        assertEq(token.balanceOf(user), 50 ether);
    }

    function testUnauthorizedAccountCannotMint() public {
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, user, token.MINTER_ROLE())
        );
        vm.prank(user);
        token.mint(user, 1 ether);
    }

    function testMintCannotExceedCap() public {
        vm.expectRevert(
            abi.encodeWithSelector(ERC20Capped.ERC20ExceededCap.selector, 1_000_000_001 ether, 1_000_000_000 ether)
        );
        vm.prank(admin);
        token.mint(user, 900_000_001 ether);
    }

    function testPauseStopsTransfersAndUnpauseRestoresThem() public {
        vm.prank(treasury);
        assertTrue(token.transfer(user, 20 ether));

        vm.prank(admin);
        token.pause();
        vm.expectRevert(Pausable.EnforcedPause.selector);
        vm.prank(user);
        token.transfer(treasury, 1 ether);

        vm.prank(admin);
        token.unpause();
        vm.prank(user);
        assertTrue(token.transfer(treasury, 1 ether));
        assertEq(token.balanceOf(user), 19 ether);
    }

    function testHolderCanBurnTokens() public {
        vm.prank(treasury);
        assertTrue(token.transfer(user, 10 ether));
        vm.prank(user);
        token.burn(4 ether);
        assertEq(token.balanceOf(user), 6 ether);
        assertEq(token.totalSupply(), INITIAL_SUPPLY - 4 ether);
    }
}
