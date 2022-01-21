// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract Event {
    event Log1(address sender, uint256 value);

    function test() external {
        emit Log1(msg.sender, 100);
    }
}