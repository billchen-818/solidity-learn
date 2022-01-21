// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8;

contract Payable {

    mapping(address => uint256) public balanceOf;

    // 充值函数
    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
    }

    // 提现函数
    function withdraw() public {
        payable(msg.sender).transfer(balanceOf[msg.sender]);
        balanceOf[msg.sender] = 0;
    }

    function balance() public view returns(uint256) {
        return address(this).balance;
    }
}