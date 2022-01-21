// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8;

// 例子
// - 声明数组
// - Push , Pop 和 length
// - 移除元素
contract Array {
    // 动态数组声明
    uint256[] public arr;
    uint256[] public arr2 = [1,2,3]; // 声明并初始化

    // 静态数组声明
    uint256[10] public myfixedArr;

    function getArr() public view returns(uint256[] memory) {
        return arr2;
    }

    function getArrLength() public view returns(uint256) {
        return arr.length;
    }

    function push(uint256 i) public {
        arr.push(i);
    }

    function pop() public {
        arr.pop();
    }

    function remove(uint256 index) public {
        delete arr[index]; // 只是把这个索引位置变成0
    }

}