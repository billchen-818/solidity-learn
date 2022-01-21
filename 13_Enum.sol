// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8;

contract Enum {
    // 声明一个枚举
    enum Status {
        Pengding,
        Accepted,
        Canceled
    }

    // 定义一个枚举
    Status public status;

    function get() public view returns(Status) {
        return status;
    }

      function set(Status _status) public {
        status = _status;
    }

    function cancel() public {
        status = Status.Canceled;
    }

    function reset() public {
        delete status;
    }


}