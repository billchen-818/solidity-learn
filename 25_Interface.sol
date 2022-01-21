// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8;

interface IPair {
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
}

contract MyContract {

    function Reserves(address _uniswapV2) external view returns(uint) {
        uint112 _reserve0;
        uint112 _reserve1;
        (_reserve0, _reserve1, ) = IPair(_uniswapV2).getReserves();
        return (_reserve0 + _reserve1);
    }

    // function getReserves() external view returns (uint112, uint112, uint32) {


    // }
}