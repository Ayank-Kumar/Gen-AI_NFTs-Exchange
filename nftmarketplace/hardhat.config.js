require("@nomicfoundation/hardhat-toolbox");

// npx hardhat node --> To create a node 

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.20",
  networks: {
    hardhat: {
      // this is the by default - also used by metamask. 
      chainId: 1337
    }
  }
};
