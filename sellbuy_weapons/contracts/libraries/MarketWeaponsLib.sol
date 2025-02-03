// SPDX-License-Identifier: MIT
pragma solidity >=0.4.25 <0.9.0;
pragma experimental ABIEncoderV2;

library MarketWeaponsLib {
    function getTxID(address account, uint time, uint256 number) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(account, time, number));
    }
    
}