import { ethers } from "hardhat";
import { SALE_FACTORY_ADDR } from "./constants";

async function main() {
  // const ERC20 = await ethers.getContractFactory("Token");
  // const token = await ERC20.deploy("Undefined Coin", "UDC");
  const token = await ethers.getContractAt("Token", "0x75F8ADf88019E9B1d023fF4645DfAa350Bf3Fb04");

  const [signer] = await ethers.getSigners();

  const block = await signer.provider!.getBlock("latest");
  
  const soft = "1000000000000000000000";
  const hard = "10000000000000000000000";
  const balance = await token.balanceOf(signer.address);
  if(balance.lt(hard)) {
    console.log("transfer amount exceeds balance, balance:", balance.toString());
    return;
  }
  await (await token.approve(SALE_FACTORY_ADDR, hard)).wait(1);


  const factory = await ethers.getContractAt("EnvoysSaleFactory", SALE_FACTORY_ADDR);
  await factory.create({
    token: token.address,
    price: "1000000000000000000",
    buyToken: "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56",
    soft: soft,
    hard: hard,
    start: block.timestamp,
    end: block.timestamp + 3600
  }, signer.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
