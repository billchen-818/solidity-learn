// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8;

import "./22_ImportFool.sol";

contract Import is foo {

    function getText() external view returns (string memory) {
        return text;
    }
}