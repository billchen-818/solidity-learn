// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8;

contract Error{
    uint256 public balance;
    uint256 public MAX = 2**256-1;

    function deposit(uint256 _amount) public {
        uint256 oldBal = balance;
        uint256 newBal = balance + _amount;
        if (newBal> oldBal) {
            revert("overflow");
        }
        balance = newBal;
    }

     function withdraw(uint256 _amount) public {
        balance -= _amount;
    }
}