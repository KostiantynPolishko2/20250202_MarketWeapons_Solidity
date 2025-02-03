// SPDX-License-Identifier: MIT
pragma solidity >=0.4.25 <0.9.0;
pragma experimental ABIEncoderV2;


contract Timelock {
    // uint constant MINIMUM_DELAY = 10;
    // uint constant MAXIMUM_DELAY = 1 days;
    // uint constant GRACE_PERIOD = 1 days;
    address public owner;
    address public _toContract;
    string public message;
    uint public amount;

    mapping(bytes32 => bool) public queue;

    modifier onlyOwner() {
        require(msg.sender == owner, "not an owner!");
        _;
    }

    event Queued(bytes32 txId, uint indexed _timestamp, string _func);
    event Discarded(bytes32 txId, uint indexed _timestamp, string _func);
    event Executed(bytes32 txId, uint indexed _timestamp, string _func);

    constructor() {
        owner = msg.sender;
        _toContract = address(this);
    }

    function demo(string calldata _msg) external payable {
        message = _msg;
        amount = msg.value;
    }

    function getNextTimestamp() private view returns(uint) {
        return block.timestamp + 0;
    }

    function prepareData(string calldata _msg) private pure returns(bytes memory) {
        return abi.encode(_msg);
    }

    function addToQueue(string calldata _func) external payable onlyOwner returns(bytes32) {

        uint _timestamp = getNextTimestamp();
        bytes32 txId = keccak256(abi.encode(_toContract, _func, _timestamp));

        require(!queue[txId], "already queued");

        queue[txId] = true;

        emit Queued(txId, _timestamp, _func);

        return txId;
    }

    function execute(bytes32 txId, string calldata _func, bytes calldata _data, uint _value) external payable onlyOwner returns(bytes memory) {

        require(queue[txId], "not queued!");

        delete queue[txId];

        bytes memory data;
        if(bytes(_func).length > 0) {
            data = abi.encodePacked(bytes4(keccak256(bytes(_func))),_data);
        } else {
            data = _data;
        }

        (bool success, bytes memory resp) = _toContract.call{value: _value}(data);
        require(success);

        emit Executed(txId, block.timestamp, _func);
        return resp;
    }

    function discard(bytes32 _txId) external onlyOwner {
        require(queue[_txId], "not queued");

        delete queue[_txId];

        emit Discarded(_txId, block.timestamp, "demo(string)");
    }
}