// SPDX-License-Identifier: MIT
pragma solidity >=0.4.25 <0.9.0;
pragma experimental ABIEncoderV2;

import "./structs/TxData.sol";

contract TimeLock {
    address private market;
    address private owner;
    mapping(bytes32 => bool) private queues;
    mapping(bytes32 => TxData) private queuesTxData;

    modifier onlyOwner() {
        require(msg.sender == owner, "Attention! You are not an owner!");
        _;
    }

    modifier ValueMoreEqualSum(uint sum){
        require(msg.value >= sum, "Attention! The send founds less than requested sum.");
        _;
    }

    event Queued(uint indexed timestamp, bytes32 txId, string func, address client, uint indexed sum);
    event Executed(bytes32 txId, string func, address client, uint indexed sum);
    event Discarded(bytes32 txId, string func, address client, uint indexed sum);

    fallback() external payable {
        revert("Error! The called function is absent.");
    }

    receive() external payable {}

    constructor(address _market) payable {
        market = _market;
        owner = msg.sender;
    }

    function getNextTimestamp() private view returns(uint) {
        return block.timestamp + 0;
    }

    function prepareData(string memory _msg) private pure returns(bytes memory) {
        return abi.encode(_msg);
    }

    function getBalance() public view onlyOwner returns(uint){
        return address(this).balance;
    }

    function getTxData(bytes32 txId) public view onlyOwner returns(TxData memory){
        require(queues[txId], "Error! Required tx is not queued.");
        return queuesTxData[txId];
    }

    function addToQueue(string calldata productName, uint sum) public payable ValueMoreEqualSum(sum) returns(bytes32) {
        require(!(msg.sender == owner), "Attention! Transaction can not be done by owner.");
        
        uint timestamp = getNextTimestamp();
        bytes memory _data = prepareData(productName);
        bytes32 txId = keccak256(abi.encode(market, msg.sender, timestamp, _data, sum));

        require(!queues[txId], "Attention! Required tx is already queued.");

        queues[txId] = true;
        queuesTxData[txId] = TxData(msg.sender, msg.value, "sellProduct(string)", productName, sum);

        emit Queued(block.timestamp, txId, "sellProduct(string)", msg.sender, sum);

        return txId;
    }

    function execute(bytes32 txId) public payable onlyOwner returns(bytes memory) {
 
        require(queues[txId], "Error! Required tx is not queued.");
        TxData storage txData = queuesTxData[txId];

        bytes memory data = abi.encodeWithSignature(txData.func, txData.productName);

        (bool success, bytes memory resp) = market.call{value: txData.sum}(data); // sellProduct("f1")
        require(success, string.concat("Error! Failed call function '", txData.func, "'."));
        delete queues[txId];
        delete queuesTxData[txId];

        emit Executed(txId, txData.func, txData.client, txData.sum);

        return resp;
    }

    function discard(bytes32 txId) public {
        require(queues[txId], "Attention! Required tx is not queued.");

        TxData storage txData = queuesTxData[txId];
        delete queues[txId];
        delete queuesTxData[txId];

        emit Discarded(txId, txData.func, txData.client, txData.sum);
    }
}