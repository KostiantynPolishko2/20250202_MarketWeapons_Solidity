// SPDX-License-Identifier: MIT
pragma solidity >=0.4.25 <0.9.0;
pragma experimental ABIEncoderV2;

import "./TimeLock.sol";
import "./structs/TxData.sol";

contract Market {
    address private owner;
    // TimeLock private timeLock;

    modifier onlyOwner() {
        require(msg.sender == owner, "Attention! You are not an owner!");
        _;
    }

    fallback() external payable {
        revert("Error! The called function is absent.");
    }

    receive() external payable {}

    event ProductSold(uint indexed timestamp, string productName, uint sum);

    constructor()payable{
        owner = msg.sender;
    }


    function getBalance() external view onlyOwner returns(uint){
        return address(this).balance;
    }

    // Sell Product (Funds received from Timelock)
    function sellProduct(string calldata productName) public payable {
        emit ProductSold(block.timestamp, productName, msg.value);
    }

}