const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NarcolepsyEarlyWarning", function () {
  let contract;
  let owner;
  let patient1;
  let patient2;

  beforeEach(async function () {
    [owner, patient1, patient2] = await ethers.getSigners();
    
    const NarcolepsyEarlyWarning = await ethers.getContractFactory("NarcolepsyEarlyWarning");
    contract = await NarcolepsyEarlyWarning.deploy();
    await contract.waitForDeployment(); // ethers v6 syntax
  });

  describe("Deployment", function () {
    it("Should set the correct owner", async function () {
      expect(await contract.owner()).to.equal(owner.address);
    });

    it("Should start with survey active", async function () {
      expect(await contract.surveyActive()).to.equal(true);
    });

    it("Should start with zero episodes", async function () {
      expect(await contract.getTotalEpisodes()).to.equal(0);
    });
  });

  describe("Episode Reporting", function () {
    it("Should allow patients to report episodes", async function () {
      await contract.connect(patient1).reportEpisodeComplete(
        1, // sleep attack
        7, // severity
        8, // stress level
        6, // sleep quality
        14, // 2 PM
        30, // 30 min warning
        8, // confidence
        2, // age range (26-35)
        5, // years since diagnosis
        7, // overall severity
        true, // had caffeine
        false, // had meal
        true, // temp change
        true, // dizziness
        false, // nausea
        true, // tingling
        false, // headache
        false, // blurred vision
        true, // mood change
        true, // cognitive slowing
        false, // muscle weakness
        false // restlessness
      );

      expect(await contract.getTotalEpisodes()).to.equal(1);
      expect(await contract.userEpisodeCount(patient1.address)).to.equal(1);
    });

    it("Should auto-register participants", async function () {
      await contract.connect(patient1).reportEpisodeComplete(
        1, 7, 8, 6, 14, 30, 8, 2, 5, 7, true, false,
        true, true, false, true, false, false, true, true, false, false
      );

      expect(await contract.registeredUsers(patient1.address)).to.equal(true);
      expect(await contract.totalParticipants()).to.equal(1);
    });

    it("Should validate episode type", async function () {
      await expect(
        contract.connect(patient1).reportEpisodeComplete(
          5, 7, 8, 6, 14, 30, 8, 2, 5, 7, true, false,
          true, true, false, true, false, false, true, true, false, false
        )
      ).to.be.revertedWith("Invalid episode type");
    });

    it("Should validate severity range", async function () {
      await expect(
        contract.connect(patient1).reportEpisodeComplete(
          1, 11, 8, 6, 14, 30, 8, 2, 5, 7, true, false,
          true, true, false, true, false, false, true, true, false, false
        )
      ).to.be.revertedWith("Invalid severity");
    });
  });

  describe("Analytics Functions", function () {
    beforeEach(async function () {
      // Add multiple episode reports for testing
      await contract.connect(patient1).reportEpisodeComplete(
        1, 7, 8, 6, 14, 30, 8, 2, 5, 7, true, false,
        true, true, false, true, false, false, true, true, false, false
      );
      
      await contract.connect(patient2).reportEpisodeComplete(
        2, 5, 5, 8, 10, 45, 6, 3, 2, 6, false, true,
        false, true, true, false, true, false, false, false, true, false
      );
    });

    it("Should calculate symptom frequencies correctly", async function () {
      const frequencies = await contract.getSymptomFrequencies();
      
      expect(frequencies.totalEpisodes).to.equal(2);
      expect(frequencies.tempChangeCount).to.equal(1);
      expect(frequencies.dizzinessCount).to.equal(2);
      expect(frequencies.nauseaCount).to.equal(1);
      expect(frequencies.tinglingCount).to.equal(1);
      expect(frequencies.headacheCount).to.equal(1);
    });

    it("Should calculate warning time statistics", async function () {
      const stats = await contract.getWarningTimeStats();
      
      expect(stats.totalEpisodes).to.equal(2);
      expect(stats.episodesWithWarning).to.equal(2);
      expect(stats.averageWarningTime).to.equal(37); // (30 + 45) / 2 = 37.5, rounded down
    });

    it("Should retrieve episode data correctly", async function () {
      const episode = await contract.getEpisode(0);
      
      expect(episode.episodeType).to.equal(1);
      expect(episode.episodeSeverity).to.equal(7);
      expect(episode.warningTimeMinutes).to.equal(30);
      
      const symptoms = await contract.getEpisodeSymptoms(0);
      expect(symptoms.suddenTempChange).to.equal(true);
      expect(symptoms.dizziness).to.equal(true);
    });
  });

  describe("Owner Functions", function () {
    it("Should allow owner to toggle survey", async function () {
      await contract.connect(owner).toggleSurvey();
      expect(await contract.surveyActive()).to.equal(false);
      
      await expect(
        contract.connect(patient1).reportEpisodeComplete(
          1, 7, 8, 6, 14, 30, 8, 2, 5, 7, true, false,
          true, true, false, true, false, false, true, true, false, false
        )
      ).to.be.revertedWith("Survey is currently inactive");
    });

    it("Should not allow non-owner to toggle survey", async function () {
      await expect(
        contract.connect(patient1).toggleSurvey()
      ).to.be.revertedWith("Only owner can call this");
    });
  });

  describe("Registration", function () {
    it("Should allow manual participant registration", async function () {
      await contract.connect(patient1).registerParticipant();
      
      expect(await contract.registeredUsers(patient1.address)).to.equal(true);
      expect(await contract.totalParticipants()).to.equal(1);
    });

    it("Should not double-register participants", async function () {
      await contract.connect(patient1).registerParticipant();
      await contract.connect(patient1).registerParticipant();
      
      expect(await contract.totalParticipants()).to.equal(1);
    });
  });
});