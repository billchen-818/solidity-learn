// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8;

// delegatecall is a low level function similar to call.
// When contract A executes delegatecall to contract B,B's code is excuted
// with contract A's storage, msg.sender and msg.value.

contract B {
    uint public num;
    uint public value;

    function setVars(uint _num) public payable {
        num = _num;
        value = msg.value;
    }
}

// B合约升级
contract B2 {
    uint public num;
    uint public value;

    function setVars(uint _num) public payable {
        num = _num + 1;
        value = msg.value;
    }
}

contract A {
    uint public num;
    uint public value;
    address public b;

    event Re(bool, bytes);

    function setVars(uint _num) public payable {
        (bool success, bytes memory data) = b.delegatecall(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );

        emit Re(success, data);
    }

    function setB(address _b) external {
        b = _b;
    }
}