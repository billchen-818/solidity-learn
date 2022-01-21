// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract EtherUnits {
    uint public onewei = 1 wei;
    bool public isOneWei = 1 wei == 1;

    uint public oneEther = 1 ether;
    bool public isOneEther = 1 ether == 1e18;
}