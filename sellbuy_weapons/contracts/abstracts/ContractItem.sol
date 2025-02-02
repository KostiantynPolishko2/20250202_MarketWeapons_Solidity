// SPDX-License-Identifier: MIT
pragma solidity >=0.4.25 <0.9.0;
pragma experimental ABIEncoderV2;

import "./AbsItem.sol";

contract ContractItem is AbsItem {
    address private owner;

    constructor(address _owner, address _item, uint _time) AbsItem(_item, _time){
        owner = _owner;
    }
}