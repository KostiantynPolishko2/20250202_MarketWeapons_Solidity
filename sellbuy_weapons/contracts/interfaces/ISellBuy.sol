// SPDX-License-Identifier: MIT
pragma solidity >=0.4.25 <0.9.0;
pragma experimental ABIEncoderV2;

interface ISellBuy {
    function doRefund(address recipient, uint256 refund) external payable;

    function sellProduct(address sender, address owner, uint256 sum) external payable;

    function withdrawFounds(address owner, address _contract) external payable;
}