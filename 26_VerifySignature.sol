// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8;

contract VerifySignature {

    function getMessageHash(
        string memory _to,
        uint _amount,
        string memory _message,
        uint _nonce
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_to, _amount, _message, _nonce));
    }

    
}