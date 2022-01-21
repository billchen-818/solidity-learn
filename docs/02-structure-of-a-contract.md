# 合约的结构

solidity中的合约类似于面向对象语言中的类。每个合约都可以包含状态变量、函数、函数修饰符、事件、错误、结构类型和枚举类型的声明。此外合约还可以从其它合约继承。

还有称为库和接口的特殊类型合约。

## 状态变量

状态变量是其值永久存储在合约存储中的变量。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;

contract SimpleStorage {
    uint storedData; // State variable
    // ...
}
```

## 函数

代码的执行单元，通常在合约内定义，亦可以在合约外定义。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.1 <0.9.0;

contract SimpleAuction {
    function bid() public payable { // Function
        // ...
    }
}

// Helper function defined outside of a contract
function helper(uint x) pure returns (uint) {
    return x * 2;
}
```

函数调用可以在内部或者外部发生，并且对其它合约具有不同级别的可见性。函数接受参数并返回变量以在它们之间传递参数和值。

## 函数修饰器

参见合约部分

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;

contract Purchase {
    address public seller;

    modifier onlySeller() { // Modifier
        require(
            msg.sender == seller,
            "Only seller can call this."
        );
        _;
    }

    function abort() public view onlySeller { // Modifier usage
        // ...
    }
}
```

## 事件

事件是与EVM日志记录工具的便捷接口。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.21 <0.9.0;

contract SimpleAuction {
    event HighestBidIncreased(address bidder, uint amount); // Event

    function bid() public payable {
        // ...
        emit HighestBidIncreased(msg.sender, msg.value); // Triggering event
    }
}
```

参见合约部分

## 错误

错误允许您为失败情况定义描述性名称和数据。 错误可以在 revert 语句中使用。 与字符串描述相比，错误要便宜得多，并且允许您对附加数据进行编码。 您可以使用 NatSpec 向用户描述错误。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

/// Not enough funds for transfer. Requested `requested`,
/// but only `available` available.
error NotEnoughFunds(uint requested, uint available);

contract Token {
    mapping(address => uint) balances;
    function transfer(address to, uint amount) public {
        uint balance = balances[msg.sender];
        if (balance < amount)
            revert NotEnoughFunds(amount, balance);
        balances[msg.sender] -= amount;
        balances[to] += amount;
        // ...
    }
}
```

参见合约部分

## 结构类型

结构自定义类型，可以对多个变量进行组合。（类似于其他语言里面的结构体）

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;

contract Ballot {
    struct Voter { // Struct
        uint weight;
        bool voted;
        address delegate;
        uint vote;
    }
}
```

## 枚举类型

枚举可以创建具有有限常量值集的自定义类型。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;

contract Purchase {
    enum State { Created, Locked, Inactive } // Enum
}
```