// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title AnchorBounties — funded contribution and verifiable payout receipts
/// @notice Unaudited hackathon reference implementation. ERC-20 USDC uses 6 decimals on Arc.
/// @dev Claimed tasks require sponsor approval; unresolved disputes need an offchain resolution.
contract AnchorBounties is ReentrancyGuard {
    using SafeERC20 for IERC20;
    IERC20 public immutable usdc;
    uint256 public nextId;
    enum Status {Open, Claimed, Submitted, Paid, Cancelled}
    struct Bounty {
        address sponsor;
        address contributor;
        uint96 amount;
        uint64 deadline;
        Status status;
        bytes32 briefHash;
        bytes32 evidenceHash;
    }
    mapping(uint256 => Bounty) public bounties;
    event BountyCreated(uint256 indexed id, address indexed sponsor, uint256 amount, uint64 deadline, bytes32 briefHash);
    event Claimed(uint256 indexed id, address indexed contributor);
    event Submitted(uint256 indexed id, bytes32 evidenceHash);
    event Paid(uint256 indexed id, address indexed contributor, uint256 amount, bytes32 evidenceHash);
    event Cancelled(uint256 indexed id);
    error Unauthorized(); error InvalidState(); error InvalidInput(); error DeadlinePassed();

    constructor(address usdc_) {
        if (usdc_ == address(0)) revert InvalidInput();
        usdc = IERC20(usdc_);
    }
    function create(uint96 amount, uint64 deadline, bytes32 briefHash) external nonReentrant returns (uint256 id) {
        if (amount == 0 || deadline <= block.timestamp || briefHash == bytes32(0)) revert InvalidInput();
        id = nextId++;
        bounties[id] = Bounty(msg.sender, address(0), amount, deadline, Status.Open, briefHash, bytes32(0));
        usdc.safeTransferFrom(msg.sender, address(this), amount);
        emit BountyCreated(id, msg.sender, amount, deadline, briefHash);
    }
    function claim(uint256 id) external {
        Bounty storage b = bounties[id];
        if (b.sponsor == address(0)) revert InvalidInput();
        if (b.status != Status.Open) revert InvalidState();
        if (block.timestamp > b.deadline) revert DeadlinePassed();
        if (msg.sender == b.sponsor) revert Unauthorized();
        b.contributor = msg.sender;
        b.status = Status.Claimed;
        emit Claimed(id, msg.sender);
    }
    function submit(uint256 id, bytes32 evidenceHash) external {
        Bounty storage b = bounties[id];
        if (msg.sender != b.contributor) revert Unauthorized();
        if (b.status != Status.Claimed) revert InvalidState();
        if (evidenceHash == bytes32(0)) revert InvalidInput();
        b.evidenceHash = evidenceHash;
        b.status = Status.Submitted;
        emit Submitted(id, evidenceHash);
    }
    function approveAndPay(uint256 id) external nonReentrant {
        Bounty storage b = bounties[id];
        if (msg.sender != b.sponsor) revert Unauthorized();
        if (b.status != Status.Submitted) revert InvalidState();
        b.status = Status.Paid;
        usdc.safeTransfer(b.contributor, b.amount);
        emit Paid(id, b.contributor, b.amount, b.evidenceHash);
    }
    /// @notice Refund unclaimed tasks; never takes funds away from a claimed contributor.
    function cancelUnclaimed(uint256 id) external nonReentrant {
        Bounty storage b = bounties[id];
        if (msg.sender != b.sponsor) revert Unauthorized();
        if (b.status != Status.Open) revert InvalidState();
        b.status = Status.Cancelled;
        usdc.safeTransfer(b.sponsor, b.amount);
        emit Cancelled(id);
    }
}
