// SPDX-License-Identifier: MIT
pragma solidity >=0.4.25 <0.9.0;
pragma experimental ABIEncoderV2;

import "./structs/TxData.sol";

contract Timelock {
    address private owner;
    address private toContract;
    string private message;
    uint private amount;

    mapping(bytes32 => bool) private queues;
    mapping(bytes32 => TxData) private queuesTxData;

    modifier onlyOwner() {
        require(msg.sender == owner, "not an owner!");
        _;
    }

    event Queued(bytes32 txId, uint indexed timestamp, string func, string data, uint value);
    event Discarded(bytes32 txId, uint indexed timestamp, string func);
    event Executed(bytes32 txId, uint indexed timestamp, string func);

    constructor() {
        owner = msg.sender;
        toContract = address(this);
    }

    function demo(string calldata _msg) external payable {
        message = _msg;
        amount = msg.value;
    }

    function getNextTimestamp() private view returns(uint) {
        return block.timestamp + 0;
    }

    function prepareData(string memory _msg) private pure returns(bytes memory) {
        return abi.encode(_msg);
    }

    function getTxData(bytes32 txId) public view returns(TxData memory){
        require(queues[txId], "Error! Required tx is not queued.");
        return queuesTxData[txId];
    }

    function addToQueue(string calldata func, string calldata data, uint value) external payable returns(bytes32) {

        uint timestamp = getNextTimestamp();
        bytes memory _data = prepareData(data);
        bytes32 txId = keccak256(abi.encode(toContract, func, timestamp, _data, value));

        require(!queues[txId], "Attention! Required tx is already queued.");

        queues[txId] = true;
        queuesTxData[txId] = TxData(func, data, value);

        emit Queued(txId, timestamp, func, data, value);

        return txId;
    }

    function execute(bytes32 txId) external payable onlyOwner returns(bytes memory) {

        require(queues[txId], "Error! Required tx is not queued.");
        TxData storage txData = queuesTxData[txId];
        bytes memory _data = prepareData(txData.data);

        bytes memory data;
        if(bytes(txData.func).length > 0) {
            data = abi.encodePacked(bytes4(keccak256(bytes(txData.func))),_data);
        } else {
            data = _data;
        }

        (bool success, bytes memory resp) = toContract.call{value: txData.value}(data);
        require(success, string.concat("Error! Failed call function '", txData.func, "'."));
        delete queues[txId];
        delete queuesTxData[txId];

        emit Executed(txId, block.timestamp, txData.func);

        return resp;
    }

    function discard(bytes32 txId) external onlyOwner {
        require(queues[txId], "Attention! Required tx is not queued.");

        string memory func = queuesTxData[txId].func;
        delete queues[txId];
        delete queuesTxData[txId];

        emit Discarded(txId, block.timestamp, func);
    }
}