// SPDX-License-Identifier: MIT
pragma solidity >=0.4.25 <0.9.0;
pragma experimental ABIEncoderV2;

import "./abstracts/AbsItem.sol";
import "./abstracts/ContractItem.sol";
import "./abstracts/OwnerItem.sol";

contract MarketWeapons {
    address payable private owner;
    ContractItem private contractItem;

    constructor() payable {
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Error! Only owner can call.");
        _;
    }

    modifier isSenderValue(uint128 price, uint128 quantity) {
        uint256 sum = price * quantity;
        require(sum <= msg.value, "Error! The senders' value is less than required amount.");
        _;
    }

    event Deposit(uint indexed time, address account, string deposit_type, uint sum);
    event Sell(uint indexed time, address account, string productName, uint sum);

    function initContractData() public onlyOwner {
        contractItem = new ContractItem(owner, address(this), block.timestamp);
    }

    fallback() external payable {
        revert("Error! The called function is absent.");
    }

    receive() external payable {
        uint256 _sum = msg.value;
        require(owner.send(msg.value), "Error! The transfer of founds did not execute.");

        emit Deposit(block.timestamp, msg.sender, "donation", _sum);
    }

    function SellProduct(string memory productName, uint128 price, uint128 quantity) external payable isSenderValue(price, quantity) returns(bool){
        // check if it is not owner called
        if(owner == msg.sender){
            revert("Error! Contracts' owner is not able to call it.");
        }

        // call msg.value makes transfer funds from customer to contract balance
        uint256 sum = price * quantity;
        require(payable(address(this)).send(msg.value), "Error! The transfer of founds did not execute.");
        emit Sell(block.timestamp, msg.sender, productName, sum);

        // optionally, handle excess payment (refund)
        uint256 refund = msg.value - sum;
        if(refund > 0){
            require(payable(msg.sender).send(refund), "Error! The transfer of refunds did not execute.");
            return true;
        }

        return true;
    }

    function getContractItem() external view returns(AbsItem item){
        return contractItem;
    }

    function getOwnerBalance() external view onlyOwner returns (uint) {
        return owner.balance;
    }

    function getContractBalance() external view onlyOwner returns(uint){
        return address(this).balance;
    }
}
