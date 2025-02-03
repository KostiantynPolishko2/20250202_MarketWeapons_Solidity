// SPDX-License-Identifier: MIT
pragma solidity >=0.4.25 <0.9.0;
pragma experimental ABIEncoderV2;

import "./TimeLock.sol";
import "./structs/TxData.sol";

contract Market {
    address private owner;
    TimeLock private timeLock;
    string private productName;
    uint private amount;

    modifier onlyOwner() {
        require(msg.sender == owner, "Attention! You are not an owner!");
        _;
    }

    constructor(){
        owner = msg.sender;
    }

    function initTimeLok() public {
        timeLock = new TimeLock(address(this));
    }

    function sellProduct(string calldata _productName) public payable {
        productName = _productName;
        amount = msg.value;
    }

    function getTxDataSallProduct(bytes32 txId) public view onlyOwner returns(TxData memory){
        return timeLock.getTxData(txId);
    }

    function addToQueueTxSellProduct(string calldata _productName, uint sum)external payable returns(bytes32){
        return timeLock.addToQueue("sellProduct(string)", _productName, sum);
    }

    function executeTxSellProduct(bytes32 txId) external payable onlyOwner returns(bytes memory){
        return timeLock.execute(txId);
    }

    function removeFromQueueTxSellProduct(bytes32 txId) external onlyOwner {
        timeLock.discard(txId);
    }
}