// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Box is Ownable {
    uint256 private _value;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function store(uint256 newValue) external onlyOwner {
        _value = newValue;
    }

    function retrieve() external view returns (uint256) {
        return _value;
    }
}
