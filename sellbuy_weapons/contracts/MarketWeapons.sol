// SPDX-License-Identifier: MIT
pragma solidity >=0.4.25 <0.9.0;
pragma experimental ABIEncoderV2;

import "./abstracts/AbsItem.sol";
import "./abstracts/ContractItem.sol";
import "./abstracts/OwnerItem.sol";
import "./structs/SalesInfo.sol";
import "./structs/TxInfo.sol";
import "./libraries/MarketWeaponsLib.sol";
import "./interfaces/ISellBuy.sol";
import "./structs/ContractInfo.sol";

contract MarketWeapons {
    address payable private owner;
    bool private locked;
    mapping(bytes32 => SalesInfo) txSalesInfo;
    ContractItem private contractItem;
    ISellBuy private sellBuy;

    constructor(address sellBuyWeapons) payable {
        owner = payable(msg.sender);
        locked = false;
        sellBuy = ISellBuy(sellBuyWeapons);
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Error! Only owner can call.");
        _;
    }

    // check-effects-interactions pattern
    modifier noReaentrancy(){
        require(!locked, "Reentrant call detected");
        locked = true;
        _;
        locked = false;
    }

    modifier msgValue(uint256 sum) {
        require(sum <= msg.value, "Error! The senders' value is less than required amount.");
        _;
    }

    event Deposit(uint indexed time, address account, string deposit_type, uint sum, bool isSuccess);
    event Sell(bytes32 txID, uint indexed time, uint256 sum, bool isSuccess);
    event Fail(uint indexed time, string reason);

    fallback() external payable {
        revert("Error! The called function is absent.");
    }

    receive() external payable {
        uint256 _sum = msg.value;
        bool isSuccess = owner.send(msg.value);
        if (!isSuccess){
            emit Deposit(block.timestamp, msg.sender, "donation", _sum, isSuccess);
            revert("Error! The transfer of founds did not execute.");
        }

        emit Deposit(block.timestamp, msg.sender, "donation", _sum, isSuccess);
    }

    function initContractData() public onlyOwner {
        contractItem = new ContractItem(owner, address(this), block.timestamp);
    }

    function fixTxData(string memory productName, uint256 sum) private returns(bytes32){
        bytes32 txID = MarketWeaponsLib.getTxID(msg.sender, block.timestamp, block.number);
        txSalesInfo[txID] = SalesInfo(block.timestamp, msg.sender, productName, sum);

        return txID;
    }

    function refund(address recipient, uint256 sum) private noReaentrancy {
        uint256 refund_sum = msg.value - sum;
        if(refund_sum > 0){
            require(address(this).balance>= refund_sum, "Error! Not enough funds on contract balance.");
            (bool isSuccess, ) = payable(recipient).call{value: refund_sum}("");
            require(isSuccess, "Error! Refund is failed.");
        }
    }

    function sellWeapons(string memory productName, uint128 price, uint128 quantity) external payable msgValue(price * quantity) returns(bool) {

        uint256 sum = price * quantity;
        bool isSuccess = false;
        try sellBuy.sellProduct(msg.sender, owner) returns(bool result){
            isSuccess = result;
        }
        catch Error(string memory reason){
            emit Fail(block.timestamp, reason);
            isSuccess = false;
        }
        catch{
            emit Fail(block.timestamp, "undefined");
            isSuccess = false;
        }

        refund(msg.sender, sum);

        emit Sell(fixTxData(productName, sum), block.timestamp, sum, isSuccess);
        return isSuccess;
    }

    function withdrawToWallet() payable external onlyOwner{

        uint256 sumWithdraw = address(this).balance;
        MarketWeaponsLib.withdrawFounds(owner, address(this));

        emit Deposit(block.timestamp, msg.sender, "donation", sumWithdraw, true);
    }

    function getSalesInfo(bytes32 _txID) external view returns(SalesInfo memory){
        return txSalesInfo[_txID];
    }

    function getContractItem() external view returns(ContractInfo memory){
        return contractItem.getInfo();
    }

    function getOwnerBalance() external view onlyOwner returns (uint) {
        return owner.balance;
    }

    function getContractBalance() external view onlyOwner returns(uint){
        return address(this).balance;
    }
}
