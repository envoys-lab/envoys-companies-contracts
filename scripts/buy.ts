import { ethers } from "hardhat";

async function main() {
    const token = await ethers.getContractAt("Token", "0x0e14d15504d83bd91434cf970691a02c6b5928f8");  
    const wbnb = await ethers.getContractAt("Token", "0xae13d989dac2f0debff460ac112a837c89baa7cd");  
    const factory = await ethers.getContractAt("EnvoysSaleFactory", "0x929F065831aCa929D83C1aD7aCB837067513F7db");
    const saleAddress = await factory.sales(token.address);
    const sale = await ethers.getContractAt("EnvoysSale", saleAddress);
    const [signer] = await ethers.getSigners();

    await (await wbnb.approve(sale.address, wbnb.balanceOf(signer.address))).wait();
    console.log(sale.address);

    console.log(await wbnb.balanceOf(signer.address));
    console.log(await wbnb.allowance(signer.address, sale.address));
    await sale.buy("1000000000");


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
