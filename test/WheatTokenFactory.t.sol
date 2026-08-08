// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {WheatCommunityToken, WheatTokenFactory} from "../src/WheatTokenFactory.sol";

contract WheatTokenFactoryTest is Test {
    WheatTokenFactory internal factory;
    address internal creator = address(0xCAFE);
    address payable internal treasury = payable(address(0xBEEF));

    function setUp() public {
        factory = new WheatTokenFactory(address(this), treasury, 10 ether);
        vm.deal(creator, 100 ether);
    }

    function testCreateFixedSupplyTokenAndRegisterIt() public {
        vm.prank(creator);
        address tokenAddress = factory.createToken{value: 10 ether}("Harvest Token", "HRVST", 1_000_000);
        WheatCommunityToken token = WheatCommunityToken(tokenAddress);

        assertEq(token.name(), "Harvest Token");
        assertEq(token.symbol(), "HRVST");
        assertEq(token.totalSupply(), 1_000_000 ether);
        assertEq(token.balanceOf(creator), 1_000_000 ether);
        assertEq(token.creator(), creator);
        assertTrue(factory.isFactoryToken(tokenAddress));
        assertEq(factory.tokenCount(), 1);
        assertEq(treasury.balance, 10 ether);
    }

    function testRejectsIncorrectFee() public {
        vm.prank(creator);
        vm.expectRevert(WheatTokenFactory.IncorrectFee.selector);
        factory.createToken{value: 1 ether}("Harvest Token", "HRVST", 1_000_000);
    }

    function testRejectsInvalidMetadataAndSupply() public {
        vm.startPrank(creator);
        vm.expectRevert(WheatTokenFactory.InvalidName.selector);
        factory.createToken{value: 10 ether}("A", "AAA", 1);
        vm.expectRevert(WheatTokenFactory.InvalidSymbol.selector);
        factory.createToken{value: 10 ether}("Valid", "A", 1);
        vm.expectRevert(WheatTokenFactory.InvalidSupply.selector);
        factory.createToken{value: 10 ether}("Valid", "VALID", 0);
        vm.stopPrank();
    }

    function testOwnerCanUpdateFactorySettings() public {
        factory.setCreationFee(25 ether);
        factory.setFeeRecipient(payable(address(0x1234)));
        assertEq(factory.creationFee(), 25 ether);
        assertEq(factory.feeRecipient(), address(0x1234));
    }
}
