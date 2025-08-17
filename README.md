# 🧠 Narcolepsy Early Warning Research

A blockchain-based smart contract for collecting anonymous narcolepsy episode data to help identify early warning patterns.

## 🎯 Project Goal

This project aims to discover patterns in symptoms that occur 30-60 minutes before narcolepsy episodes, potentially helping patients develop early warning systems to:
- Find safe places to rest before episodes
- Alert family/friends when needed
- Better manage their condition
- Improve quality of life

## 🔬 What Data We Collect

**Episode Information:**
- Type (sleep attack, cataplexy, hallucination, sleep paralysis)
- Severity (1-10 scale)
- Time of occurrence

**Pre-Episode Symptoms:**
- Physical: temperature changes, dizziness, nausea, tingling, headache
- Visual: blurred vision, visual disturbances
- Cognitive: brain fog, mood changes
- Motor: muscle weakness, restlessness

**Context:**
- Stress level, sleep quality, caffeine/food intake
- Warning time (how many minutes before symptoms appeared)
- Demographics (anonymous age ranges, years since diagnosis)

## 🔐 Privacy & Security

- **No personal identifiers** stored on blockchain
- **Anonymous wallet addresses** only
- **No medical records or names**
- **Open source code** - verify exactly what data is collected
- **Immutable records** - data cannot be altered after submission
- **Global accessibility** - not limited to specific clinics or regions

## 🚀 Quick Start

### Prerequisites
- Node.js (v16 or higher)
- MetaMask wallet
- Small amount of ETH for gas fees

### Installation

1. **Clone and setup:**
   ```bash
   mkdir narcolepsy-research
   cd narcolepsy-research
   npm init -y
   npm install hardhat @nomicfoundation/hardhat-toolbox ethers dotenv
   ```

2. **Copy the contract files** (provided separately)

3. **Setup environment:**
   ```bash
   cp .env.example .env
   # Edit .env with your private key and RPC URLs
   ```

4. **Compile the contract:**
   ```bash
   npx hardhat compile
   ```

5. **Run tests:**
   ```bash
   npx hardhat test
   ```

### Deployment

**Deploy to Sepolia testnet (recommended for testing):**
```bash
npm run deploy:sepolia
```

**Deploy to Base network (for production):**
```bash
npm run deploy:base
```

After deployment, you'll get:
- Contract address
- Blockchain explorer link
- Gas costs
- Funding instructions

## 💡 Usage Examples

### Reporting an Episode (Complete - One Transaction)

```javascript
// Complete episode report in one transaction
await contract.reportEpisodeComplete(
  1,     // Episode type: 1=sleep attack, 2=cataplexy, 3=hallucination, 4=sleep paralysis
  7,     // Severity (1-10)
  8,     // Stress level (1-10)
  6,     // Sleep quality last night (1-10)
  14,    // Time of day (24-hour format)
  30,    // Warning time in minutes
  8,     // Confidence level (1-10)
  2,     // Age range: 1=18-25, 2=26-35, 3=36-45, 4=46-55, 5=56+
  5,     // Years since diagnosis
  7,     // Overall narcolepsy severity (1-10)
  true,  // Had caffeine within 4 hours
  false, // Had meal within 2 hours
  true,  // Sudden temperature change
  true,  // Dizziness
  false, // Nausea
  true,  // Tingling
  false, // Headache
  false, // Blurred vision
  true,  // Mood change
  true,  // Cognitive slowing
  false, // Muscle weakness
  false  // Restlessness
);
```

### Reporting an Episode (Two-Step Process)

```javascript
// Step 1: Report basic episode data
const episodeId = await contract.reportEpisode(
  1, 7, 8, 6, 14, 30, 8, 2, 5, 7, true, false
);

// Step 2: Add symptoms
await contract.addSymptoms(
  episodeId, true, true, false, true, false, false, 
  true, true, false, false
);
```

### Analyzing Data

```javascript
// Get symptom frequencies
const frequencies = await contract.getSymptomFrequencies();
console.log(`Dizziness occurs in ${frequencies.dizzinessCount}/${frequencies.totalEpisodes} episodes`);

// Get warning time statistics
const stats = await contract.getWarningTimeStats();
console.log(`Average warning time: ${stats.averageWarningTime} minutes`);

// Get specific episode data
const episode = await contract.getEpisode(0);
const symptoms = await contract.getEpisodeSymptoms(0);
console.log(`Episode type: ${episode.episodeType}, Severity: ${episode.episodeSeverity}`);
console.log(`Had dizziness: ${symptoms.dizziness}, Had nausea: ${symptoms.nausea}`);
```

## 💰 Compensation System

- Participants receive **~$12-15 worth of ETH** per episode report
- Automatic payment upon successful submission
- Owner must fund contract with ETH for compensation
- Compensation amount is adjustable by contract owner

## 🔧 Smart Contract Functions

### For Participants:
- `registerParticipant()` - Optional registration (auto-registered on first submission)
- `reportEpisode(...)` - Submit basic episode data (returns episode ID)
- `addSymptoms(episodeId, ...)` - Add symptoms to an episode
- `reportEpisodeComplete(...)` - Submit complete episode data in one transaction
- `userEpisodeCount(address)` - Check how many episodes you've reported

### For Researchers:
- `getTotalEpisodes()` - Get total number of reports
- `getEpisode(id)` - Retrieve episode data
- `getEpisodeSymptoms(id)` - Retrieve symptoms for an episode
- `getSymptomFrequencies()` - Analyze symptom patterns
- `getWarningTimeStats()` - Study warning time patterns

### For Contract Owner:
- `toggleSurvey()` - Activate/deactivate data collection
- `transferOwnership(address)` - Transfer contract ownership

## 📊 Research Applications

This data could enable:

**Pattern Discovery:**
- "85% of patients report dizziness 20-40 minutes before sleep attacks"
- "Temperature changes precede cataplexy more than other episode types"
- "Morning episodes have different warning patterns than afternoon episodes"

**Clinical Applications:**
- Evidence-based early warning criteria
- Personalized symptom recognition training
- Digital health tool development
- Treatment timing optimization

**Academic Publications:**
- First large-scale blockchain-based medical data collection
- Novel insights into narcolepsy prodrome symptoms
- Methodology for decentralized medical research

## 🛡️ Security Considerations

**For Participants:**
- Use a dedicated wallet for privacy
- Don't reuse wallets that could link to your identity
- Understand that blockchain data is permanent

**For Researchers:**
- Ensure IRB approval if using for formal research
- Consider additional privacy measures for participant recruitment
- Regular security audits recommended

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/new-analysis`)
3. Make changes and test thoroughly
4. Submit pull request with detailed description

## 📜 License

MIT License - see LICENSE file for details

## ⚠️ Disclaimers

- This is research software, not medical advice
- Consult healthcare providers for medical decisions
- Participants should understand blockchain permanence
- No guarantee of research outcomes
- Smart contracts carry inherent risks

## 🆘 Support

**Technical Issues:**
- Open GitHub issue with error details
- Include transaction hashes and network information

**Medical Questions:**
- Consult with your neurologist or healthcare provider
- This project is for research, not medical advice

## 🔗 Useful Links

- [Base Network](https://base.org)
- [MetaMask](https://metamask.io)
- [Hardhat Documentation](https://hardhat.org)
- [Solidity Documentation](https://docs.soliditylang.org)

---

**Built with:** Solidity, Hardhat, Node.js, and the goal of improving lives for narcolepsy patients worldwide.

*"Data-driven insights for better sleep and better lives."*