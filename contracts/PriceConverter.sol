// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


library PriceConverter {
    function getPrice(AggregatorV3Interface priceFeed) internal view returns(uint256){
        // ABI 
        // Address 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        (,int256 price,,,) = priceFeed.latestRoundData(); // we want just price
        // ETH in terms of USD
        // now the price has 8 decimal, so we have to divind more by 10
        return uint256(price * 1e10); // 1*10
    
    }
    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns(uint256){
        uint256 ethPrice= getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) /1e18; // now we have 36 decimal place because 18 places from ethPrice and 18 places for ethAmount
        return ethAmountInUsd;
    }
    //function withdraw(){}
}
// asking questions on github
// markdown 
// ''' make it clear 
