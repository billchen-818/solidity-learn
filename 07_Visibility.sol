// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract Base {
    string private privateVar = "private variable";
    string internal internalVar = "internal variable";
    string public publicVar = "public variable";


    function privateFunc() private pure returns (string memory) {
        return "private function called";
    }

    function internalFunc() internal pure returns (string memory) {
        return "internal function called";
    }

    function testPrivateFunc() public pure returns (string memory) {
        return privateFunc();
    }

    function externalFunc() external pure returns (string memory) {
        return "external function called";
    }
}

contract Child is Base {
    function testInternalFunc() external pure returns (string memory) {
        return internalFunc();
    }
}