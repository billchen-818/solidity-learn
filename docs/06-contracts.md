# Contracts合约

solidity中的合约类似于面向对象语言中的类。它们在状态变量中包含持久数据，以及可以修改这些变量的函数。在不同合约(实例)上调用函数将执行EVM函数调用，从而切换上下文，使得调用合约中的状态变量不可访问。任何事情都需要调用合约及其函数方法。以太坊中没有"cron"概念来在特定事件中自动调用函数。

## Creating Contracts(创建合约)

可以通过以太坊交易从外部创建合约或者从solidity合约内部创建合约。

IDE(例如Remix)使用UI元素使创建过程无缝衔接。

在以太坊上以编程方式创建合约的一种方法是通过JavaScript API web3.js。使用名为web3.eth.Contract的函数可以更容易的来创建合约。

当一个合约被创建时，它的构造函数（一个用constructor关键字声明的函数）被执行一次。

构造函数是可选的。只允许一个构造函数，这意味着不支持重载。

构造函数执行后，合约的最终代码存储在区块链上。 此代码包括所有公共和外部函数以及可通过函数调用从那里访问的所有函数。 部署的代码不包括构造函数代码或仅从构造函数调用的内部函数。

在内部，构造函数参数在合约本身的代码之后通过 ABI 编码传递，但如果您使用 web3.js，则不必关心这一点。

如果一个合约想要创建另一个合约，创建者必须知道所创建合约的源代码（和二进制文件）。 这意味着循环创建依赖是不可能的。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;


contract OwnedToken {
    // `TokenCreator` is a contract type that is defined below.
    // It is fine to reference it as long as it is not used
    // to create a new contract.
    TokenCreator creator;
    address owner;
    bytes32 name;

    // This is the constructor which registers the
    // creator and the assigned name.
    constructor(bytes32 _name) {
        // State variables are accessed via their name
        // and not via e.g. `this.owner`. Functions can
        // be accessed directly or through `this.f`,
        // but the latter provides an external view
        // to the function. Especially in the constructor,
        // you should not access functions externally,
        // because the function does not exist yet.
        // See the next section for details.
        owner = msg.sender;

        // We perform an explicit type conversion from `address`
        // to `TokenCreator` and assume that the type of
        // the calling contract is `TokenCreator`, there is
        // no real way to verify that.
        // This does not create a new contract.
        creator = TokenCreator(msg.sender);
        name = _name;
    }

    function changeName(bytes32 newName) public {
        // Only the creator can alter the name.
        // We compare the contract based on its
        // address which can be retrieved by
        // explicit conversion to address.
        if (msg.sender == address(creator))
            name = newName;
    }

    function transfer(address newOwner) public {
        // Only the current owner can transfer the token.
        if (msg.sender != owner) return;

        // We ask the creator contract if the transfer
        // should proceed by using a function of the
        // `TokenCreator` contract defined below. If
        // the call fails (e.g. due to out-of-gas),
        // the execution also fails here.
        if (creator.isTokenTransferOK(owner, newOwner))
            owner = newOwner;
    }
}


contract TokenCreator {
    function createToken(bytes32 name)
        public
        returns (OwnedToken tokenAddress)
    {
        // Create a new `Token` contract and return its address.
        // From the JavaScript side, the return type
        // of this function is `address`, as this is
        // the closest type available in the ABI.
        return new OwnedToken(name);
    }

    function changeName(OwnedToken tokenAddress, bytes32 name) public {
        // Again, the external type of `tokenAddress` is
        // simply `address`.
        tokenAddress.changeName(name);
    }

    // Perform checks to determine if transferring a token to the
    // `OwnedToken` contract should proceed
    function isTokenTransferOK(address currentOwner, address newOwner)
        public
        pure
        returns (bool ok)
    {
        // Check an arbitrary condition to see if transfer should proceed
        return keccak256(abi.encodePacked(currentOwner, newOwner))[0] == 0x7f;
    }
}
```

## 可见性与Getters

solidity拥有两种函数调用：不创建实际EVM调用(也称为消息调用)的内部调用和创建EVM的外部调用。所以，函数和状态变量有四种类型的可见性。

函数必须指定为`external`、`public`、`internal`和`private`。对于状态变量，不包括`external`。

- external(外部的)：external修饰的函数是合约接口的一部分，它们可以从其它合约和通过交易调用。外部函数不能在内部调用(f()不起作用，this.f()起作用)
- public(公共的)：公共函数是合约接口的一部分，可以在内部或者通过消息调用。对于公共状态变量，会自动生成一个getter函数。
- internal：这些函数和状态变量只能在内部访问(即从当前合约或从它派生的合约中)，而不能使用this。状态变量的默认可见性级别就是internal。
- private：私有函数和状态变量仅对定义它们的合约可见，在派生合约中不可见。

> 合约中的所有内容对区块链外部的所有观察者都是可见的。将某些东西定义为`private`只会阻止其它合约读取或修改信息，但它仍然对区块链之外的整个世界可见。

可见性说明符在状态变量的类型之后以及函数的参数列表和返回参数列表之间。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract C {
    function f(uint a) private pure returns (uint b) { return a + 1; }
    function setData(uint a) internal { data = a; }
    uint public data;
}
```

以下合约中，D可以调用c.getData()来检索状态存储中的数据值，但不能调用f。合约E派生自C，因此可以调用compute。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract C {
    uint private data;

    function f(uint a) private pure returns(uint b) { return a + 1; }
    function setData(uint a) public { data = a; }
    function getData() public view returns(uint) { return data; }
    function compute(uint a, uint b) internal pure returns (uint) { return a + b; }
}

// This will not compile
contract D {
    function readData() public {
        C c = new C();
        uint local = c.f(7); // error: member `f` is not visible
        c.setData(3);
        local = c.getData();
        local = c.compute(3, 5); // error: member `compute` is not visible
    }
}

contract E is C {
    function g() public {
        C c = new C();
        uint val = compute(3, 5); // access to internal member (from derived to parent contract)
    }
}
```

### Getter Functions

编译器会自动为所有公共状态变量创建getter函数。对于下面给出的合约，编译器将生成一个名为data的函数，该函数不接受任何参数并返回一个uint，即状态变量data的值。状态变量可以在声明时进行初始化。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract C {
    uint public data = 42;
}

contract Caller {
    C c = new C();
    function f() public view returns (uint) {
        return c.data();
    }
}
```

getter函数具有外部(external)可见性，如果在内部被访问(即没有使用`this.`),它会被评估为状态变量；如果从外部访问(即使用`this.`)，它会被评估为一个函数。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;

contract C {
    uint public data;
    function x() public returns (uint) {
        data = 3; // internal access
        return this.data(); // external access
    }
}
```

如果你有一个数组类型的公共状态变量，那么你只能通过生成的getter函数检索数组的单个元素。这种机制的存在是为了避免在返回整个数组时产生高昂的gas成本。你可以使用参数来指定要返回的单个元素，例如myArray(0)。如果要在一次调用中返回整个数组，则需要编写一个函数，例如：

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract arrayExample {
    // public state variable
    uint[] public myArray;

    // Getter function generated by the compiler
    /*
    function myArray(uint i) public view returns (uint) {
        return myArray[i];
    }
    */

    // function that returns entire array
    function getArray() public view returns (uint[] memory) {
        return myArray;
    }
}
```

现在你可以使用getArray()来检索整个数组，而不是myArray(i)。后者每次调用返回一个元素。

下一个例子更复杂：

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;

contract Complex {
    struct Data {
        uint a;
        bytes3 b;
        mapping (uint => uint) map;
        uint[3] c;
        uint[] d;
        bytes e;
    }
    mapping (uint => mapping(bool => Data[])) public data;
}
```

它生成以下形式的函数。结构体中的映射和数组(除字节数组外)被省略，因为没有好的方法来选择单个结构成员或为映射提供键：

```
function data(uint arg1, bool arg2, uint arg3)
    public
    returns (uint a, bytes3 b, bytes memory e)
{
    a = data[arg1][arg2][arg3].a;
    b = data[arg1][arg2][arg3].b;
    e = data[arg1][arg2][arg3].e;
}
```

## 函数修饰符

函数修饰符可以用于已声明方式更改函数的行为。例如，可以使用修饰符在执行函数之前自动检查条件。

修饰符是合约的可继承属性，可以被派生合约覆盖，但前提是它被标记为`virtual`。有关详细信息请参阅修饰符覆盖。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.1 <0.9.0;

contract owned {
    constructor() { owner = payable(msg.sender); }
    address payable owner;

    // This contract only defines a modifier but does not use
    // it: it will be used in derived contracts.
    // The function body is inserted where the special symbol
    // `_;` in the definition of a modifier appears.
    // This means that if the owner calls this function, the
    // function is executed and otherwise, an exception is
    // thrown.
    modifier onlyOwner {
        require(
            msg.sender == owner,
            "Only owner can call this function."
        );
        _;
    }
}

contract destructible is owned {
    // This contract inherits the `onlyOwner` modifier from
    // `owned` and applies it to the `destroy` function, which
    // causes that calls to `destroy` only have an effect if
    // they are made by the stored owner.
    function destroy() public onlyOwner {
        selfdestruct(owner);
    }
}

contract priced {
    // Modifiers can receive arguments:
    modifier costs(uint price) {
        if (msg.value >= price) {
            _;
        }
    }
}

contract Register is priced, destructible {
    mapping (address => bool) registeredAddresses;
    uint price;

    constructor(uint initialPrice) { price = initialPrice; }

    // It is important to also provide the
    // `payable` keyword here, otherwise the function will
    // automatically reject all Ether sent to it.
    function register() public payable costs(price) {
        registeredAddresses[msg.sender] = true;
    }

    function changePrice(uint _price) public onlyOwner {
        price = _price;
    }
}

contract Mutex {
    bool locked;
    modifier noReentrancy() {
        require(
            !locked,
            "Reentrant call."
        );
        locked = true;
        _;
        locked = false;
    }

    /// This function is protected by a mutex, which means that
    /// reentrant calls from within `msg.sender.call` cannot call `f` again.
    /// The `return 7` statement assigns 7 to the return value but still
    /// executes the statement `locked = false` in the modifier.
    function f() public noReentrancy returns (uint) {
        (bool success,) = msg.sender.call("");
        require(success);
        return 7;
    }
}
```

如果要访问合约C中定义的修饰符m,则可以使用C.m来引用它，而无需虚拟查找。只能使用在当前合约中或其基础合约中定义的修饰符。修饰符也可以在库中定义，但它的使用权仅限于同一库的函数。

多个修饰符通常在以空格分隔的列表中指定它们来应用于函数，并按显示的顺序进行评估。

修饰符不能隐式访问或更改它们修饰的函数的参数和返回值。它们的值只能在调用时显式传递给它们。

修饰符或函数体的显式返回只保留当前的修饰符或函数体。返回变量被赋值，控制流在前面修饰符中的`_`之后继续。

> 在solidity的早期版本中，具有修饰符的函数中的return语句变相不同。

来自带有return的修饰符的显式返回，不影响函数返回的值。然而，修饰符可以选择根本不执行函数体，在这种情况下，返回变量被设置为它们的默认值，就像函数有一个空体一样。

`_`符号可以多次出现在修饰符中。每次出现都替换为函数体。

修饰符参数允许使用任意表达式，在此上下文中，从函数可见的所有符号在修饰符中都是可见的。修饰符中引入的符号在函数中不可见（因为它们可能通过覆盖而改变）。

## 常量和不可变状态变量

状态变量可以声明为`constant`(常量)或者`immutable`(不可变的)。在这两种情况下，在合约构建后无法修改变量。对于`constant`(常量)变量，其值必须在编译时固定；对于`immutable`(不可变变量)，它仍然可以在构造时赋值。

也可以在文件级别定义`constant`变量。

编译器不会为这些变量保留存储槽，并且每次出现都被相应的值替换。

与常规状态变量相比，常量和不可变变量的gas成本要低得多。对于常量变量，分配给它的表达式被复制到它被访问的所有地方，并且每次都重新计算。这允许局部优化。不可变变量在构造时被评估一次，它们的值被复制到代码中访问它们的所有位置。对于这些值，保留32个字节，即使它们适合较少的字节。因此，常量值有时比不可变值便宜。

并非所有常量和不可变类型都在此时实现。 唯一支持的类型是字符串（仅用于常量）和值类型。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.4;

uint constant X = 32**22 + 8;

contract C {
    string constant TEXT = "abc";
    bytes32 constant MY_HASH = keccak256("abc");
    uint immutable decimals;
    uint immutable maxBalance;
    address immutable owner = msg.sender;

    constructor(uint _decimals, address _reference) {
        decimals = _decimals;
        // Assignments to immutables can even access the environment.
        maxBalance = _reference.balance;
    }

    function isBalanceTooHigh(address _other) public view returns (bool) {
        return _other.balance > maxBalance;
    }
}

```

### Constant

对于`constant`常量变量，该值在编译时必须是常量，并且必须在声明变量的地方赋值。任何访问存储、区块链数据(例如`block.timestamp`、`address(this).balance`或`block.number`)或执行数据(`msg.value`或`gasleft()`)或调用外部合约的表达式都是不允许的。允许可能对内存分配产生副作用的表达式，但不允许对其它内存对象产生副作用的表达式。内置函数`keccak256`、`sha256`、`ripemd160`、`ecrecover`、`addmod`和`mulmod`是允许的(尽管除了`keccak256`，它们确实调用了外部合约)。

允许对内存分配器产生副作用的原因是它应该可以构造复杂的对象，例如查找表。此功能尚未完全可用。

### Immutable

声明为不可变的变量比声明为常量的变量限制要少一些：不可变变量可以在合约的构造函数中或在它们的声明点分配任意值。它们在构建期间无法读取，只能分配一次。

编译器生成的合约创建代码将在返回之前修改合约的运行时代码，方法是将所有对不可变的引用替换为分配给它们的值。如果您将编译器生成的运行时代码与实际存储在区块链中的代码进行比较，这一点很重要。

## 函数

函数可以在合约内部和外部定义。

合约之外的函数也称为自由函数，总是具有隐含的内部可见性。它门的代码包含在调用它们的所有合约中，类似于内部库函数。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.1 <0.9.0;

function sum(uint[] memory _arr) pure returns (uint s) {
    for (uint i = 0; i < _arr.length; i++)
        s += _arr[i];
}

contract ArrayExample {
    bool found;
    function f(uint[] memory _arr) public {
        // This calls the free function internally.
        // The compiler will add its code to the contract.
        uint s = sum(_arr);
        require(s >= 10);
        found = true;
    }
}
```

> 在合约之外定义的函数仍然总是在合约的上下文中执行。它们仍然可以访问变量`this`，可以调用其它合约，向它们发送Ether并且销毁调用它们的合约等。与合约内定义的函数主要区别在于，自由函数不能直接访问存储变量和不在其范围内的函数。

### Function Parameters and Return Variables(函数参数和返回变量)

函数将类型参数作为输入，并且与其它许多语言不同，函数还可以返回任意数量的值作为输出。

#### Function Parameters(函数参数)

函数参数的声明方式与变量相同，未使用的参数名称可以省略。

例如：如果您希望您的合约接受一种带有两个整数的外部函数，您可以使用以下内容：

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract Simple {
    uint sum;
    function taker(uint _a, uint _b) public {
        sum = _a + _b;
    }
}
```

函数参数可以用作任何其它局部变量，也可以赋值给它们。

> 外部函数不能接受多维数组作为输入参数。如果您通过添加pragma abicoder v2启用ABI编码器v2，则此功能是可能的；到您的源文件。

>内部函数可以不启用该功能的情况下接受多维数组。

#### Return Variables(返回变量)














## 事件Events




## 错误和revert语句


## 继承Inheritance



## 抽象合约Abstract Contracts

当合约中至少有一个函数没有实现，需要将合约标记为抽象。即使所有功能都已实现，合约也可以被标记为抽象。

如下示例所示，可以通过使用关键字`abstract`来完成。注意这个合约需要被定义为抽象的，因为函数`utterance()`被定义了，但没有提供实现。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

abstract contract Feline {
    function utterance() public virtual returns (bytes32);
}
```

这种抽象合约不能直接实例化，对于实现了所有定义的功能的抽象合约，也不能实例化。抽象合约作为基类的用法如下所示：

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

abstract contract Feline {
    function utterance() public pure virtual returns (bytes32);
}

contract Cat is Feline {
    function utterance() public pure override returns (bytes32) { return "miaow"; }
}
```

如果一个合约继承自一个抽象合约并且没有通过覆盖实现所有未实现的功能，那么它也需要被标记为抽象的。

请注意，没有实现的函数和函数类型不同，即使它们的语法看起来非常相似。

没有实现的函数示例：

```
function foo(address) external returns (address);
```

类型为函数类型的变量声明示例：

```
function(address) external returns (address) foo;
```

抽象合约将合约的定义与其实现分离，提供更好的可扩展性和自定义文档化，并促进模板方法和删除重复代码等模式。抽象合约的用处与在接口中定义方法的用处相同。这是抽象合约的设计者说“我的任何孩子都必须实现此方法”的一种方式。

> 抽象合约不能用未实现的虚函数覆盖已实现的虚函数。

## 接口Interfaces

接口类似于抽象合约，但它们不能实现任何功能。还有更多限制：

- 不能从其它合约继承，但可以从其它接口继承；
- 声明的函数都必须是外部的；
- 不能声明构造函数；
- 不能声明状态变量；

其中一些限制可能会在未来取消。

接口基本上仅限于Contract ABI可以表示的内容，并且ABI和接口之间的转换应该是可能的，而不会丢失任何信息。

接口由它们自己的关键字表示：

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.2 <0.9.0;

interface Token {
    enum TokenType { Fungible, NonFungible }
    struct Coin { string obverse; string reverse; }
    function transfer(address recipient, uint amount) external;
}
```

合约可以像继承其它合约一样继承接口。

在接口中声明的所有函数都是隐式虚拟的，这意味着它们可以被覆盖。这并不意味着可以再次覆盖覆盖函数——这只是在覆盖函数被标记为虚拟时才有可能。

接口可以从其它接口继承，这与普通继承具有相同的规则。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.2 <0.9.0;

interface ParentA {
    function test() external returns (uint256);
}

interface ParentB {
    function test() external returns (uint256);
}

interface SubInterface is ParentA, ParentB {
    // Must redefine test in order to assert that the parent
    // meanings are compatible.
    function test() external override(ParentA, ParentB) returns (uint256);
}
```

可以从其他合约访问在接口和其他类似合约的结构中定义的类型：Token.TokenType 或 Token.Coin。

## 库Libraries



## 使用For(Using For)

指令`using A for B;`可用于将库函数（库A）附加到合约上下文中的任何类型（B）。这些函数将接受调用它们的对象作为它们的第一个参数(如Python中的self变量)。

使用`using A for B;`的影响是库A中的函数附加到任何类型。

在这两种情况下，库中的所有函数都被附加，即使是那些第一个参数的类型与对象的类型不匹配的函数。在调用函数和执行函数重载解析时检查类型。

`using A for B;`指令仅在当前合约内有效，包括在其所有功能内，并且在使用它的合约之外无效。该指令只能在合约内使用，不能在其任何函数内使用。

以下重写库中的Set示例：

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;


// This is the same code as before, just without comments
struct Data { mapping(uint => bool) flags; }

library Set {
    function insert(Data storage self, uint value)
        public
        returns (bool)
    {
        if (self.flags[value])
            return false; // already there
        self.flags[value] = true;
        return true;
    }

    function remove(Data storage self, uint value)
        public
        returns (bool)
    {
        if (!self.flags[value])
            return false; // not there
        self.flags[value] = false;
        return true;
    }

    function contains(Data storage self, uint value)
        public
        view
        returns (bool)
    {
        return self.flags[value];
    }
}


contract C {
    using Set for Data; // this is the crucial change
    Data knownValues;

    function register(uint value) public {
        // Here, all variables of type Data have
        // corresponding member functions.
        // The following function call is identical to
        // `Set.insert(knownValues, value)`
        require(knownValues.insert(value));
    }
}
```

也可以以这种方式扩展基本类型：

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.8 <0.9.0;

library Search {
    function indexOf(uint[] storage self, uint value)
        public
        view
        returns (uint)
    {
        for (uint i = 0; i < self.length; i++)
            if (self[i] == value) return i;
        return type(uint).max;
    }
}

contract C {
    using Search for uint[];
    uint[] data;

    function append(uint value) public {
        data.push(value);
    }

    function replace(uint _old, uint _new) public {
        // This performs the library function call
        uint index = data.indexOf(_old);
        if (index == type(uint).max)
            data.push(_new);
        else
            data[index] = _new;
    }
}
```

请注意，所有外部库调用都是事实上的EVM函数调用。这意味着如果您传递内存或者值类型，则将执行复制，即使是self变量。不执行复制的唯一情况是使用存储引用变量或调用内部库函数。