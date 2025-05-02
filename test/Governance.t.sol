// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {MyToken} from "../src/MyToken.sol";
import {Box} from "../src/Box.sol";
import {IGovernor} from "@openzeppelin/contracts/governance/IGovernor.sol";

contract GovernorLifecycleTest is Test {
    // Test accounts
    address public proposer;
    address public voter1;
    address public voter2;

    // Core contracts
    MyToken public token;
    TimelockController public timelock;
    MyGovernor public governor;
    Box public box;

    // Proposal data
    uint256 public proposalId;
    bytes32 public descriptionHash;
    address[] public targets;
    uint256[] public values;
    bytes[] public calldatas;
    string public description = "Store 42 in Box";

    // Constants
    uint256 public constant TOKENS = 100e18;
    uint256 public constant NEW_VALUE = 42;

    function setUp() public {
        // Initialize test accounts
        proposer = makeAddr("Proposer");
        voter1 = makeAddr("Voter1");
        voter2 = makeAddr("Voter2");

        // Deploy token
        token = new MyToken();

        // Deploy timelock with minimal configuration
        address[] memory proposers = new address[](1);
        proposers[0] = proposer;
        timelock = new TimelockController(
            1 days,
            proposers,
            new address[](0), // Empty executors array
            address(this)
        );

        // Deploy governor
        governor = new MyGovernor(token, timelock);

        // Configure timelock permissions
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(0)); // Anyone can execute
        timelock.revokeRole(timelock.PROPOSER_ROLE(), proposer); // Only governor can propose

        // Deploy box controlled by timelock
        box = new Box(address(timelock));

        // Set up proposal data
        targets = new address[](1);
        values = new uint256[](1);
        calldatas = new bytes[](1);
        targets[0] = address(box);
        values[0] = 0;
        calldatas[0] = abi.encodeCall(Box.store, (NEW_VALUE));
        descriptionHash = keccak256(bytes(description));

        // Distribute tokens and delegate voting power
        token.mint(voter1, TOKENS);
        token.mint(voter2, TOKENS);
        vm.prank(voter1);
        token.delegate(voter1);
        vm.prank(voter2);
        token.delegate(voter2);
    }

    function test_GovProposal() public {
        // Create proposal
        vm.prank(proposer);
        proposalId = governor.propose(targets, values, calldatas, description);
        assertEq(uint8(governor.state(proposalId)), uint8(IGovernor.ProposalState.Pending));

        // Move to active state
        vm.roll(block.number + governor.votingDelay() + 1);
        assertEq(uint8(governor.state(proposalId)), uint8(IGovernor.ProposalState.Active));

        // Vote
        vm.prank(voter1);
        governor.castVote(proposalId, 1); // Vote in favor
        vm.prank(voter2);
        governor.castVote(proposalId, 1); // Vote in favor

        // End voting period
        vm.roll(block.number + governor.votingPeriod() + 1);
        assertEq(uint8(governor.state(proposalId)), uint8(IGovernor.ProposalState.Succeeded));

        // Queue
        governor.queue(targets, values, calldatas, descriptionHash);
        assertEq(uint8(governor.state(proposalId)), uint8(IGovernor.ProposalState.Queued));

        // Wait timelock delay
        vm.warp(block.timestamp + timelock.getMinDelay() + 1);

        // Execute
        governor.execute(targets, values, calldatas, descriptionHash);
        assertEq(uint8(governor.state(proposalId)), uint8(IGovernor.ProposalState.Executed));

        // Verify execution
        assertEq(box.retrieve(), NEW_VALUE, "Box value should match proposal value");
    }
}
