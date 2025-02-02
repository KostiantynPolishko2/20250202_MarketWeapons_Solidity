// SPDX-License-Identifier: MIT
pragma solidity >=0.4.25 <0.9.0;
pragma experimental ABIEncoderV2;

import "./abstracts/AbsItem.sol";
import "./abstracts/ContractItem.sol";
import "./abstracts/OwnerItem.sol";

contract MarketWeapons {
    address payable private owner;
    bool private locked;
    ContractItem private contractItem;

    constructor() payable {
        owner = payable(msg.sender);
        locked = false;
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

    // check-effects-interactions pattern
    modifier noReaentrancy(){
        require(!locked, "Reentrant call detected");
        locked = true;
        _;
        locked = false;
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

    function doRefund(address recipient, uint256 sum) private noReaentrancy {
        uint256 refund = msg.value - sum;
        if(refund > 0){
            require(address(this).balance>= refund, "Error! Not enough funds on contract balance.");
            (bool isSuccess, ) = payable(recipient).call{value: refund}("");
            require(isSuccess, "Error! Refund is failed.");
        }
    }

    function sellProduct(string memory productName, uint128 price, uint128 quantity) external payable isSenderValue(price, quantity) returns(bool){
        // check if it is not owner called
        if(owner == msg.sender){
            revert("Error! Contracts' owner is not able to call it.");
        }

        // optionally, handle excess payment (refund)
        uint256 sum = price * quantity;
        doRefund(msg.sender, sum);
        emit Sell(block.timestamp, msg.sender, productName, sum);

        return true;
    }

    function withdrawFounds() payable external onlyOwner returns (bool){
        if (address(this).balance == 0){
            return false;
        }

        uint256 sumWithdraw = address(this).balance;
        (bool isSuccess, ) = owner.call{value: address(this).balance}("");
        require(isSuccess, "Error! Withdraw is failed.");
        emit Deposit(block.timestamp, msg.sender, "donation", sumWithdraw);

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
