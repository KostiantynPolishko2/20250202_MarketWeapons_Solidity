// SPDX-License-Identifier: MIT
pragma solidity >=0.4.25 <0.9.0;
pragma experimental ABIEncoderV2;

struct SalesInfo {
    uint time;
    address account;
    string product_name;
    uint256 sum;
}