// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8;

library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns(uint256) {
        uint256 z = x + y;
        require(z >= x, "overflow");
        return z;
    }
}

contract TestArray {
    using SafeMath for uint;

    function testAdd(uint x, uint y) public pure returns(uint) {
        return x.add(y);

        // SafeMath.add(x,y);

    }

}