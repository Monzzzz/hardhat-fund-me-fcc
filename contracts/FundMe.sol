// SPDX-License-Identifier: MIT
// Get fund from user
//With draw funds
// Set minimum fuding value in USD

pragma solidity ^0.8.0;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";
import "hardhat/console.sol";
// constant 
//immuable
// 859,757
error FundMe__NotOwner();

// interfaces, libraries, contracts

/** @title A contract for crowd  funding
* @author Elmond
* @notice this contract is to demo a sample funding contract
* @dev This implements price feed as a our library
 */
contract FundMe{
    // Type declarations 
    using PriceConverter for uint256;

    // State variables
    mapping(address =>uint256) private s_addressToAmountFunded;
    event Funded(address indexed from, uint256 amount);
    address[] private s_funders;
    // constant doesn't use the storage slot, but it is stored in the byte code of the contract and decrease the gas price
    uint256 public constant MINIMUM_USD = 50 * 1e18; 
    
    
    // it is stored in the byte code of the contract
    address private immutable i_owner;
    AggregatorV3Interface public s_priceFeed;

    modifier onlyOwner{
        if(msg.sender != i_owner) {revert FundMe__NotOwner();}// other address can't call this sontract 
        _;
    }

    constructor(address priceFeedAddress) {// automatically send the the priceFeed that the coin address is running on
        i_owner = msg.sender; // 
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);

    }
   
    /**
    * @notice This function funds this contrat
    * @dev This implements price feeds as our library
     */
    function fund() public payable{  // payable make fund function red, but normal is orange.
        // we want to be able to set a minimum amount in USD
        // How do we send to this contract?
        //msg.value is user balance
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "Didn't send enough"); // 1e18 == 1*10**18== 1000000000000000000
        // 18 decimals
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender]+=msg.value;
        emit Funded(msg.sender,msg.value);
        console.log(msg.sender, "send", msg.value ,"wei");
        // a ton of computationn here
        //What is reverting

        // oracle is a tool that helps to interact with off-chain information. In this case, USD.
    }

    function withdraw() public onlyOwner { // onlyOwner is modifier below
        // reset the array funds
        for(uint256 funderIndex=0; funderIndex <s_funders.length; funderIndex++){
            address funder= s_funders[funderIndex];
            s_addressToAmountFunded[funder] =0; // msg.value
        }
        //reset the array
        s_funders = new address[](0);
        // actually withdraw the funds

        //transfer (2300 gas, throws error)
        //payable(msg.sender)=payable address
        // payable(msg.sender).transfer(address(this).balance);// (this) means whole contract
        // // send (2300 gas, return bool)
        // bool sendSuccess= payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed"); // if above sentence fail it will display "send failed"
        // // call (forward all gas or set gas, returns bool)
        (bool callSuccess, )= payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");

    }
    function cheaperWithdraw() public payable onlyOwner{
        address[] memory funders = s_funders;
        // mappings can't be in memory
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] =0;
        }
        s_funders = new address[](0);
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success);

    }

    function getOwner() public view returns(address){
        return i_owner;
    }
    function getFunder(uint256 index) public view returns(address){
        return s_funders[index];
    }
    function getAddressToAmountFunded(address funder) public view returns(uint256){
        return s_addressToAmountFunded[funder];
    }
    function getPriceFeed() public view returns(AggregatorV3Interface){
        return s_priceFeed;
    }
    // What happen if someone send this contract ETh without calling the fund function 
    // create to help people who accidentally called wrong function or send this contract money without fund function.
    
    
    //fallback();
}
