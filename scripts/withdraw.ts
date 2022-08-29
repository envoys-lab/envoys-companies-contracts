import { ethers } from "hardhat";
import { SALE_FACTORY_ADDR } from "./constants";

async function main() {
    const token = await ethers.getContractAt("Token", "0x75F8ADf88019E9B1d023fF4645DfAa350Bf3Fb04");  
    const factory = await ethers.getContractAt("EnvoysSaleFactory", SALE_FACTORY_ADDR);
  
    const saleAddress = await factory.sales(token.address);
    const sale = await ethers.getContractAt("EnvoysSale", saleAddress);
    const owner = await sale.owner();
    console.log("Owner:", owner);

    await sale.withdraw();

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
