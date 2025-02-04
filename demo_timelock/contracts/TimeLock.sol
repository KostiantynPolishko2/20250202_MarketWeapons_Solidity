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

    event Queued(bytes32 txId, uint indexed timestamp, address client, string func, string data, uint value);
    event Discarded(bytes32 txId, uint indexed timestamp, string func);
    event Executed(bytes32 txId, uint indexed timestamp, string func);

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

    function addToQueue(string calldata productName, uint sum) public payable returns(bytes32) {

        uint timestamp = getNextTimestamp();
        bytes memory _data = prepareData(productName);
        bytes32 txId = keccak256(abi.encode(market, msg.sender, timestamp, _data, sum));

        require(!queues[txId], "Attention! Required tx is already queued.");

        queues[txId] = true;
        queuesTxData[txId] = TxData(msg.sender, msg.value, "sellProduct(string)", productName, sum);

        emit Queued(txId, timestamp, msg.sender, "sellProduct(string)", productName, sum);

        return txId;
    }

    function execute(bytes32 txId) public payable onlyOwner returns(bytes memory) {
 
        require(queues[txId], "Error! Required tx is not queued.");
        TxData storage txData = queuesTxData[txId];
        // bytes memory _productName = prepareData(txData.productName);

        //bytes memory data = abi.encodePacked(bytes4(keccak256(bytes(txData.func))), txData.productName);
        bytes memory data = abi.encodeWithSignature(txData.func, txData.productName);

        (bool success, bytes memory resp) = market.call{value: txData.sum}(data); // sellProduct("f1")
        require(success, string.concat("Error! Failed call function '", txData.func, "'."));
        delete queues[txId];
        delete queuesTxData[txId];

        emit Executed(txId, block.timestamp, txData.func);

        return resp;
    }

    function discard(bytes32 txId) public {
        require(queues[txId], "Attention! Required tx is not queued.");

        string memory func = queuesTxData[txId].func;
        delete queues[txId];
        delete queuesTxData[txId];

        emit Discarded(txId, block.timestamp, func);
    }
}