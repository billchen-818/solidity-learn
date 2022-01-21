// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8;

// 合约创建合约

contract Pair {
    address public factory;
    string public token0;
    string public token1;

    constructor(string memory _token0, string memory _token1) payable {
        token0 = _token0;
        token1 = _token1;
        factory = msg.sender;
    }

}

contract Factory {
    Pair[] public allPairs;

    function creat(string memory _token0, string memory _token1) public {
        Pair pair = new Pair(_token1, _token0);
        allPairs.push(pair);
    }

    function creat2(string memory _token0, string memory _token1) public payable {
        Pair pair = (new Pair){value:msg.value}(_token1, _token0);
        allPairs.push(pair);
    }
}