import { ethers } from "hardhat";
import { AIRDROP_FACTORY_ADDR } from "./constants";

async function main() {
  const token = await ethers.getContractAt("Token", "0x75F8ADf88019E9B1d023fF4645DfAa350Bf3Fb04");

  const [signer] = await ethers.getSigners();

  const block = await signer.provider!.getBlock("latest");
  
  const amt = "10000000000000000000";
  const count = 3;
  const total = ethers.BigNumber.from(amt).mul(count);
  const balance = await token.balanceOf(signer.address);
  if(balance.lt(total)) {
    console.log("transfer amount exceeds balance, balance:", balance.toString());
    return;
  }
  await (await token.approve(AIRDROP_FACTORY_ADDR, total)).wait(1);


  const factory = await ethers.getContractAt("EnvoysAirdropFactory", AIRDROP_FACTORY_ADDR);
  await factory.create({
    token: token.address,
    amount: amt,
    start: block.timestamp,
    end: block.timestamp + 3600
  }, total, signer.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
