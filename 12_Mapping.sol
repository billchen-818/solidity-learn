// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8;

contract Mapping {

    mapping (address => uint256) public balanceOf;

    function getBalance(address addr) public view returns(uint256) {
        return balanceOf[addr];
    }

    function transfer(address addr, uint256 value) public {
        //balanceOf[msg.sender] -= value;
        balanceOf[addr] += value;
    }

    function remove(address addr) public {
            delete balanceOf[addr];
    }
}