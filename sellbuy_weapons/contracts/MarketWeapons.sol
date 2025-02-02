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
}
