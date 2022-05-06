const Factory = artifacts.require("Factory");
const Pool = artifacts.require("Pool");
const Dai = artifacts.require("ERC20");
const Bat = artifacts.require("ERC20");
const Wbtc = artifacts.require("ERC20");
const Iinch = artifacts.require("ERC20");
const Ape = artifacts.require("ERC20");
const Link = artifacts.require("ERC20");


module.exports = async function (deployer) {
    await deployer.deploy(Factory);
    await deployer.deploy(Pool, "0x0000000000000000000000000000000000000000");
    await deployer.deploy(Dai, "DAI Stablecoin", "DAI");
    await deployer.deploy(Bat, "Basic Attention Token", "BAT");
    await deployer.deploy(Wbtc, "Wrapped Bitcoin", "WBTC");
    await deployer.deploy(Iinch, "1 Inch", "1INCH");
    await deployer.deploy(Ape, "Ape coin", "APE");
    await deployer.deploy(Link, "Chainlink", "LINK");

    const factory = await Factory.deployed();
    const pool = await Pool.deployed();

    await factory.setPool(pool.address);
};
