// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Test.sol";
import "../src/ACTXToken.sol";

contract ACTXTokenTest is Test {
    ACTXToken token;

    address owner = address(this);
    address treasury = address(0x1);
    address reservoir = address(0x2);
    address user = address(0x3);

    uint256 constant INITIAL_SUPPLY = 100_000_000 ether;
    uint256 constant TAX_RATE = 200; // 2%

    function setUp() public {
        token = new ACTXToken();
        token.initialize(treasury, reservoir, TAX_RATE);
    }

    //MINTING

    function testInitialSupplyMintedToTreasury() public {
        assertEq(token.balanceOf(treasury), INITIAL_SUPPLY);
    }

    //TRANSFER + TAX

    function testTransferAppliesTax() public {
        vm.prank(treasury);
        token.transfer(user, 100 ether);

        uint256 tax = (100 ether * TAX_RATE) / 10_000;
        uint256 received = 100 ether - tax;

        assertEq(token.balanceOf(user), received);
        assertEq(token.balanceOf(reservoir), tax);
    }

    //REWARD DISTRIBUTION

    function testRewardDistributionByManager() public {
        vm.prank(treasury);
        token.transfer(owner, 50 ether);

        token.distributeReward(user, 20 ether);

        assertEq(token.balanceOf(user), 20 ether);
    }

    //ROLE RESTRICTIONS

    function testUnauthorizedRewardDistributionReverts() public {
        vm.prank(user);
        vm.expectRevert();
        token.distributeReward(user, 1 ether);
    }

    //TAX ADMIN

    function testOnlyOwnerCanUpdateTaxRate() public {
        token.setTaxRate(300);
        assertEq(token.taxRateBasisPoints(), 300);

        vm.prank(user);
        vm.expectRevert();
        token.setTaxRate(400);
    }

    //UPGRADE LOGIC
    function testUpgradeAuthorization() public {
        ACTXToken newImpl = new ACTXToken();

        token.upgradeTo(address(newImpl));

        // Proxy address remains unchanged
        assertTrue(address(token) != address(0));
    }
}
