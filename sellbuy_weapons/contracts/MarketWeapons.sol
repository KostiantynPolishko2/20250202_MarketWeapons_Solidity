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

    event Deposit(uint indexed time, string name, address account, uint sum);

    function initContractData() public onlyOwner {
        contractItem = new ContractItem(owner, address(this), block.timestamp);
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

    fallback() external payable {
        revert("Error! The called function is absent.");
    }

    receive() external payable {
        uint256 _sum = msg.value;
        require(owner.send(msg.value), "Error! The transfer of founds did not execute.");

        emit Deposit(block.timestamp, "donation", msg.sender, _sum);
    }
}
