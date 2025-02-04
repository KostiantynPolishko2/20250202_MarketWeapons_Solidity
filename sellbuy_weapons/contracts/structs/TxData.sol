// SPDX-License-Identifier: MIT
pragma solidity >=0.4.25 <0.9.0;
pragma experimental ABIEncoderV2;

struct TxData{
    address client;
    uint value;
    string func;
    string productName;
    uint sum;
}