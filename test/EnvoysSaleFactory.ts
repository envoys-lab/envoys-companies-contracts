import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

/**
    address token;
    uint256 soft;
    uint256 hard;
    address buyToken;
    uint256 price;
    
    uint256 start;
    uint256 end;
 */
describe("EnvoysSaleFactory", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshopt in every test.
  async function deploy() {
  

    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const EnvoysSaleFactory = await ethers.getContractFactory("EnvoysSaleFactory");
    const factory = await EnvoysSaleFactory.deploy();

    const Token = await ethers.getContractFactory("Token");
    const token = await Token.deploy("Envoys Token", "EVT");
    const payToken = await Token.deploy("Tether US", "USDT");

    const block = await owner.provider!.getBlock("latest");
    const currentTime = block.timestamp;

    await token.mint(1000000000);
    await payToken.mint(1000000000);
 
    return { factory, token, payToken, owner, otherAccount, currentTime };
  }

  it("Create", async function () {
    const { factory, token, payToken, owner, currentTime } = await loadFixture(deploy);

    await factory.create({
      token: token.address,
      soft: 1000,
      hard: 2000,
      buyToken: payToken.address,
      price: 14,

      start: currentTime,
      end: currentTime + 3600
    }, owner.address);

    const saleAddress = await factory.sales(token.address);
    const sale = await ethers.getContractAt("EnvoysSale", saleAddress);

    expect(sale.address).not.eq("0x0000000000000000000000000000000000000000");
  });

  it("When trying to create a sale for one token a second time, an exception is expected", async function () {
    const { factory, token, payToken, owner, currentTime } = await loadFixture(deploy);

    await factory.create({
      token: token.address,
      soft: 1000,
      hard: 2000,
      buyToken: payToken.address,
      price: 10,

      start: currentTime,
      end: currentTime + 3600
    }, owner.address);

    
    await expect(factory.create({
      token: token.address,
      soft: 1000,
      hard: 2000,
      buyToken: payToken.address,
      price: 10,

      start: currentTime,
      end: currentTime + 3600
    }, owner.address)).to.be.revertedWith(("EnvoysSaleFactory: Sale already exists"))
  });
  
});
