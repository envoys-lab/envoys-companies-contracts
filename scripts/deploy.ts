import { ethers } from "hardhat";

async function main() {

  const EnvoysAirdropFactory = await ethers.getContractFactory("EnvoysAirdropFactory");
  const airdropFactory = await EnvoysAirdropFactory.deploy();
  await airdropFactory.deployed();
  console.log("Airdrop factory deployed:", airdropFactory.address);

  // const EnvoysSaleFactory = await ethers.getContractFactory("EnvoysSaleFactory");
  // const saleFactory = await EnvoysSaleFactory.deploy();
  // await saleFactory.deployed();
  // console.log("Sale factory deployed:", saleFactory.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
