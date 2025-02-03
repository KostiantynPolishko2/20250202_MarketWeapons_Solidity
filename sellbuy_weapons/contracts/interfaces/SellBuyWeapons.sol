// SPDX-License-Identifier: MIT
pragma solidity >=0.4.25 <0.9.0;
pragma experimental ABIEncoderV2;

import "./ISellBuy.sol";

contract SellBuyWeapons is ISellBuy {
    bool private locked;

    constructor(){
        locked = false;
    }

    // check-effects-interactions pattern
    modifier noReaentrancy(){
        require(!locked, "Reentrant call detected");
        locked = true;
        _;
        locked = false;
    }

    function doRefund(address recipient, uint256 refund) external payable noReaentrancy {
        (bool isSuccess, ) = payable(recipient).call{value: refund}("");
        require(isSuccess, "Error! Refund is failed.");
    }

    function sellProduct(address sender, address owner) external payable returns(bool){
        // check if it is not owner called
        if(owner == sender){
            revert("Error! Contracts' owner is not able to call it.");
        }

        return true;
    }

    function withdrawFounds(address wallet, address _contract) external payable {
        if (address(_contract).balance == 0){
            revert("Error! Contracts' balance is 0 wei");
        }

        (bool isSuccess, ) = payable(wallet).call{value: address(_contract).balance}("");
        require(isSuccess, "Error! Withdraw is failed.");
    }
}