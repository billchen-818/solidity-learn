// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8;

contract Immutable {

    address public immutable MY_ADDRESS = msg.sender;
    uint private varr;

    function foo() external {
        require(msg.sender == MY_ADDRESS);
        varr += 1;
    }
}

// 45696 gas
// immutable 更省gas
// 43563 gas
