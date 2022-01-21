// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8;

contract ReceiveEther {

    string public data;

    // Function to receive Ether. msg.data must be empty
    receive() external payable {
        data = "receive call";
    }

    // Fallback function is called when msg.data is not empty
    fallback() external payable {
        data = "fallback call";
    }

    function getBalance() public view returns(uint256) {
            return address(this).balance;
    }
}