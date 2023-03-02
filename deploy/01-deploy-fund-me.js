const { networkConfig, developmentChains } = require("../helper-hardhat-config")
const { network } = require("hardhat")
const { verify } = require("../utils/verify")
require("dotenv").config()

//same as above
module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    //well what happens when we want to change chains?
    //when going for localhost or hardhat network we want to use a mock
    //To make the price feed dynamic, we could change utilise the chainId of the network to select the chains

    // const ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]; //-- this allows to get the pricefeed when not deploying the mocks!!

    let ethUsdPriceFeedAddress
    if (developmentChains.includes(network.name)) {
        const ethUsdAggregator = await deployments.get("MockV3Aggregator")
        ethUsdPriceFeedAddress = ethUsdAggregator.address
    } else {
        ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]
    }

    //mock contracts - is the contrcat does not exist, we deploy a minimal version for our local hosting, deploy mocks are technically deploy scripts!

    //const args = [ethUsdPriceFeedAddress];
    const fundMe = await deploy("FundMe", {
        from: deployer,
        args: [ethUsdPriceFeedAddress], //put price feed address
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })

    log(`Fundme deployed at ${fundMe.address}`)

    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        //verify
        await verify(fundMe.address, [ethUsdPriceFeedAddress])
    }

    log("-----------------------------------------------")
}

module.exports.tags = ["all", "fundme"]
