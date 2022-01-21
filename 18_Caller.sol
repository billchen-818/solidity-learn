// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8;

contract ReceiveEther {

    event Received(address caller, uint256 amout, string msg);

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    fallback() external payable {
        emit Received(msg.sender, msg.value, "fallback");
    }

      receive() external payable {
        emit Received(msg.sender, msg.value, "receive");
    }

    function foo(string memory _msg, uint256 _x) public payable returns(uint256) {
        emit Received(msg.sender, msg.value, _msg);
        return _x + 1;
    }
}

contract Caller {

    event Re(bool, bytes);

    function callFunc(address payable _addr) public payable {
        (bool success, bytes memory data) = _addr.call{value:msg.value, gas: 10000}(
            abi.encodeWithSignature("foo(string,uint256)", "call foo", 63504)
        );

        emit Re(success, data);
    }

    function callAAA(address payable _addr) public payable {
        (bool success, bytes memory data) = _addr.call{value:msg.value, gas: 10000}(
            abi.encodeWithSignature("aaa(string,uint256)", "call foo", 63504)
        );

        emit Re(success, data);
    }


}