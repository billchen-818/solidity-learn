# Uints and Global Variables

## Ether单位

数字字面量可以采用`wei`、`gwei`或`ether`的后缀来指定Ether的子面额，其中没有后缀的Ether数字被假定为Wei。

```
assert(1 wei == 1);
assert(1 gwei == 1e9);
assert(1 ether == 1e18);
```

子面额后缀的唯一作用是乘以10的幂。

finney 和 szabo 面额已在 0.7.0 版中删除。

## 时间单位

字面数字后的后缀如秒、分钟、小时、天和周可用于指定时间单位，其中秒是基本单位，单位以以下方式被天真地考虑：

- `1 == 1 seconds`
- `1 minutes == 60 seconds`
- `1 hours == 60 minutes`
- `1 days == 24 hours`
- `1 week == 7 days`

如果您使用这些单位执行日历计算，请注意，因为不是每年都等于 365 天，甚至不是每天都有 24 小时，因为闰秒。 由于无法预测闰秒，因此必须通过外部预言机更新精确的日历库。

> 由于上述原因，后缀年份已在 0.5.0 版本中删除。

这些后缀不能应用于变量。 例如，如果你想以天为单位解释一个函数参数，你可以通过以下方式：

```
function f(uint start, uint daysAfter) public {
    if (block.timestamp >= start + daysAfter * 1 days) {
      // ...
    }
}
```

## 特殊变量和函数

全局命名空间中始终存在一些特殊的变量和函数，主要用于提供有关区块链的信息或者是通用的实用函数。

### 区块和交易属性

- `blockhash(uint blockNumber) returns (byte32)`:hash of the given block when `blocknumber` is one of the 256 most recent blocks; otherwise returns zero
- `block.basefee(uint)`:current block's base fee(EIP-3198) and (EIP-1559)
- `block.chainid (uint)`: current chain id
- `block.coinbase (address payable)`: current block miner’s address
- `block.difficulty (uint)`: current block difficulty
- `block.gaslimit (uint)`: current block gaslimit
- `block.number (uint)`: current block number
- `block.timestamp (uint)`: current block timestamp as seconds since unix epoch
- `gasleft() returns (uint256)`: remaining gas
- `msg.data (bytes calldata)`: complete calldata
- `msg.sender (address)`: sender of the message (current call)
- `msg.sig (bytes4)`: first four bytes of the calldata (i.e. function identifier)
- `msg.value (uint)`: number of wei sent with the message
- `tx.gasprice (uint)`: gas price of the transaction
- `tx.origin (address)`: sender of the transaction (full call chain)

> msg 的所有成员，包括 msg.sender 和 msg.value 的值都可以为每个外部函数调用而改变。 这包括对库函数的调用。

> 不要依赖 block.timestamp 或 blockhash 作为随机源，除非你知道自己在做什么。

> 时间戳和区块哈希都可能在某种程度上受到矿工的影响。 例如，采矿社区中的不良参与者可以在选定的哈希上运行赌场支付功能，如果他们没有收到任何钱，则只需重试不同的哈希即可。

> 当前区块时间戳必须严格大于最后一个区块的时间戳，但唯一的保证是它会在规范链中两个连续区块的时间戳之间。

> 出于可扩展性的原因，并非所有块都可以使用块哈希。 您只能访问最近 256 个块的哈希值，所有其他值都为零。

> 函数 blockhash 以前称为 block.blockhash，它在 0.4.22 版本中被弃用并在 0.5.0 版本中删除。

> 函数 gasleft 以前称为 msg.gas，它在 0.4.21 版本中被弃用并在 0.5.0 版本中删除。

> 在 0.7.0 版本中，现在的别名（用于 block.timestamp）被删除。

### ABI编码和解码函数

- ·、`abi.decode(bytes memory encodedData, (...)) returns (...)`: ABI-decodes the given data, while the types are given in parentheses as second argument. Example: `(uint a, uint[2] memory b, bytes memory c) = abi.decode(data, (uint, uint[2], bytes))`
- `abi.encode(...) returns (bytes memory)`: ABI-encodes the given arguments
- `abi.encodePacked(...) returns (bytes memory)`: Performs packed encoding of the given arguments. Note that packed encoding can be ambiguous!
- `abi.encodeWithSelector(bytes4 selector, ...) returns (bytes memory)`: ABI-encodes the given arguments starting from the second and prepends the given four-byte selector
- `abi.encodeWithSignature(string memory signature, ...) returns (bytes memory)`: Equivalent to `abi.encodeWithSelector(bytes4(keccak256(bytes(signature))), ...)`

这些编码函数可用于为外部函数调用制作数据，而无需实际调用外部函数。 此外，`keccak256(abi.encodePacked(a, b))` 是一种计算结构化数据散列的方法（但请注意，可以使用不同的函数参数类型来制造“散列冲突”）。

有关编码的详细信息，请参阅有关 ABI 和紧密打包编码的文档。

### 字节成员

`bytes.concat(...) returns (bytes memory)`: Concatenates variable number of bytes and bytes1, …, bytes32 arguments to one byte array

### 错误处理

有关错误处理以及何时使用哪个函数的更多详细信息，请参阅有关 assert 和 require 的专用部分。

- `assert(bool condition)`

如果条件不满足，则会导致 Panic 错误，从而恢复状态更改 - 用于内部错误。

- `require(bool condition)`

如果条件不满足，则恢复 - 用于输入或外部组件中的错误。

- `require(bool condition, string memory message)`

如果条件不满足，则恢复 - 用于输入或外部组件中的错误。 还提供错误信息。

- `revert()`

中止执行并恢复状态更改

- `revert(string memory reason)`

中止执行并恢复状态更改，提供解释性字符串

### 数学和密码函数

- `addmod(uint x, uint y, uint k) returns (uint)`

compute (x + y) % k where the addition is performed with arbitrary precision and does not wrap around at 2**256. Assert that k != 0 starting from version 0.5.0.

- `mulmod(uint x, uint y, uint k) returns (uint)`

compute (x * y) % k where the multiplication is performed with arbitrary precision and does not wrap around at 2**256. Assert that k != 0 starting from version 0.5.0.

- `keccak256(bytes memory) returns (bytes32)`

compute the Keccak-256 hash of the input

> keccak256 曾经有一个别名叫做 sha3，它在 0.5.0 版本中被删除了。 

- `sha256(bytes memory) returns (bytes32)`

compute the SHA-256 hash of the input

- `ripemd160(bytes memory) returns (bytes20)`

compute RIPEMD-160 hash of the input

- `ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) returns (address)`

recover the address associated with the public key from elliptic curve signature or return zero on error. The function parameters correspond to ECDSA values of the signature:
- - r = first 32 bytes of signature
- - s = second 32 bytes of signature
- - v = final 1 byte of signature


ecrecover 返回地址，而不是应付地址。如果您需要将资金转移到恢复的地址，请参阅支付转换地址。

有关更多详细信息，请阅读示例用法。

>如果您使用 ecrecover，请注意可以将有效签名转换为不同的有效签名，而无需了解相应的私钥。在 Homestead 硬分叉中，此问题已针对 _transaction_ 签名（参见 EIP-2）修复，但 ecrecover 功能保持不变。

>这通常不是问题，除非您要求签名是唯一的或使用它们来识别项目。 OpenZeppelin 有一个 ECDSA 帮助程序库，您可以将其用作 ecrecover 的包装器，而不会出现此问题。


> 在私有区块链上运行 sha256、ripemd160 或 ecrecover 时，可能会遇到 Out-of-Gas。这是因为这些函数被实现为“预编译合约”，并且只有在它们收到第一条消息后才真正存在（尽管它们的合约代码是硬编码的）。向不存在的合约发送消息的成本更高，因此执行可能会遇到 Out-of-Gas 错误。此问题的解决方法是先将 Wei（例如 1）发送到每个合同，然后再在实际合同中使用它们。这不是主网上或测试网上的问题。

### 地址类型成员

- `<address>.balance (uint256)`:balance of the Address in Wei
- `<address>.code (bytes memory)`:code at the Address (can be empty)
- `<address>.codehash (bytes32)`:the codehash of the Address
- `<address payable>.transfer(uint256 amount)`:send given amount of Wei to Address, reverts on failure, forwards 2300 gas stipend, not adjustable
- `<address payable>.send(uint256 amount) returns (bool)`:send given amount of Wei to Address, returns false on failure, forwards 2300 gas stipend, not adjustable
- `<address>.call(bytes memory) returns (bool, bytes memory)`:issue low-level CALL with the given payload, returns success condition and return data, forwards all available gas, adjustable
- `<address>.delegatecall(bytes memory) returns (bool, bytes memory)`:issue low-level DELEGATECALL with the given payload, returns success condition and return data, forwards all available gas, adjustable
- `<address>.staticcall(bytes memory) returns (bool, bytes memory)`:issue low-level STATICCALL with the given payload, returns success condition and return data, forwards all available gas, adjustable

有关更多信息，请参阅地址部分。

>在执行另一个合约函数时，您应该尽可能避免使用 .call()，因为它会绕过类型检查、函数存在性检查和参数打包。

>使用 send 有一些危险：如果调用堆栈深度为 1024（这总是可以由调用者强制），则传输失败，如果接收者耗尽 gas，传输也会失败。 因此，为了进行安全的 Ether 转账，请始终检查 send 的返回值，使用 transfer 甚至更好：使用收款人提取资金的模式。

>由于 EVM 认为对不存在的合约的调用总是成功的，Solidity 在执行外部调用时包括使用 extcodesize 操作码的额外检查。 这确保了即将被调用的合约要么实际存在（它包含代码）要么引发异常。

>对地址而不是合约实例进行操作的低级调用（即 .call()、.delegatecall()、.staticcall()、.send() 和 .transfer()）不包括此检查，这使得它们更便宜 在燃气方面也不太安全。

>在 0.5.0 版本之前，Solidity 允许合约实例访问地址成员，例如 this.balance。 现在禁止这样做，必须进行显式转换为地址：address(this).balance。

>如果通过低级委托调用访问状态变量，则两个合约的存储布局必须对齐，以便被调用合约按名称正确访问调用合约的存储变量。 如果像高级库那样将存储指针作为函数参数传递，则情况当然不是这样。

>在 0.5.0 版本之前，.call、.delegatecall 和 .staticcall 只返回成功条件，不返回返回数据。

>在 0.5.0 版本之前，有一个名为 callcode 的成员，其语义与 delegatecall 相似但略有不同。

### 合约相关

- `this(current contract's type)`:当前合约，明确可转换为 Address
- `selfdestruct(address payable recipient)`:销毁当前合约，将其资金发送到给定地址并结束执行。 请注意，selfdestruct 有一些从 EVM 继承的特性：
  - 接收合约的接收函数没有执行。
  - 合约仅在交易结束时才被真正销毁，而 revert s 可能会“撤消”销毁。

此外，当前合约的所有功能都可以直接调用，包括当前功能。

>在 0.5.0 版本之前，有一个名为suicide的函数，其语义与 selfdestruct 相同。

### 类型信息

表达式 type(X) 可用于检索有关类型 X 的信息。目前，对该功能的支持有限（X 可以是合约或整数类型），但将来可能会扩展。

以下属性可用于合同类型 C：

- `type(C).name`:合同名称。
- `type(C).creationCode`:包含合约创建字节码的内存字节数组。这可用于内联汇编以构建自定义创建例程，尤其是通过使用 create2 操作码。此属性不能在合约本身或任何派生合约中访问。它导致字节码包含在调用站点的字节码中，因此不可能进行这样的循环引用。
- `type(C).runtimeCode`:包含合约运行时字节码的内存字节数组。这是通常由 C 的构造函数部署的代码。如果 C 有一个使用内联汇编的构造函数，这可能与实际部署的字节码不同。另请注意，库在部署时修改其运行时字节码以防止常规调用。与 .creationCode 相同的限制也适用于此属性。

除了上述属性外，接口类型 I 还具有以下属性：

`type(I).interfaceId`:包含给定接口 I 的 EIP-165 接口标识符的 bytes4 值。该标识符被定义为接口本身内定义的所有函数选择器的异或 - 不包括所有继承的函数。

以下属性可用于整数类型 T：

- `tye(T).min`:类型 T 可表示的最小值。
- `type(T).max`:类型 T 可表示的最大值。