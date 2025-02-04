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

    receive() external payable {}

    event ProductSold(string productName, uint timestamp);

    constructor()payable{
        owner = msg.sender;
    }

    // function initTimeLok() public onlyOwner{
    //     timeLock = new TimeLock(address(this));
    // }

    function getBalance() external view onlyOwner returns(uint){
        return address(this).balance;
    }

    // Sell Product (Funds received from Timelock)
    function sellProduct(string calldata productName) external payable {
        // require(msg.value >= sum, "Attention! Not enought funds.");
        emit ProductSold(productName, block.timestamp);
    }

    // function getTxDataSallProduct(bytes32 txId) public view onlyOwner returns(TxData memory){
    //     return timeLock.getTxData(txId);
    // }

    // function addToQueueTxSellProduct(string calldata _productName, uint sum)external payable returns(bytes32){
    //     TxData memory txData = TxData(msg.sender, msg.value, "sellProduct(string)", _productName, sum);
    //     return timeLock.addToQueue(txData);
    // }

    // function executeTxSellProduct(bytes32 txId) external payable onlyOwner returns(bytes memory){
    //     return timeLock.execute(txId);
    // }

    // function removeFromQueueTxSellProduct(bytes32 txId) external onlyOwner {
    //     timeLock.discard(txId);
    // }
}