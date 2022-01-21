// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract A {
    string public name;
    constructor(string memory _name) {
        name = _name;
    }

    function getContractName() public pure virtual returns(string memory) {
        return "Contract A";
    }
}

contract B is A {

    constructor(string memory _name) A(_name) {

    }
    // 函数重写
    function getContractName() public pure override returns(string memory) {
        return "Contract B";
    }
}
