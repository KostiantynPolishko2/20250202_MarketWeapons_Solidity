// SPDX-License-Identifier: MIT
pragma solidity >=0.4.25 <0.9.0;
pragma experimental ABIEncoderV2;

import "./AbsItem.sol";

contract OwnerItem is AbsItem {
    constructor(address _item, uint _time) AbsItem(_item, _time){
    }
}