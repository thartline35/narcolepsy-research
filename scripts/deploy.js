const { ethers } = require("hardhat");

async function main() {
  console.log("🚀 Starting deployment of NarcolepsyEarlyWarning contract...\n");

  // Get the contract factory
  const NarcolepsyEarlyWarning = await ethers.getContractFactory("NarcolepsyEarlyWarning");
  
  // Get deployer account
  const [deployer] = await ethers.getSigners();
  console.log("📝 Deploying with account:", deployer.address);
  console.log("💰 Account balance:", ethers.formatEther(await ethers.provider.getBalance(deployer.address)), "ETH\n");

  // Deploy the contract
  console.log("⏳ Deploying contract...");
  const contract = await NarcolepsyEarlyWarning.deploy();
  await contract.waitForDeployment();

  console.log("✅ Contract deployed successfully!");
  console.log("📍 Contract address:", await contract.getAddress());
  
  // Get network info
  const network = await ethers.provider.getNetwork();
  console.log("🌐 Network:", network.name, "(Chain ID:", network.chainId + ")");
  
  // Calculate deployment cost
  const deploymentTx = contract.deploymentTransaction();
  const receipt = await deploymentTx.wait();
  const deploymentCost = receipt.gasUsed * deploymentTx.gasPrice;
  console.log("⛽ Gas used:", receipt.gasUsed.toString());
  console.log("💸 Deployment cost:", ethers.formatEther(deploymentCost), "ETH\n");

  // Generate useful information
  console.log("📋 Important Information:");
  console.log("========================");
  
  const contractAddress = await contract.getAddress();
  
  if (network.chainId === 1n) {
    console.log("🔍 Etherscan URL: https://etherscan.io/address/" + contractAddress);
  } else if (network.chainId === 11155111n) { // Sepolia
    console.log("🔍 Etherscan URL: https://sepolia.etherscan.io/address/" + contractAddress);
  } else if (network.chainId === 8453n) { // Base Mainnet
    console.log("🔍 BaseScan URL: https://basescan.org/address/" + contractAddress);
  } else if (network.chainId === 84531n) { // Base Testnet
    console.log("🔍 BaseScan URL: https://goerli.basescan.org/address/" + contractAddress);
  }
  
  console.log("\n📱 Next Steps:");
  console.log("1. Build a web interface for survey submission");
  console.log("2. Share with neurologists for patient recruitment");
  console.log("3. Analyze data using the built-in analytics functions");
  console.log("4. Export data for research publications\n");

  console.log("\n🎉 Deployment complete!");
  
  // Save deployment info to file
  const deploymentInfo = {
    contractAddress: await contract.getAddress(),
    deployerAddress: deployer.address,
    network: network.name,
    chainId: network.chainId.toString(),
    transactionHash: deploymentTx.hash,
    deploymentCost: ethers.formatEther(deploymentCost),
    gasUsed: receipt.gasUsed.toString(),
    timestamp: new Date().toISOString()
  };

  const fs = require('fs');
  fs.writeFileSync(
    'deployment-info.json',
    JSON.stringify(deploymentInfo, null, 2)
  );
  console.log("💾 Deployment info saved to deployment-info.json");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  });