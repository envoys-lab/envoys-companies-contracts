import { ethers } from "hardhat";

async function main() {
    const token = await ethers.getContractAt("Token", "0x0e14d15504d83bd91434cf970691a02c6b5928f8");  
    const factory = await ethers.getContractAt("EnvoysSaleFactory", "0x929F065831aCa929D83C1aD7aCB837067513F7db");
  
    const saleAddress = await factory.sales(token.address);
    const sale = await ethers.getContractAt("EnvoysSale", saleAddress);
  
    await (await token.mint("1000000000000000000000000")).wait(2);
    await (await token.approve(saleAddress, "1000000000000000000000000")).wait(2);
    await sale.deposit("1000000000000000000000000");

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
