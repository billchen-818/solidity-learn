# 表达式和控制结构

## 控制结构

已知的大多数控制结构可以在solidity中使用。有if、else、while、do、for、break、continue、return。

solidity还支持try/catch语句形式的异常处理，但仅适用于外部函数调用和合约创建调用。可以使用revert语句创建错误。

条件语句不能省略括号，但可以省略单语句体周围的大括号。

## 函数调用

### 内部函数调用

当前合约的函数可以直接（“内部”）调用，也可以递归调用，如这个荒谬的例子所示：

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;

// This will report a warning
contract C {
    function g(uint a) public pure returns (uint ret) { return a + f(); }
    function f() internal pure returns (uint ret) { return g(7) + f(); }
}
```

这些函数调用被转换为 EVM 内的简单跳转。 这具有不会清除当前内存的效果，即将内存引用传递给内部调用的函数是非常有效的。 内部只能调用同一个合约实例的函数。

您仍然应该避免过度递归，因为每个内部函数调用至少会占用一个堆栈槽，并且只有 1024 个槽可用。

### 外部函数调用

表达式 this.g(8); 和 c.g(2); （其中 c 是合约实例）也是有效的函数调用，但这次，该函数将通过消息调用而不是直接通过跳转被“外部”调用。 请注意，不能在构造函数中使用 this 的函数调用，因为尚未创建实际的合约。

其他合约的功能必须在外部调用。 对于外部调用，所有函数参数都必须复制到内存中。

> 从一个合约到另一个合约的函数调用不会创建自己的交易，它是作为整个交易一部分的消息调用。

在调用其他合约的函数时，您可以通过特殊选项{value: 10, gas: 10000}指定随调用发送的wei或gas数量。 请注意，不鼓励明确指定 gas 值，因为操作码的 gas 成本可能会在未来发生变化。 您发送到合约的任何 Wei 都会添加到该合约的总余额中：

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.2 <0.9.0;

contract InfoFeed {
    function info() public payable returns (uint ret) { return 42; }
}

contract Consumer {
    InfoFeed feed;
    function setFeed(InfoFeed addr) public { feed = addr; }
    function callFeed() public { feed.info{value: 10, gas: 800}(); }
}
```

您需要在 info 函数中使用修饰符payable，否则，value 选项将不可用。

> 请注意 feed.info{value: 10, gas: 800} 仅在本地设置随函数调用发送的 gas 值和数量，最后的括号执行实际调用。 因此，在这种情况下，不会调用该函数并且会丢失值和气体设置。

由于 EVM 认为对不存在的合约的调用总是成功的，Solidity 使用 extcodesize 操作码来检查即将被调用的合约是否确实存在（它包含代码），如果确实存在，则会引发异常 不是。 请注意，在对地址而不是合约实例进行操作的低级调用的情况下，不会执行此检查。

如果被调用的合约本身抛出异常或耗尽气体，函数调用也会导致异常。

> 与另一个合约的任何交互都会带来潜在的危险，尤其是在事先不知道合约的源代码的情况下。 当前合约将控制权移交给被调用的合约，这可能会做任何事情。 即使被调用的合约继承自一个已知的父合约，继承合约也只需要有一个正确的接口。 然而，合同的实施可能是完全任意的，因此会带来危险。 此外，请做好准备，以防它在第一次调用返回之前调用您系统的其他合约，甚至回到调用合约中。 这意味着被调用合约可以通过其函数更改调用合约的状态变量。 以某种方式编写您的函数，例如，在您的合约中的状态变量发生任何更改后调用外部函数，这样您的合约就不容易受到可重入漏洞的攻击。

> 在 Solidity 0.6.2 之前，推荐的指定值和气体的方法是使用 f.value(x).gas(g)()。 这在 Solidity 0.6.2 中已被弃用，并且自 Solidity 0.7.0 起不再可能。

### 命名调用和匿名函数参数

函数调用参数可以按名称以任何顺序给出，如果它们包含在 { } 中，如以下示例所示。 参数列表必须在名称上与函数声明中的参数列表一致，但可以是任意顺序。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;

contract C {
    mapping(uint => uint) data;

    function f() public {
        set({value: 2, key: 3});
    }

    function set(uint key, uint value) public {
        data[key] = value;
    }

}
```

### 省略的函数参数名称

未使用的参数（尤其是返回参数）的名称可以省略。 这些参数仍将出现在堆栈中，但无法访问。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;

contract C {
    // omitted name for parameter
    function func(uint k, uint) public pure returns(uint) {
        return k;
    }
}
```

## 通过new创建合约

一个合约可以使用 new 关键字创建其他合约。 在编译创建合约时必须知道正在创建的合约的完整代码，这样递归创建依赖是不可能的。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
contract D {
    uint public x;
    constructor(uint a) payable {
        x = a;
    }
}

contract C {
    D d = new D(4); // will be executed as part of C's constructor

    function createD(uint arg) public {
        D newD = new D(arg);
        newD.x();
    }

    function createAndEndowD(uint arg, uint amount) public payable {
        // Send ether along with the creation
        D newD = new D{value: amount}(arg);
        newD.x();
    }
}
```

如示例所示，可以在使用 value 选项创建 D 实例时发送 Ether，但不能限制 gas 的数量。 如果创建失败（由于栈外、余额不足或其他问题），则抛出异常。

###  Salted contract creations / create2

创建合约时，合约的地址是根据创建合约的地址和随着每次合约创建而增加的计数器计算得出的。

如果您指定选项 salt（一个 bytes32 值），那么合约创建将使用不同的机制来提供新合约的地址：

它将根据创建合约的地址、给定的盐值、创建的合约的（创建）字节码和构造函数参数计算地址。

特别是，不使用计数器（“nonce”）。 这为创建合约提供了更大的灵活性：您可以在创建新合约之前获得它的地址。 此外，如果创建合同同时创建其他合同，您也可以依赖此地址。

这里的主要用例是充当链下交互法官的合约，只有在发生争议时才需要创建合约。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
contract D {
    uint public x;
    constructor(uint a) {
        x = a;
    }
}

contract C {
    function createDSalted(bytes32 salt, uint arg) public {
        // This complicated expression just tells you how the address
        // can be pre-computed. It is just there for illustration.
        // You actually only need ``new D{salt: salt}(arg)``.
        address predictedAddress = address(uint160(uint(keccak256(abi.encodePacked(
            bytes1(0xff),
            address(this),
            salt,
            keccak256(abi.encodePacked(
                type(D).creationCode,
                arg
            ))
        )))));

        D d = new D{salt: salt}(arg);
        require(address(d) == predictedAddress);
    }
}
```

> 有一些关于盐渍创作的特殊性。 合约被销毁后可以在同一地址重新创建。 然而，即使创建字节码相同，新创建的合约也有可能具有不同的部署字节码（这是必需的，否则地址会改变）。 这是因为编译器可以查询在两次创建之间可能发生变化的外部状态，并在存储之前将其合并到部署的字节码中。

## 表达式的求值顺序

表达式的计算顺序没有指定（更正式地说，表达式树中一个节点的子节点的计算顺序没有指定，但它们当然在节点本身之前计算）。 只保证语句按顺序执行并完成布尔表达式的短路。

## 任务

### 解构赋值并返回多个值

Solidity 内部允许元组类型，即潜在不同类型的对象列表，其编号在编译时为常量。 这些元组可用于同时返回多个值。 然后可以将它们分配给新声明的变量或预先存在的变量（或一般的 LValues）。

元组在 Solidity 中不是适当的类型，它们只能用于形成表达式的句法分组。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;

contract C {
    uint index;

    function f() public pure returns (uint, bool, uint) {
        return (7, true, 2);
    }

    function g() public {
        // Variables declared with type and assigned from the returned tuple,
        // not all elements have to be specified (but the number must match).
        (uint x, , uint y) = f();
        // Common trick to swap values -- does not work for non-value storage types.
        (x, y) = (y, x);
        // Components can be left out (also for variable declarations).
        (index, , ) = f(); // Sets the index to 7
    }
}
```

不能混合变量声明和非声明赋值，即以下是无效的：(x, uint y) = (1, 2);

> 在 0.5.0 版本之前，可以分配给较小尺寸的元组，填充在左侧或右侧（无论是空的）。 现在不允许这样做，因此双方必须具有相同数量的组件。

> 当涉及引用类型时，同时分配给多个变量时要小心，因为这可能导致意外的复制行为。

### 数组和结构的复杂性

对于非值类型（如数组和结构）（包括字节和字符串），赋值的语义更为复杂，有关详细信息，请参阅数据位置和赋值行为。

在下面的示例中，对 g(x) 的调用对 x 没有影响，因为它在内存中创建了存储值的独立副本。 然而，h(x) 成功地修改了 x，因为只传递了一个引用而不是一个副本。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;

contract C {
    uint[20] x;

    function f() public {
        g(x);
        h(x);
    }

    function g(uint[20] memory y) internal pure {
        y[2] = 3;
    }

    function h(uint[20] storage y) internal {
        y[3] = 4;
    }
}
```

## 范围和声明

声明的变量将有一个初始默认值，其字节表示全为零。变量的“默认值”是任何类型的典型“零状态”。例如，bool 的默认值为 false。 uint 或 int 类型的默认值是 0。对于静态大小的数组和 bytes1 到 bytes32，每个单独的元素将被初始化为其类型对应的默认值。对于动态大小的数组、字节和字符串，默认值为空数组或字符串。对于枚举类型，默认值是它的第一个成员。

Solidity 中的作用域遵循 C99（和许多其他语言）的广泛作用域规则：变量从声明之后的那一点到包含声明的最小 { } 块的末尾都是可见的。作为此规则的一个例外，在 for 循环的初始化部分中声明的变量仅在 for 循环结束之前可见。

类似参数的变量（函数参数、修饰符参数、catch 参数……）在后面的代码块中可见 - 函数和修饰符参数的函数/修饰符的主体以及 catch 参数的 catch 块。

在代码块之外声明的变量和其他项目，例如函数、契约、用户定义的类型等，甚至在声明之前就可见。这意味着您可以在声明之前使用状态变量并递归调用函数。

因此，以下示例将在编译时没有警告，因为这两个变量具有相同的名称但作用域不相交。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;
contract C {
    function minimalScoping() pure public {
        {
            uint same;
            same = 1;
        }

        {
            uint same;
            same = 3;
        }
    }
}
```

作为 C99 范围规则的一个特殊示例，请注意在下面，对 x 的第一次赋值实际上将分配外部变量而不是内部变量。 在任何情况下，您都会收到有关外部变量被隐藏的警告。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;
// This will report a warning
contract C {
    function f() pure public returns (uint) {
        uint x = 1;
        {
            x = 2; // this will assign to the outer variable
            uint x;
        }
        return x; // x has value 2
    }
}
```

在 0.5.0 版本之前，Solidity 遵循与 JavaScript 相同的作用域规则，即在函数内任何位置声明的变量都在整个函数的作用域内，无论它在哪里声明。 以下示例显示了用于编译但从版本 0.5.0 开始导致错误的代码片段。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;
// This will not compile
contract C {
    function f() pure public returns (uint) {
        x = 2;
        uint x;
        return x;
    }
}
```

## Checked or Unchecked Arithmetic

上溢或下溢是指算术运算的结果值在不受限制的整数上执行时超出结果类型范围的情况。

在 Solidity 0.8.0 之前，算术运算总是会在下溢或溢出的情况下换行，从而导致广泛使用引入额外检查的库。

自 Solidity 0.8.0 起，默认情况下所有算术运算都会在上溢和下溢时恢复，因此无需使用这些库。

要获得先前的行为，可以使用未经检查的块：

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
contract C {
    function f(uint a, uint b) pure public returns (uint) {
        // This subtraction will wrap on underflow.
        unchecked { return a - b; }
    }
    function g(uint a, uint b) pure public returns (uint) {
        // This subtraction will revert on underflow.
        return a - b;
    }
}
```

对 f(2, 3) 的调用将返回 2**256-1，而 g(2, 3) 将导致断言失败。

unchecked 块可以在块内的任何地方使用，但不能替代块。它也不能嵌套。

该设置仅影响语法上位于块内的语句。从未经检查的块中调用的函数不继承该属性。

>为避免歧义，您不能使用 _；在未经检查的块内。

以下运算符将导致上溢或下溢断言失败，如果在未检查的块中使用，则将无错误地换行：

++, --, +, 二元 -, 一元 -, *, /, %, **

+=, -=, *=, /=, %=

>使用 unchecked 块无法禁用除以零或以零为模的检查。

>按位运算符不执行上溢或下溢检查。这在使用按位移位（<<、>>、<<=、>>=）代替整数除法和乘以 2 的幂时尤为明显。例如 type(uint256).max << 3 不会恢复即使 type(uint256).max * 8 会。


> int x = type(int).min; 中的第二个语句-X;将导致溢出，因为负范围可以比正范围多容纳一个值。

显式类型转换将始终截断并且永远不会导致断言失败，但从整数到枚举类型的转换除外。

## 错误处理：Assert、Require、Revert 和 Exceptions

Solidity 使用状态恢复异常来处理错误。此类异常会撤消对当前调用（及其所有子调用）中的状态所做的所有更改，并向调用者标记错误。

当子调用中发生异常时，它们会自动“冒泡”（即重新抛出异常），除非它们在 try/catch 语句中被捕获。这个规则的例外是发送和低级函数调用、委托调用和静态调用：它们返回 false 作为它们的第一个返回值，以防出现异常而不是“冒泡”。

>作为 EVM 设计的一部分，如果调用的帐户不存在，低级函数 call、delegatecall 和 staticcall 将返回 true 作为它们的第一个返回值。如果需要，必须在调用之前检查帐户是否存在。

异常可以包含以错误实例的形式传回给调用者的错误数据。内置错误 Error(string) 和 Panic(uint256) 由特殊函数使用，如下所述。 Error 用于“常规”错误条件，而 Panic 用于不应出现在无错误代码中的错误。

### Panic via assert and Error via require

便利函数 assert 和 require 可用于检查条件并在不满足条件时抛出异常。

assert 函数会创建一个类型为 Panic(uint256) 的错误。在下面列出的某些情况下，编译器会产生相同的错误。

断言应该只用于测试内部错误和检查不变量。正常运行的代码永远不应该造成恐慌，即使是在无效的外部输入上也不应该。如果发生这种情况，那么您的合同中存在一个您应该修复的错误。语言分析工具可以评估您的合约，以确定会导致 Panic 的条件和函数调用。

以下情况会产生 Panic 异常。与错误数据一起提供的错误代码表示恐慌的类型。

0x00：用于通用编译器插入的恐慌。

0x01：如果您使用计算结果为假的参数调用断言。

0x11：如果算术运算在未经检查的 { ... } 块之外导致下溢或上溢。

0x12;如果您除以或除以零（例如 5 / 0 或 23 % 0）。

0x21：如果将太大或为负的值转换为枚举类型。

0x22：如果您访问的存储字节数组编码不正确。

0x31：如果你在一个空数组上调用 .pop() 。

0x32：如果您在越界或负索引（即 x[i] 其中 i >= x.length 或 i < 0）处访问数组、bytesN 或数组切片。

0x41：如果分配太多内存或创建的数组太大。

0x51：如果调用内部函数类型的零初始化变量。

require 函数要么创建一个没有任何数据的错误，要么创建一个 Error(string) 类型的错误。它应该用于确保在执行时间之前无法检测到的有效条件。这包括对外部合同调用的输入或返回值的条件。

> 目前无法将自定义错误与 require 结合使用。 请使用 if (!condition) revert CustomError(); 反而。

在以下情况下，编译器会生成 Error(string) 异常（或没有数据的异常）：

调用 require(x)，其中 x 的计算结果为 false。

如果您使用 revert() 或 revert("description")。

如果您执行针对不包含代码的合同的外部函数调用。

如果您的合约通过没有应付修饰符（包括构造函数和回退函数）的公共函数接收 Ether。

如果您的合约通过公共 getter 函数接收 Ether。

对于以下情况，将转发来自外部调用（如果提供）的错误数据。这意味着它可能导致错误或恐慌（或其他任何给出的）：

如果 .transfer() 失败。

如果您通过消息调用调用一个函数但它没有正确完成（即，它耗尽了gas，没有匹配的函数，或者本身抛出异常），除非是低级操作调用、send、delegatecall、callcode 或使用静态调用。低级操作从不抛出异常，而是通过返回 false 来指示失败。

如果您使用 new 关键字创建合同，但合同创建未正确完成。

您可以选择为 require 提供消息字符串，但不能为 assert 提供消息字符串。

如果你没有为 require 提供字符串参数，它将返回空的错误数据，甚至不包括错误选择器。

以下示例显示了如何使用 require 检查输入条件并断言进行内部错误检查。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;

contract Sharer {
    function sendHalf(address payable addr) public payable returns (uint balance) {
        require(msg.value % 2 == 0, "Even value required.");
        uint balanceBeforeTransfer = address(this).balance;
        addr.transfer(msg.value / 2);
        // Since transfer throws an exception on failure and
        // cannot call back here, there should be no way for us to
        // still have half of the money.
        assert(address(this).balance == balanceBeforeTransfer - msg.value / 2);
        return address(this).balance;
    }
}
```

在内部，Solidity 执行还原操作（指令 0xfd）。 这会导致 EVM 恢复对状态所做的所有更改。 回退的原因是没有安全的方式继续执行，因为没有出现预期的效果。 因为我们要保持事务的原子性，所以最安全的操作是还原所有更改并使整个事务（或至少调用）无效。

在这两种情况下，调用者都可以使用 try/catch 对此类失败做出反应，但调用者中的更改将始终被还原。

>恐慌异常用于使用 Solidity 0.8.0 之前的无效操作码，这消耗了调用可用的所有气体。 使用 require 的例外用于消耗所有气体，直到 Metropolis 发布之前。

### Revert

可以使用 revert 语句和 revert 函数触发直接还原。

revert 语句将自定义错误作为不带括号的直接参数：

恢复自定义错误（arg1，arg2）；

出于后端兼容性的原因，还有 revert() 函数，它使用括号并接受一个字符串：

恢复（）;恢复（“描述”）；

错误数据将被传递回调用者并可以在那里被捕获。使用 revert() 会导致没有任何错误数据的还原，而 revert("description") 将创建一个 Error(string) 错误。

使用自定义错误实例通常比字符串描述便宜得多，因为您可以使用错误名称来描述它，它只用四个字节编码。更长的描述可以通过 NatSpec 提供，不会产生任何费用。

以下示例显示了如何将错误字符串和自定义错误实例与 revert 和等效的 require 一起使用：

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract VendingMachine {
    address owner;
    error Unauthorized();
    function buy(uint amount) public payable {
        if (amount > msg.value / 2 ether)
            revert("Not enough Ether provided.");
        // Alternative way to do it:
        require(
            amount <= msg.value / 2 ether,
            "Not enough Ether provided."
        );
        // Perform the purchase.
    }
    function withdraw() public {
        if (msg.sender != owner)
            revert Unauthorized();

        payable(msg.sender).transfer(address(this).balance);
    }
}
```

两种方式 if (!condition) revert(...);并要求（条件，...）；只要 revert 和 require 的参数没有副作用，例如，如果它们只是字符串，则是等效的。

>require 函数就像任何其他函数一样被评估。这意味着在执行函数本身之前评估所有参数。特别是，在 require(condition, f()) 中，即使条件为真，函数 f 也会执行。

提供的字符串是 abi 编码的，就好像它是对函数 Error(string) 的调用。在上面的例子中，revert("没有提供足够的以太。");返回以下十六进制作为错误返回数据：

```
0x08c379a0                                                         // Function selector for Error(string)
0x0000000000000000000000000000000000000000000000000000000000000020 // Data offset
0x000000000000000000000000000000000000000000000000000000000000001a // String length
0x4e6f7420656e6f7567682045746865722070726f76696465642e000000000000 // String data
```

调用者可以使用 try/catch 检索提供的消息，如下所示。

>曾经有一个名为 throw 的关键字与 revert() 具有相同的语义，它在 0.4.13 版本中被弃用并在 0.5.0 版本中删除。

### try/cache

可以使用 try/catch 语句捕获外部调用中的失败，如下所示：

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.1;

interface DataFeed { function getData(address token) external returns (uint value); }

contract FeedConsumer {
    DataFeed feed;
    uint errorCount;
    function rate(address token) public returns (uint value, bool success) {
        // Permanently disable the mechanism if there are
        // more than 10 errors.
        require(errorCount < 10);
        try feed.getData(token) returns (uint v) {
            return (v, true);
        } catch Error(string memory /*reason*/) {
            // This is executed in case
            // revert was called inside getData
            // and a reason string was provided.
            errorCount++;
            return (0, false);
        } catch Panic(uint /*errorCode*/) {
            // This is executed in case of a panic,
            // i.e. a serious error like division by zero
            // or overflow. The error code can be used
            // to determine the kind of error.
            errorCount++;
            return (0, false);
        } catch (bytes memory /*lowLevelData*/) {
            // This is executed in case revert() was used.
            errorCount++;
            return (0, false);
        }
    }
}
```

try 关键字后必须跟一个表示外部函数调用或合约创建的表达式 (new ContractName())。表达式中的错误不会被捕获（例如，如果它是一个还涉及内部函数调用的复杂表达式），只会在外部调用本身内部发生恢复。后面的返回部分（可选）声明与外部调用返回的类型匹配的返回变量。如果没有错误，这些变量将被分配，合约的执行将在第一个成功块内继续。如果到达成功块的末尾，则在 catch 块之后继续执行。

Solidity 根据错误类型支持不同类型的 catch 块：

- catch Error(string memory reason) { ... }：如果错误是由 revert("reasonString") 或 require(false, "reasonString") （或导致此类异常的内部错误）引起的，则执行此 catch 子句.

- catch Panic(uint errorCode) { ... }：如果错误是由恐慌引起的，即由失败的断言、被零除、无效的数组访问、算术溢出等引起，则将运行此 catch 子句。

- catch (bytes memory lowLevelData) { ... }：如果错误签名与任何其他子句不匹配，如果在解码错误消息时出现错误，或者如果没有错误数据提供异常，则执行此子句。在这种情况下，声明的变量提供对低级错误数据的访问。

- catch { ... }：如果您对错误数据不感兴趣，您可以使用 catch { ... } （即使作为唯一的 catch 子句）而不是前一个子句。

计划在未来支持其他类型的错误数据。字符串 Error 和 Panic 当前按原样解析，不被视为标识符。

为了捕获所有错误情况，您必须至少有子句 catch { ...} 或子句 catch (bytes memory lowLevelData) { ... }。

在returns 和catch 子句中声明的变量仅在后面的块中起作用。

>如果在 try/catch 语句中的返回数据的解码过程中发生错误，则会导致当前执行的合约中出现异常，因此，它不会在 catch 子句中捕获。如果在catch Error(string memory reason)的解码过程中出现错误，并且有低级catch子句，则在那里捕获该错误。

>如果执行到达 catch 块，则外部调用的状态改变效果已经恢复。如果执行到达成功块，则效果不会恢复。如果效果已恢复，则执行要么在 catch 块中继续执行，要么 try/catch 语句本身的执行恢复（例如，由于上述解码失败或由于未提供低级 catch 子句）。

>呼叫失败背后的原因可能是多方面的。不要假设错误消息直接来自被调用的合约：错误可能发生在调用链的更深处，被调用的合约只是转发了它。此外，这可能是由于燃料不足的情况而不是故意的错误情况：调用者总是在调用中保留 63/64 的燃料，因此即使被调用的合约耗尽燃料，调用者仍然有还剩一些气体。