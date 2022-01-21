// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract Constructor {
    uint256 public x;
    uint256 public y;
    address public owner;
    uint256 public creatAt;


    constructor(uint _x, uint256 _y) {
        x = _x;
        y = _y;
        owner = msg.sender;
        creatAt = block.timestamp;
    }
}