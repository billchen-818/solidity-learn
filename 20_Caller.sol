// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8;

contract Callee {
    uint public x;
    uint public value;

    function setX(uint _x) public returns(uint) {
        x = _x;
        return x;
    }

    function setXandSendEther(uint _x) public payable returns (uint, uint) {
        x = _x;
        value = msg.value;
        return (x, value);
    }
}

contract Caller {
    function callSetX(Callee _callee, uint256 _x) public {
        uint256 x = _callee.setX(_x);
    }

    function callSetXAddr(address _addr, uint256 _x) public {
        Callee callee = Callee(_addr);
        callee.setX(_x);
    }

    function callSetXSendEther(address _addr, uint256 _x) public payable {
        Callee callee = Callee(_addr);
        (uint256 x, uint256 value) = callee.setXandSendEther{value:msg.value}(_x);
    }

}