// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8;

contract ReceiveEyher {

    receive() external payable {

    }

    fallback() external payable {
        
    }

    function getBalance() public view returns(uint256) {
            return address(this).balance;
    }
}

// 发送Ether的方式
contract SendEther {
    // transfer
    // send
    // call

    function transfer(address payable _to) public payable {
        _to.transfer(msg.value); // 没有返回值
    }

    
    function send(address payable _to) public payable {
        bool sent = _to.send(msg.value); // 有返回值
        require(sent, "Failed to send eth");
    }

    // transfer 和 send 有gaslimit  限制

    function call(address payable _to) public payable returns (bytes memory){
        (bool sent, bytes memory data) = _to.call{value:msg.value}(""); // 有返回值
        require(sent, "Failed to send eth");
        return data;
    }

}