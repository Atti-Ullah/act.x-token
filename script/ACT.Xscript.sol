// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

/*
 * Foundry deployment script for ACT.XToken
 * This script deploys:
 * 1. ACTXToken implementation
 * 2. ERC1967 UUPS proxy
 * 3. Initializes the proxy with constructor-like parameters
 */

import "forge-std/Script.sol";
import "../src/ACTXToken.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployACTX is Script {
    function run() external {
        /*
         * Load private key and addresses from environment variables
         * NEVER hardcode private keys in production code
         */
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Treasury receives initial supply and tax reservoir
        address treasury = vm.envAddress("TREASURY");

        // Initial tax rate (basis points)
        uint256 initialTax = 200; // 2%

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy ACTXToken implementation (logic contract)
        ACTXToken implementation = new ACTXToken();

        // 2. Deploy ERC1967 UUPS proxy and initialize
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            abi.encodeWithSignature(
                "initialize(address,address,uint256)",
                treasury,
                treasury,
                initialTax
            )
        );

        vm.stopBroadcast();

        // Log proxy address
        console.log("ACT.XToken Proxy deployed at:", address(proxy));
    }
}
