# Types

Solidity是一种静态类型语言，这意味着需要指定每个变量的类型。Solidity提供了几种基本的类型，可以组合起来形成复杂的类型。

Solidity中不存在“未定义”或“空值”的概念，但新声明的变量始终具有依赖于其类型的默认值。

## 值类型

以下类型也称为值类型，因为这些类型的变量将始终按值传递，即它们在用作函数参数或者赋值时总是被复制。

### 布尔型

布尔型可能的值是常量true或者false.

操作有：
- !:逻辑非运算符
- &&:逻辑与运算符
- ||:逻辑或运算符
- ==:等于运算符
- !=:不等于运算符

> 逻辑与和逻辑或会有常见的短路规则。

### 整型

各种大小的有符号和无符号整数，uint8到uint256和int8到int256。int和uint分别为int256和uint256的别名。

操作有：
- 比较运算符：<=、<、==、!=、>=、>
- 位操作：&(按位与)、|(按位或)、^(按位异或)、~(安慰取反)
- 移位运算符:<<(左移运算符)、>>(右移运算符)
- 算术运算符:+(加)、-(减)、-(一元运算，仅支持有符号数)、*(乘)、/(除)、%(求余)、**(乘方)

>对于整数类型x，可以使用type(x).min和type(x).max来访问该类型的最小值和最大值

#### 比较运算符

比较的值是通过比较整数值获得的值

#### 位操作

位运算是在数字的二进制补码表示上执行的。~int256(0)==int256(-1)

#### 移位操作

移位操作的结果具有左操作数的类型，截断结果以匹配该类型。正确的操作数必须是无符号类型，有符号类型移位操作将产生编译错误。

左移操作：

```
x<<y等价于x*2**y
```

右移操作：

```
x>>y等价于x/2**y,朝负无穷大四舍五入
```

> 移位操作不会执行益处检查，因为它们是算术运算执行的。相反，结果总是被截断。

#### Addition、Subtraction和Multiplication加法减法和乘法

加法、减法和乘法具有通常的语义，默认情况下检查所有算术是否存在下溢或溢出，但是可以使用unchecked块禁用。

表达式-x等价于(T(0)-x)，其中T是x的类型。它只能应用于有符号类型。如果x为负，则-x的值可以为正。

如果有int c = type(int).min，则-x不适合正范围。这个可能意味着未经检查的{assert(-x == x);}有效，并且表达式-x在检查模式下使用将导致断言失败。

#### Division除法

由于运算结果的类型始终是其中一个操作数的类型，因此整数除法总是产生整数。在solidity中，除法向零舍入。例如：int256(5)/int256(-2)==iint256(-2)

除以零会导致panic错误。表达式type(int).min/(-1)是除法导致溢出的唯一情况。

#### modulo取余

模运算 a % n 在操作数 a 除以操作数 n 后产生余数 r，其中 q = int(a / n) 和 r = a - (n * q)。 这意味着取模产生与其左操作数（或零）相同的符号，并且 a % n == -(-a % n) 对负 a 成立：
- int256(5) % int256(2) == int256(1)
- int256(5) % int256(-2) == int256(1)
- int256(-5) % int256(2) == int256(-1)
- int256(-5) % int256(-2) == int256(-1)

除以零会导致panic错误。

#### Exponentiation求幂

幂运算仅适用于指数中的无符号类型。 求幂的结果类型总是等于底的类型。 请注意它足够大以保存结果并为潜在的断言失败或包装行为做好准备。

在检查模式下，取幂只使用相对便宜的 exp 操作码来处理小基数。 对于 x**3 的情况，表达式 x*x*x 可能更便宜。 在任何情况下，燃气成本测试和优化器的使用都是可取的。

>请注意，EVM 将 0**0 定义为 1。

### Fixed Point Numbers定点数

solidity尚未完全支持定点数。它们可以被声明，但不能被分配给或来自。

fixed/ufixed:各种大小的有符号和无符号定点数。关键字 ufixedMxN 和 fixedMxN，其中 M 表示该类型采用的位数，N 表示可用的小数点数。 M 必须能被 8 整除，并且从 8 到 256 位。 N 必须介于 0 和 80 之间，包括 0 和 80。 ufixed 和 fixed 分别是 ufixed128x18 和 fixed128x18 的别名。

运算操作：
- 比较运算符(<=、<、==、!=、>=、>))
- 算术运算符(+、-、-(一元)、*、/、%)

> 浮点数（许多语言中的浮点数和双精度数，更准确地说是 IEEE 754 数）和定点数之间的主要区别在于，用于整数和小数部分（小数点后的部分）的位数在 前者，而后者则有严格的定义。 通常，在浮点中，几乎整个空间都用于表示数字，而只有少数位定义小数点的位置。

### Address地址类型

address类型有两种风格，它们基本相同：
- address:保存一个20字节的值(以太坊地址的大小)
- address payable:与地址相同，但附加成员转移和发送。

它们之间的区别想法是，`address payable`是您可以发送ETH的地址，而`address`地址不能发送ETH

它们之间的类型转换

- 允许`address payable`到`address`的隐式转换
- `address`到`address payable`必须显示转换，payable(address)
- 对于uint160、整数类型、bytes20和合约类型，允许与`address`类型进行显示转换
- 只有`address`类型和合约类型的表达式可以通过显示转换转换为`address payable`,对于合约类型，只有当合约可以接收 Ether 时才允许这种转换，即合约具有接收或应付回退功能。 请注意，payable(0) 是有效的，并且是此规则的一个例外。

> 如果您需要一个地址类型的变量并计划向它发送 Ether，则将其类型声明为`address payable`以使此要求可见。

如果使用较大字节大小的类型转换为地址，比如byte32,则该地址将被截断，必须在转换中明确截断。

以32字节值0x1111222233334444555566666777788889999AAAABBBBCCCCDDDDEEEEFFFFCCCC 为例。

- address(uint160(bytes20(b)))，结果为 0x1111222233334444555566667777788889999aAaa
- address(uint160(uint256(b)))，结果为 0x777788889999AaAAbBbbCcccddDdeeeEfFFfCcCc

`address`和`address payable`之间的区别是在 0.5.0 版本中引入的。 同样从那个版本开始，合约不是从地址类型派生的，但如果它们具有接收或应付回退功能，仍然可以显式转换为`address`或`address payable`。

#### Members of Addresses(地址类型的成员)

`balance`和`transfer`

可以使用属性`balance`查询地址余额,使用`transfer`函数将Eth(以Wei为单位)发送到可支付地址。

```
address payable x = address(0x123);
address myAddress = address(this);
if (x.balance < 10 && myAddress.balance >= 10) x.transfer(10);
```

如果当前合约的余额不足或者以太币转账被接收账户拒绝，则转账功能失败。`transfer`函数在失败时恢复。

如果 x 是一个合约地址，它的代码（更具体地说：它的接收以太函数，如果存在，或者它的回退函数，如果存在）将与`transfer`调用一起执行（这是 EVM 的一个特性，无法阻止） ）。如果该执行用完 gas 或以任何方式失败，则以太币转移将被恢复，当前合约将异常停止。

`send`

Send是`transfer`的低级对应物。如果执行失败，当前合约不会因为异常而停止，但是`send`会返回`false`。

> 使用`send`有一些危险：如果调用堆栈深度为 1024（这总是可以由调用者强制），则传输失败，如果接收者耗尽 gas，传输也会失败。因此，为了进行安全的 Ether 转账，请始终检查 send 的返回值，使用`transfer`甚至更好：使用收款人提取资金的模式。

`call`, `delegatecall` and `staticcall`（调用、委托调用和静态调用）

为了与不遵守 ABI 的合约进行交互，或者更直接地控制编码，提供了函数 call、delegatecall 和 staticcall。它们都采用单个字节内存参数并返回成功条件（作为布尔值）和返回的数据（字节内存）。函数 abi.encode、abi.encodePacked、abi.encodeWithSelector 和 abi.encodeWithSignature 可用于对结构化数据进行编码。

```
bytes memory payload = abi.encodeWithSignature("register(string)", "MyName");
(bool success, bytes memory returnData) = address(nameReg).call(payload);
require(success);
```

所有这些函数都是低级函数，应谨慎使用。具体来说，任何未知的合约都可能是恶意的，如果你调用它，你会将控制权移交给该合约，该合约又可能会回调到你的合约中，因此请准备好在调用返回时更改你的状态变量。与其他合约交互的常规方式是在合约对象 (x.f()) 上调用函数。

> Solidity 的先前版本允许这些函数接收任意参数，并且还会以不同的方式处理 bytes4 类型的第一个参数。这些边缘情况已在 0.5.0 版中删除。

可以使用气体调节器调整供应的气体：

```
address(nameReg).call{gas: 1000000}(abi.encodeWithSignature("register(string)", "MyName"));
```

同样，提供的 Ether 值也可以控制：

```
address(nameReg).call{value: 1 ether}(abi.encodeWithSignature("register(string)", "MyName"));
```

最后，可以组合这些修饰符。他们的顺序无关紧要：

```
address(nameReg).call{gas: 1000000, value: 1 ether}(abi.encodeWithSignature("register(string)", "MyName"));
```

类似地，可以使用函数delegatecall：不同的是只使用给定地址的代码，所有其他方面（存储，余额，...）都取自当前合约。 delegatecall 的目的是使用存储在另一个合约中的库代码。用户必须确保两个合约中的存储布局都适合要使用的 delegatecall。


在 homestead 之前，只有一个称为 callcode 的有限变体可用，它不提供对原始 msg.sender 和 msg.value 值的访问。 此功能在 0.5.0 版本中被移除。

由于 byzantium staticcall 也可以使用。 这与 call 基本相同，但如果被调用的函数以任何方式修改状态，则会恢复。

call、delegatecall 和 staticcall 这三个函数都是非常低级的函数，只能作为最后的手段使用，因为它们破坏了 Solidity 的类型安全性。

gas 选项可用于所有三种方法，而 value 选项仅在调用时可用。

最好避免在智能合约代码中依赖硬编码的 gas 值，无论是读取还是写入状态，因为这可能有很多陷阱。 此外，未来对天然气的获取可能会发生变化。


所有合约都可以转换为地址类型，因此可以使用address(this).balance查询当前合约的余额。

### Contract Types合约类型

每个合约都定义了自己的类型。您可以将合约隐式转换为它们继承的合约。合约可以显式转换为地址类型或从地址类型转换。

只有当合同类型具有接收或应付回退功能时，才可能与地址应付类型进行显式转换。转换仍然使用 address(x) 执行。如果合同类型没有接收或应付回退功能，则可以使用payable(address(x))转换为应付地址。您可以在有关地址类型的部分中找到更多信息。

在0.5.0版本之前，合约直接从地址类型派生，没有地址和应付地址的区别。

如果你声明一个合约类型的局部变量（MyContract c），你可以调用该合约的函数。请注意从相同合同类型的某个地方分配它。

您还可以实例化合约（这意味着它们是新创建的）。您可以在“新合同”部分找到更多详细信息。

合约的数据表示与地址类型的数据表示相同，并且在 ABI 中也使用这种类型。

合约不支持任何运营商。

合约类型的成员是合约的外部函数，包括标记为 public 的任何状态变量。

对于合约 C，您可以使用 type(C) 来访问有关合约的类型信息。

### Fixed-size byte arrays固定大小的字节数组

值类型 bytes1、bytes2、bytes3、...、bytes32 包含从 1 到 32 的字节序列。

操作运算符：

比较：<=、<、==、!=、>=、>

位运算符：&、|、^（按位异或）、~（按位取反）

移位运算符：<<（左移）、>>（右移）

索引访问：如果 x 是 bytesI 类型，则 x[k] for 0 <= k < I 返回第 k 个字节（只读）。

移位运算符使用无符号整数类型作为右操作数（但返回左操作数的类型），表示要移位的位数。 按有符号类型进行移位将产生编译错误。

成员：

.length 产生字节数组的固定长度（只读）。

类型 bytes1[] 是一个字节数组，但由于填充规则，它为每个元素浪费了 31 个字节的空间（存储除外）。 最好改用字节类型。

在 0.8.0 版本之前，byte 曾经是 bytes1 的别名。

### Dynamically-sized byte arrays动态大小的字节数组

字节：
动态大小的字节数组，请参阅数组。 不是值类型！

字符串：
动态大小的 UTF-8 编码字符串，请参阅数组。 不是值类型！

### Address Literals (地址字面量)

通过地址校验和测试的十六进制文字，例如 0xdCad3a6d3569DF655070DEd06cb7A1b2Ccd1D3AF 属于地址类型。 长度在 39 到 41 位之间且未通过校验和测试的十六进制文字会产生错误。 您可以预先（对于整数类型）或附加（对于 bytesNN 类型）零以消除错误。

EIP-55 中定义了大小写混合的地址校验和格式。

### Rational and Integer Literals(有理数和整数字面量)

整数文字由 0-9 范围内的数字序列构成。它们被解释为小数。例如，69 表示六十九。 Solidity 中不存在八进制文字，前导零无效。

小数部分文字由 a 组成。一侧至少有一个数字。示例包括 1.、.1 和 1.3。

还支持科学记数法，其中基数可以有分数而指数不能。示例包括 2e10、-2e10、2e-10、2.5e1。

下划线可用于分隔数字文字的数字以提高可读性。例如，十进制 123_000、十六进制 0x2eff_abde、科学十进制记数法 1_2e345_678 都是有效的。下划线只允许在两位数之间，并且只允许有一个连续的下划线。没有向包含下划线的数字文字添加额外的语义含义，下划线被忽略。

数字文字表达式保留任意精度，直到它们被转换为非文字类型（即通过将它们与非文字表达式一起使用或通过显式转换）。这意味着计算不会溢出并且除法不会在数字文字表达式中截断。

例如，(2**800 + 1) - 2**800 导致常量 1（类型 uint8），尽管中间结果甚至不适合机器字的大小。此外，0.5 * 8 导致整数 4（尽管中间使用了非整数）。

只要操作数是整数，任何可以应用于整数的运算符也可以应用于数字文字表达式。如果两者中的任何一个是小数，则不允许位运算，如果指数是小数，则不允许取幂（因为这可能导致非有理数）。

将文字数作为左（或基）操作数和整数类型作为右（指数）操作数的移位和求幂总是在 uint256（对于非负文字）或 int256（对于负文字）类型中执行，而不管类型如何右（指数）操作数的。

警告

在 0.4.0 版本之前的 Solidity 中用于截断整数文字的除法，但现在转换为有理数，即 5 / 2 不等于 2，而是等于 2.5。

笔记

Solidity 对每个有理数都有一个数字文字类型。整数文字和有理数文字属于数字文字类型。此外，所有数字字面量表达式（即仅包含数字字面量和运算符的表达式）都属于数字字面量类型。因此，数字字面量表达式 1 + 2 和 2 + 1 都属于有理数 3 的相同数字字面量类型。

笔记

数字文字表达式一旦与非文字表达式一起使用，就会转换为非文字类型。不考虑类型，下面分配给 b 的表达式的值计算为整数。因为 a 是 uint128 类型，所以表达式 2.5 + a 必须有一个正确的类型。由于2.5和uint128的类型没有通用类型，所以Solidity编译器不接受这段代码。

```
uint128 a = 1;
uint128 b = 2.5 + a + 0.5；
```

### String Literals and Types(字符串字面量和类型)

字符串文字用双引号或单引号（“foo”或“bar”）书写，它们也可以分成多个连续的部分（“foo”“bar”等价于“foobar”），这在以下情况下会很有帮助处理长字符串。它们并不像 C 中那样暗示尾随零； “foo”代表三个字节，而不是四个。与整数文字一样，它们的类型可以变化，但它们可以隐式转换为 bytes1、...、bytes32（如果它们适合的话）到字节和字符串。

例如，使用 bytes32 samevar = "stringliteral" 字符串文字在分配给 bytes32 类型时以其原始字节形式解释。

字符串文字只能包含可打印的 ASCII 字符，这意味着介于 0x1F .. 0x7E 之间的字符。

此外，字符串文字还支持以下转义字符：

\<newline>（转义实际的换行符）

\\（反斜杠）

\'（单引号）

\"（双引号）

\n（换行）

\r（回车）

\t（制表符）

\xNN（十六进制转义，见下文）

\uNNNN（Unicode 转义，见下文）

\xNN 采用十六进制值并插入适当的字节，而 \uNNNN 采用 Unicode 代码点并插入 UTF-8 序列。

笔记

在 0.8.0 版本之前，还有三个额外的转义序列：\b、\f 和 \v。它们通常以其他语言提供，但在实践中很少需要。如果您确实需要它们，它们仍然可以通过十六进制转义插入，即分别为 \x08、\x0c 和 \x0b，就像任何其他 ASCII 字符一样。

以下示例中的字符串长度为十个字节。它以换行字节开头，后跟双引号、单引号、反斜杠字符，然后是（不带分隔符）字符序列 abcdef。

"\n\"\'\\abc\
定义”
任何不是换行符的 Unicode 行终止符（即 LF、VF、FF、CR、NEL、LS、PS）都被视为终止字符串文字。换行符仅在字符串文字前面没有 \ 时才终止。

### Unicode Literals(Unicode字面量)

虽然常规字符串文字只能包含 ASCII，但 Unicode 文字（以关键字 unicode 为前缀）可以包含任何有效的 UTF-8 序列。它们还支持与常规字符串文字非常相同的转义序列。

字符串内存 a = unicode"你好😃";

### Hexadecimal Literals(十六进制字面量)

十六进制文字以关键字 hex 为前缀，并用双引号或单引号括起来（hex"001122FF", hex'0011_22_FF'）。它们的内容必须是十六进制数字，可以选择使用单个下划线作为字节边界之间的分隔符。文字的值将是十六进制序列的二进制表示。

由空格分隔的多个十六进制文字连接成单个文字：hex"00112233" hex"44556677" 等效于 hex"0011223344556677"

十六进制文字的行为类似于字符串文字，并具有相同的可转换性限制。

### 枚举

枚举是在 Solidity 中创建用户定义类型的一种方法。它们可以与所有整数类型显式转换，但不允许隐式转换。整数的显式转换在运行时检查该值是否在枚举范围内，否则会导致 Panic 错误。枚举需要至少一个成员，并且其声明时的默认值是第一个成员。枚举不能超过 256 个成员。

数据表示与 C 中的枚举相同：选项由从 0 开始的后续无符号整数值表示。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract test {
    enum ActionChoices { GoLeft, GoRight, GoStraight, SitStill }
    ActionChoices choice;
    ActionChoices constant defaultChoice = ActionChoices.GoStraight;

    function setGoStraight() public {
        choice = ActionChoices.GoStraight;
    }

    // Since enum types are not part of the ABI, the signature of "getChoice"
    // will automatically be changed to "getChoice() returns (uint8)"
    // for all matters external to Solidity.
    function getChoice() public view returns (ActionChoices) {
        return choice;
    }

    function getDefaultChoice() public pure returns (uint) {
        return uint(defaultChoice);
    }
}
```

枚举也可以在文件级别上声明，在合同或库定义之外。

### 函数类型

函数类型是函数的类型。函数类型的变量可以从函数中赋值，函数类型的函数参数可以用来将函数传递给函数调用并从函数调用中返回函数。函数类型有两种风格 - 内部函数和外部函数：

内部函数只能在当前合约内部调用（更具体地说，在当前代码单元内部，也包括内部库函数和继承函数），因为它们不能在当前合约的上下文之外执行。调用内部函数是通过跳转到其入口标签来实现的，就像内部调用当前合约的函数一样。

外部函数由地址和函数签名组成，它们可以通过外部函数调用传递和返回。

函数类型标记如下：

函数 (<参数类型>) {internal|external} [pure|view|payable] [returns (<return types>)]
与参数类型相反，返回类型不能为空 - 如果函数类型不应返回任何内容，则必须省略整个返回（<返回类型>）部分。

默认情况下，函数类型是内部的，因此可以省略 internal 关键字。请注意，这仅适用于函数类型。必须为合同中定义的函数明确指定可见性，它们没有默认值。

转换：

函数类型 A 可隐式转换为函数类型 B 当且仅当它们的参数类型相同、返回类型相同、内部/外部属性相同且 A 的状态可变性比 B 的状态可变性更具限制性。 特别是：

纯函数可以转换为视图和非支付函数

视图函数可以转换为非支付函数

应付功能可以转换为非应付功能

函数类型之间无法进行其他转换。

关于应付和不可支付的规则可能有点混乱，但本质上，如果一个函数是可支付的，这意味着它也接受零以太币的支付，所以它也是不可支付的。另一方面，不可支付的功能会拒绝发送给它的以太币，因此不可支付的功能无法转换为可支付的功能。

如果函数类型变量未初始化，调用它会导致 Panic 错误。如果在对函数使用 delete 之后调用函数，也会发生同样的情况。

如果在 Solidity 的上下文之外使用外部函数类型，它们将被视为函数类型，它将地址后跟函数标识符一起编码为单个 bytes24 类型。

请注意，当前合约的公共功能既可以用作内部功能，也可以用作外部功能。要将f用作内部函数，只需使用f，如果要使用其外部形式，则使用this.f。

内部类型的函数可以分配给内部函数类型的变量，而不管它在哪里定义。这包括合同和图书馆的私有、内部和公共功能以及免费功能。另一方面，外部函数类型仅与公共和外部合约函数兼容。库被排除在外，因为它们需要委托调用并为其选择器使用不同的 ABI 约定。在接口中声明的函数没有定义，因此指向它们也没有意义。

成员：

外部（或公共）函数具有以下成员：

.address 返回函数合约的地址。

.selector 返回 ABI 函数选择器

笔记

用于具有附加成员 .gas(uint) 和 .value(uint) 的外部（或公共）函数。这些在 Solidity 0.6.2 中被弃用，在 Solidity 0.7.0 中被移除。而是使用 {gas: ...} 和 {value: ...} 分别指定发送给函数的 gas 量或 wei 量。有关更多信息，请参阅外部函数调用。

显示如何使用成员的示例：

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.4 <0.9.0;

contract Example {
    function f() public payable returns (bytes4) {
        assert(this.f.address == address(this));
        return this.f.selector;
    }

    function g() public {
        this.f{gas: 10, value: 800}();
    }
}
```

显示如何使用内部函数类型的示例：

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

library ArrayUtils {
    // internal functions can be used in internal library functions because
    // they will be part of the same code context
    function map(uint[] memory self, function (uint) pure returns (uint) f)
        internal
        pure
        returns (uint[] memory r)
    {
        r = new uint[](self.length);
        for (uint i = 0; i < self.length; i++) {
            r[i] = f(self[i]);
        }
    }

    function reduce(
        uint[] memory self,
        function (uint, uint) pure returns (uint) f
    )
        internal
        pure
        returns (uint r)
    {
        r = self[0];
        for (uint i = 1; i < self.length; i++) {
            r = f(r, self[i]);
        }
    }

    function range(uint length) internal pure returns (uint[] memory r) {
        r = new uint[](length);
        for (uint i = 0; i < r.length; i++) {
            r[i] = i;
        }
    }
}


contract Pyramid {
    using ArrayUtils for *;

    function pyramid(uint l) public pure returns (uint) {
        return ArrayUtils.range(l).map(square).reduce(sum);
    }

    function square(uint x) internal pure returns (uint) {
        return x * x;
    }

    function sum(uint x, uint y) internal pure returns (uint) {
        return x + y;
    }
}

```

另一个使用外部函数类型的例子：

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;


contract Oracle {
    struct Request {
        bytes data;
        function(uint) external callback;
    }

    Request[] private requests;
    event NewRequest(uint);

    function query(bytes memory data, function(uint) external callback) public {
        requests.push(Request(data, callback));
        emit NewRequest(requests.length - 1);
    }

    function reply(uint requestID, uint response) public {
        // Here goes the check that the reply comes from a trusted source
        requests[requestID].callback(response);
    }
}


contract OracleUser {
    Oracle constant private ORACLE_CONST = Oracle(address(0x00000000219ab540356cBB839Cbe05303d7705Fa)); // known contract
    uint private exchangeRate;

    function buySomething() public {
        ORACLE_CONST.query("USD", this.oracleResponse);
    }

    function oracleResponse(uint response) public {
        require(
            msg.sender == address(ORACLE_CONST),
            "Only oracle can call this."
        );
        exchangeRate = response;
    }
}
```

Lambda 或内联函数已计划但尚不支持。

## 引用类型




## 映射类型


## Operators Involving LValues



## Conversions between Elementary Types(基本类型之间的转换)



## Conversions between Literals and Elementary Types(字面量和基本类型之间的转换)

