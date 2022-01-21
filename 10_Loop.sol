// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8;

contract Loop {
    uint public count;

    function forloop(uint n) public {
        // for loop
        for (uint i = 0; i < n; i++) {
            count += 1;
            if (i > 50) {
                // Exit loop with break
                break;
            }
        }
    }

    function whileloop(uint n) public {
        uint j;

        while(j < n) {
            j++;
        }
        count = j;
    }

}