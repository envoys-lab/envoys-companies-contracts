import { ethers } from "hardhat";
import { AIRDROP_FACTORY_ADDR } from "./constants";

async function main() {
    const token = await ethers.getContractAt("Token", "0x75F8ADf88019E9B1d023fF4645DfAa350Bf3Fb04");  
    const factory = await ethers.getContractAt("EnvoysAirdropFactory", AIRDROP_FACTORY_ADDR);
  
    const airdropAddress = await factory.airdrops(token.address);
    const airdrop = await ethers.getContractAt("EnvoysAirdrop", airdropAddress);
  
    const len = (await airdrop.allocationLen()).toNumber();

    for (let i = 0; i < len; i++) {
        const addr = await airdrop.allocation(i);
        console.log(i, addr);
    }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
