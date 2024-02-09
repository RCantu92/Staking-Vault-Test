pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {Upgrades, Options} from "openzeppelin-foundry-upgrades/Upgrades.sol";

import {RedemptionReceiver} from "../src/RedemptionReceiver.sol";
import {InactiveSharesDistributor} from "../src/InactiveSharesDistributor.sol";
import {FortaStakingVault} from "../src/FortaStakingVault.sol";

import {IFortaStaking} from "../src/interfaces/IFortaStaking.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DefenderScript is Script {
    function setUp() public {}

    function run() public {
        Options memory opts;
        opts.defender.useDefenderDeploy = true;

        address RedemptionReceiverProxy = Upgrades.deployUUPSProxy(
            "RedemptionReceiver.sol",
            abi.encodeCall(RedemptionReceiver.initialize, (
                IFortaStaking(0x64d5192F03bD98dB1De2AA8B4abAC5419eaC32CE),
                IERC20(0x107Ac13567b1b5D84691f890A5bA07EdaE1a11c3)
            )),
            opts
        );

        console.log("Deployed RedemptionReceiver proxy to address", RedemptionReceiverProxy);

        // address InactiveSharesDistributorProxy = Upgrades.deployUUPSProxy(
        //     "InactiveSharesDistributor.sol",
        //     abi.encodeCall(InactiveSharesDistributor.initialize, (
        //         IFortaStaking(0x64d5192F03bD98dB1De2AA8B4abAC5419eaC32CE),
        //         IERC20(0x107Ac13567b1b5D84691f890A5bA07EdaE1a11c3),
        //         /* uint256 subject */,
        //         /* uint256 shares */
        //     )),
        //     opts
        // );

        // console.log("Deployed InactiveSharesDistributor proxy to address", InactiveSharesDistributorProxy);

        // address FortaStakingVaultProxy = Upgrades.deployUUPSProxy(
        //     "FortaStakingVault.sol",
        //     abi.encodeCall(FortaStakingVault.initialize, (
        //         0x107Ac13567b1b5D84691f890A5bA07EdaE1a11c3,
        //         0x64d5192F03bD98dB1De2AA8B4abAC5419eaC32CE,
        //         0xc9197C75161acE0a07687F61FC6aF055BC42326c, // redemptionReceiverImplementation - Initial Deployment
        //         0x4161743f40FbB88bF682A4D0183B537D72c7357d, // inactiveSharesDistributorImplementation - Initial Deployment
        //         0,
        //         0x233BAc002bF01DA9FEb9DE57Ff7De5B3820C1a24,
        //         0x404afc59Cacd74A28d0D5651460Cc950b42FAf08
        //     )),
        //     opts
        // );
    }
}