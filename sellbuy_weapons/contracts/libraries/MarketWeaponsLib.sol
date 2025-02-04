// SPDX-License-Identifier: MIT
pragma solidity >=0.4.25 <0.9.0;
pragma experimental ABIEncoderV2;

library MarketWeaponsLib {
    function getTxID(address account, uint time, uint256 number) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(account, time, number));
    }
    
    function withdrawFounds(address wallet, address _contract) internal{
        if (address(_contract).balance == 0){
            revert("Error! Contracts' balance is 0 wei");
        }

        (bool isSuccess, ) = payable(wallet).call{value: address(_contract).balance}("");
        require(isSuccess, "Error! Withdraw is failed.");
    }
}