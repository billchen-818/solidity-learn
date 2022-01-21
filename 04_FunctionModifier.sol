// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract FunctionModifier {
    address public owner;
    address public zero = address(0);
    uint256 public btcPrice;
    uint256 public ethPrice;
    uint256 public adaPrice;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner ,"Not Owner");
        _;
    }

    modifier validAddress(address addr) {
        require(addr != address(0), "0 address");
        _;
    }

    function setBTC(uint256 _btcPrice) public onlyOwner {
        btcPrice = _btcPrice;
    }

    function setETH(uint256 _ethPrice) public onlyOwner {
        ethPrice = _ethPrice;
    }

    function setADA(uint256 _adaPrice) public onlyOwner {
        adaPrice = _adaPrice;
    }

    function changeOwner(address _newOwner) public 
        onlyOwner 
        validAddress(_newOwner) {
        owner = _newOwner;
    }   

}