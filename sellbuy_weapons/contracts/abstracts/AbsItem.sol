// SPDX-License-Identifier: MIT
pragma solidity >=0.4.25 <0.9.0;
pragma experimental ABIEncoderV2;

abstract contract AbsItem {
    address internal item;
    uint internal time;

    constructor(address _item, uint _time){
        item = _item;
        time = _time;
    }
}