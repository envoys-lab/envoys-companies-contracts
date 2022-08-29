import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("EnvoysTokenizedShare", function () {
    async function deploy() {
        // Contracts are deployed using the first signer/account by default
        const [owner, otherAccount] = await ethers.getSigners();
    
        const EnvoysKycOracle = await ethers.getContractFactory("EnvoysKycOracle");
        const oracle = await EnvoysKycOracle.deploy();

        const EnvoysTokenizedShare = await ethers.getContractFactory("EnvoysTokenizedShare");
        const share = await EnvoysTokenizedShare.deploy("Test Share", "TS", 18, oracle.address);
        await oracle.setRequired(share.address, true);
    
        return { share, oracle, owner, otherAccount };
    }

    describe("Transfers", async function() {
        it("verify", async function() {
            const { otherAccount, oracle } = await loadFixture(deploy);
            await oracle.verify(otherAccount.address, true);
        });

        it("transfer with no balance", async function() {
            const { share, owner, oracle } = await loadFixture(deploy);
            await oracle.verify(owner.address, true);
            await expect(share.transfer(owner.address, 1)).to.be.rejectedWith("ERC20: transfer amount exceeds balance");
        });

        it("sender not verified", async function() {
            const { share, owner, otherAccount, oracle } = await loadFixture(deploy);
            await share.mint(otherAccount.address, 1);
            await oracle.verify(owner.address, true);
            await expect(share.connect(otherAccount).transfer(owner.address, 1))
                .to.be.rejectedWith("EnvoysTokenizedShare: Sender not verified");
        });

        it("recipient not verified", async function() {
            const { share, owner, otherAccount, oracle } = await loadFixture(deploy);
            await share.mint(owner.address, 1);
            await oracle.verify(owner.address, true);
            await expect(share.transfer(otherAccount.address, 1))
                .to.be.rejectedWith("EnvoysTokenizedShare: Receiver not verified");
        });
    });

    describe("Mint && Burn", async function() {
        it("mint", async function() {
            const { share, owner } = await loadFixture(deploy);
            await share.mint(owner.address, 1)
        });

        it("mint without permission", async function() {
            const { share, otherAccount } = await loadFixture(deploy);
            await expect(share.connect(otherAccount).mint(otherAccount.address, 1))
                .to.be.revertedWith("Access: Permission denied");
        });

        it("mint with dinamic permission", async function() {
            const { share, otherAccount } = await loadFixture(deploy);
            await share.setRole(otherAccount.address, share.MINTER_ROLE(), true);
            await share.connect(otherAccount).mint(otherAccount.address, 1);
            await share.setRole(otherAccount.address, share.MINTER_ROLE(), false);
            await expect(share.connect(otherAccount).mint(otherAccount.address, 1)).to.be.revertedWith("Access: Permission denied");
        });

        it("mint with burn permission", async function() {
            const { share, otherAccount } = await loadFixture(deploy);
            await share.setRole(otherAccount.address, share.BURNER_ROLE(), true);
            await expect(share.connect(otherAccount).mint(otherAccount.address, 1)).to.be.revertedWith("Access: Permission denied");
        });

        it("burn", async function() {
            const { share, otherAccount } = await loadFixture(deploy);
            await share.mint(otherAccount.address, 1);
            await share.burn(otherAccount.address, 1);
        });

        it("burn with mint permission", async function() {
            const { share, otherAccount } = await loadFixture(deploy);
            await share.setRole(otherAccount.address, share.MINTER_ROLE(), true);
            await share.mint(otherAccount.address, 1);
            await expect(share.connect(otherAccount).burn(otherAccount.address, 1)).to.be.revertedWith("Access: Permission denied");
        });

        it("burn without balance", async function() {
            const { share, otherAccount } = await loadFixture(deploy);
            await share.setRole(otherAccount.address, share.MINTER_ROLE(), true);
            await share.mint(otherAccount.address, 1);
            await expect(share.burn(otherAccount.address, 2)).to.be.revertedWith("ERC20: burn amount exceeds balance");
        });

        it("mint with redeemed permission", async function() {
            const { share, owner } = await loadFixture(deploy);
            await share.setRole(owner.address, share.MINTER_ROLE(), false);
            await expect(share.mint(owner.address, 1)).to.be.revertedWith("Access: Permission denied");
        });

        it("burn with redeemed permission", async function() {
            const { share, owner } = await loadFixture(deploy);
            await share.setRole(owner.address, share.BURNER_ROLE(), false);
            await expect(share.burn(owner.address, 1)).to.be.revertedWith("Access: Permission denied");
        });
    })
});