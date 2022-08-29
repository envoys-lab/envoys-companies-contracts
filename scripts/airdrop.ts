import { ContractTransaction } from "ethers";
import { ethers } from "hardhat";
import isPromise from "is-promise";
import { AIRDROP_FACTORY_ADDR } from "./constants";

const printTxHash = async (tx: ContractTransaction | Promise<ContractTransaction>) => {
    if(isPromise(tx)) {
        await printTxHash(await tx)
    } else {
        console.log(tx.hash);
    }
}

async function main() {
    const token = await ethers.getContractAt("Token", "0x75F8ADf88019E9B1d023fF4645DfAa350Bf3Fb04");  
    const factory = await ethers.getContractAt("EnvoysAirdropFactory", AIRDROP_FACTORY_ADDR);
    
    const [signer] = await ethers.getSigners();
    const block = await signer.provider!.getBlock("latest");
    const timestamp = block.timestamp;

    const airdropAddress = await factory.airdrops(token.address);
    const airdrop = await ethers.getContractAt("EnvoysAirdrop", airdropAddress);
    
    const info = await airdrop.airdropInfo();
    const isFinished = info.end.lt(timestamp);
    
    try {
        const tx = await airdrop.refund();
        console.log("Refund...");
        printTxHash(tx);
    } catch {}

    if(!isFinished) {
        console.log("Airdrop...");
        printTxHash(airdrop.airdrop());
    } else {
        console.log("Harvest...");
        await printTxHash(airdrop.harvest());
    }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
