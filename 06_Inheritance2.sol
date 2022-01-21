// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract A {
    function foo() public pure virtual returns(string memory) {
        return "Contract A";
    }
}

contract B {
    function foo() public pure virtual returns(string memory) {
        return "Contract B";
    }
}

contract C is A,B {
    function foo() public pure override(A,B) returns(string memory) {
        return "Contract C";
    }

    function boo() public pure returns(string memory) {
        return super.foo();
    }

    function coo() public pure returns(string memory) {
        return A.foo();
    }
}