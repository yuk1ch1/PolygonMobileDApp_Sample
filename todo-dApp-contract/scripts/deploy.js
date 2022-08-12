const { ethers } = require("hardhat")

// deploy.js
const main = async () => {
  const todoContractFactory = await ethers.getContractFactory("TodoContract");
  const todoContract = await todoContractFactory.deploy();
  const todoPortal = await todoContract.deployed();
  console.log("Contract deployed to: ", todoPortal.address);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
};

runMain();