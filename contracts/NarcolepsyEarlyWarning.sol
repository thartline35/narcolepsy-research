// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title NarcolepsyEarlyWarning
 * @dev Smart contract for collecting anonymous narcolepsy episode data for early warning research
 * @author Your Name
 */
contract NarcolepsyEarlyWarning {
    
    // Struct to store episode data
    struct EpisodeReport {
        uint8 episodeType;        // 1=sleep attack, 2=cataplexy, 3=hallucination, 4=sleep paralysis
        uint8 episodeSeverity;    // 1-10 scale
        uint256 episodeTimestamp;
        uint8 stressLevel;        // 1-10 scale
        uint8 sleepQualityLastNight; // 1-10 scale
        uint8 timeOfDay;          // 0-23 (24-hour format)
        uint8 warningTimeMinutes; // How many minutes before episode symptoms started
        uint8 confidenceLevel;    // 1-10 how sure about timing
        uint8 ageRange;           // 1=18-25, 2=26-35, 3=36-45, 4=46-55, 5=56+
        uint8 yearsSinceDiagnosis; // 0-50
        uint8 overallSeverity;    // 1-10 how severe is their narcolepsy generally
        bool hadCaffeine;         // Within 4 hours
        bool hadMeal;             // Within 2 hours
    }
    
    // Struct for symptoms (to reduce stack depth)
    struct Symptoms {
        bool suddenTempChange;    // Hot/cold flashes
        bool dizziness;          // Lightheadedness
        bool nausea;             // Stomach discomfort
        bool tingling;           // Hands/feet/face tingling
        bool headache;           // Head pressure/pain
        bool blurredVision;      // Vision changes
        bool moodChange;         // Irritability/anxiety
        bool cognitiveSlowing;   // Brain fog
        bool muscleWeakness;     // General weakness
        bool restlessness;       // Fidgeting/can't sit still
    }
    
    // Storage
    EpisodeReport[] public episodes;
    mapping(uint256 => Symptoms) public episodeSymptoms; // episodeId => symptoms
    mapping(address => uint256) public userEpisodeCount;
    mapping(address => bool) public registeredUsers;
    
    // Contract settings
    address public owner;
    uint256 public totalParticipants;
    bool public surveyActive = true;
    
    // Events
    event EpisodeReported(address indexed reporter, uint256 episodeId, uint8 episodeType);
    event UserRegistered(address indexed user);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }
    
    modifier surveyIsActive() {
        require(surveyActive, "Survey is currently inactive");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * @dev Register as a participant (optional but helps with analytics)
     */
    function registerParticipant() public {
        if (!registeredUsers[msg.sender]) {
            registeredUsers[msg.sender] = true;
            totalParticipants++;
            emit UserRegistered(msg.sender);
        }
    }
    
    /**
     * @dev Submit an episode report (split into two parts to avoid stack too deep)
     */
    function reportEpisode(
        uint8 _episodeType,
        uint8 _severity,
        uint8 _stressLevel,
        uint8 _sleepQuality,
        uint8 _timeOfDay,
        uint8 _warningMinutes,
        uint8 _confidence,
        uint8 _ageRange,
        uint8 _yearsSinceDiagnosis,
        uint8 _overallSeverity,
        bool _hadCaffeine,
        bool _hadMeal
    ) public surveyIsActive returns (uint256 episodeId) {
        // Validate inputs
        require(_episodeType >= 1 && _episodeType <= 4, "Invalid episode type");
        require(_severity >= 1 && _severity <= 10, "Invalid severity");
        require(_stressLevel >= 1 && _stressLevel <= 10, "Invalid stress level");
        require(_sleepQuality >= 1 && _sleepQuality <= 10, "Invalid sleep quality");
        require(_timeOfDay <= 23, "Invalid time of day");
        require(_confidence >= 1 && _confidence <= 10, "Invalid confidence");
        require(_ageRange >= 1 && _ageRange <= 5, "Invalid age range");
        require(_overallSeverity >= 1 && _overallSeverity <= 10, "Invalid overall severity");
        
        // Create episode report
        episodes.push(EpisodeReport({
            episodeType: _episodeType,
            episodeSeverity: _severity,
            episodeTimestamp: block.timestamp,
            stressLevel: _stressLevel,
            sleepQualityLastNight: _sleepQuality,
            timeOfDay: _timeOfDay,
            warningTimeMinutes: _warningMinutes,
            confidenceLevel: _confidence,
            ageRange: _ageRange,
            yearsSinceDiagnosis: _yearsSinceDiagnosis,
            overallSeverity: _overallSeverity,
            hadCaffeine: _hadCaffeine,
            hadMeal: _hadMeal
        }));
        
        episodeId = episodes.length - 1;
        userEpisodeCount[msg.sender]++;
        
        // Auto-register if not already registered
        if (!registeredUsers[msg.sender]) {
            registerParticipant();
        }
        
        emit EpisodeReported(msg.sender, episodeId, _episodeType);
        return episodeId;
    }
    
    /**
     * @dev Add symptoms to an episode (call after reportEpisode)
     */
    function addSymptoms(
        uint256 _episodeId,
        bool _tempChange,
        bool _dizziness,
        bool _nausea,
        bool _tingling,
        bool _headache,
        bool _blurredVision,
        bool _moodChange,
        bool _cognitiveSlowing,
        bool _muscleWeakness,
        bool _restlessness
    ) public {
        require(_episodeId < episodes.length, "Episode does not exist");
        
        episodeSymptoms[_episodeId] = Symptoms({
            suddenTempChange: _tempChange,
            dizziness: _dizziness,
            nausea: _nausea,
            tingling: _tingling,
            headache: _headache,
            blurredVision: _blurredVision,
            moodChange: _moodChange,
            cognitiveSlowing: _cognitiveSlowing,
            muscleWeakness: _muscleWeakness,
            restlessness: _restlessness
        });
    }
    
    /**
     * @dev Complete episode report in one transaction (convenience function)
     */
    function reportEpisodeComplete(
        uint8 _episodeType,
        uint8 _severity,
        uint8 _stressLevel,
        uint8 _sleepQuality,
        uint8 _timeOfDay,
        uint8 _warningMinutes,
        uint8 _confidence,
        uint8 _ageRange,
        uint8 _yearsSinceDiagnosis,
        uint8 _overallSeverity,
        bool _hadCaffeine,
        bool _hadMeal,
        bool _tempChange,
        bool _dizziness,
        bool _nausea,
        bool _tingling,
        bool _headache,
        bool _blurredVision,
        bool _moodChange,
        bool _cognitiveSlowing,
        bool _muscleWeakness,
        bool _restlessness
    ) public surveyIsActive {
        uint256 episodeId = reportEpisode(
            _episodeType, _severity, _stressLevel, _sleepQuality,
            _timeOfDay, _warningMinutes, _confidence, _ageRange,
            _yearsSinceDiagnosis, _overallSeverity, _hadCaffeine, _hadMeal
        );
        
        addSymptoms(
            episodeId, _tempChange, _dizziness, _nausea, _tingling,
            _headache, _blurredVision, _moodChange, _cognitiveSlowing,
            _muscleWeakness, _restlessness
        );
    }
    
    /**
     * @dev Get total number of episode reports
     */
    function getTotalEpisodes() public view returns (uint256) {
        return episodes.length;
    }
    
    /**
     * @dev Get episode data by ID
     */
    function getEpisode(uint256 _episodeId) public view returns (EpisodeReport memory) {
        require(_episodeId < episodes.length, "Episode does not exist");
        return episodes[_episodeId];
    }
    
    /**
     * @dev Get symptoms for an episode
     */
    function getEpisodeSymptoms(uint256 _episodeId) public view returns (Symptoms memory) {
        require(_episodeId < episodes.length, "Episode does not exist");
        return episodeSymptoms[_episodeId];
    }
    
    /**
     * @dev Get symptom frequency analysis
     */
    function getSymptomFrequencies() public view returns (
        uint256 tempChangeCount,
        uint256 dizzinessCount,
        uint256 nauseaCount,
        uint256 tinglingCount,
        uint256 headacheCount,
        uint256 totalEpisodes
    ) {
        totalEpisodes = episodes.length;
        
        for (uint256 i = 0; i < episodes.length; i++) {
            Symptoms memory symptoms = episodeSymptoms[i];
            if (symptoms.suddenTempChange) tempChangeCount++;
            if (symptoms.dizziness) dizzinessCount++;
            if (symptoms.nausea) nauseaCount++;
            if (symptoms.tingling) tinglingCount++;
            if (symptoms.headache) headacheCount++;
        }
    }
    
    /**
     * @dev Get warning time patterns
     */
    function getWarningTimeStats() public view returns (
        uint256 averageWarningTime,
        uint256 episodesWithWarning,
        uint256 totalEpisodes
    ) {
        totalEpisodes = episodes.length;
        uint256 totalWarningTime = 0;
        
        for (uint256 i = 0; i < episodes.length; i++) {
            if (episodes[i].warningTimeMinutes > 0) {
                episodesWithWarning++;
                totalWarningTime += episodes[i].warningTimeMinutes;
            }
        }
        
        if (episodesWithWarning > 0) {
            averageWarningTime = totalWarningTime / episodesWithWarning;
        }
    }
    
    /**
     * @dev Toggle survey active status
     */
    function toggleSurvey() public onlyOwner {
        surveyActive = !surveyActive;
    }
    
    /**
     * @dev Transfer contract ownership
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }
}