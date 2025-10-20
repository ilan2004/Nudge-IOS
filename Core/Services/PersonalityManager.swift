import SwiftUI
import Combine

class PersonalityManager: ObservableObject {
    @Published var personalityType: PersonalityType?
    @Published var gender: Gender = .neutral
    @Published var hasCompletedTest: Bool = false
    @Published var testScores: [String: Int] = [:]
    @Published var currentTheme: PersonalityColors = PersonalityTheme.defaultColors
    
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    // UserDefaults keys
    private let personalityTypeKey = "nudge_personality_type"
    private let genderKey = "nudge_gender"
    private let testCompletedKey = "nudge_test_completed"
    private let testScoresKey = "nudge_test_scores"
    
    init() {
        loadPersonalityType()
        setupThemeBinding()
    }
    
    func loadPersonalityType() {
        // FOR TESTING: Set ENFJ by default
        // Load saved personality data
        if let typeString = userDefaults.string(forKey: personalityTypeKey),
           let type = PersonalityType(rawValue: typeString) {
            personalityType = type
            hasCompletedTest = userDefaults.bool(forKey: testCompletedKey)
            
            if let genderString = userDefaults.string(forKey: genderKey),
               let savedGender = Gender(rawValue: genderString) {
                gender = savedGender
            }
            
            if let scoresData = userDefaults.data(forKey: testScoresKey),
               let scores = try? JSONDecoder().decode([String: Int].self, from: scoresData) {
                testScores = scores
            }
            
            updateTheme()
        } else {
            // FOR TESTING: Default to ENFJ with female gender
            personalityType = .enfj
            gender = .female
            hasCompletedTest = true
            testScores = ["E": 15, "N": 12, "F": 18, "J": 14]
            
            // Save test data
            userDefaults.set(PersonalityType.enfj.rawValue, forKey: personalityTypeKey)
            userDefaults.set(Gender.female.rawValue, forKey: genderKey)
            userDefaults.set(true, forKey: testCompletedKey)
            
            if let scoresData = try? JSONEncoder().encode(testScores) {
                userDefaults.set(scoresData, forKey: testScoresKey)
            }
            
            updateTheme()
        }
    }
    
    func savePersonalityResult(type: PersonalityType, gender: Gender, scores: [String: Int]) {
        self.personalityType = type
        self.gender = gender
        self.testScores = scores
        self.hasCompletedTest = true
        
        // Save to UserDefaults
        userDefaults.set(type.rawValue, forKey: personalityTypeKey)
        userDefaults.set(gender.rawValue, forKey: genderKey)
        userDefaults.set(true, forKey: testCompletedKey)
        
        if let scoresData = try? JSONEncoder().encode(scores) {
            userDefaults.set(scoresData, forKey: testScoresKey)
        }
        
        updateTheme()
        
        // Post notification for theme change
        NotificationCenter.default.post(name: .personalityUpdated, object: type)
    }
    
    func resetPersonalityData() {
        personalityType = nil
        gender = .neutral
        hasCompletedTest = false
        testScores = [:]
        
        userDefaults.removeObject(forKey: personalityTypeKey)
        userDefaults.removeObject(forKey: genderKey)
        userDefaults.removeObject(forKey: testCompletedKey)
        userDefaults.removeObject(forKey: testScoresKey)
        
        currentTheme = PersonalityTheme.defaultColors
    }
    
    private func updateTheme() {
        // OVERRIDE: Always use mint background regardless of personality type
        let mintTheme = PersonalityColors(
            primary: Color(red: 0.063, green: 0.737, blue: 0.502), // mint
            secondary: Color(red: 0.055, green: 0.259, blue: 0.184), // green
            accent: Color(red: 1.0, green: 0.411, blue: 0.706), // pink
            surface: Color(red: 0.988, green: 0.973, blue: 0.949), // cream
            background: Color(red: 0.063, green: 0.737, blue: 0.502), // mint background
            text: Color.white, // white text on mint background
            textSecondary: Color(red: 0.9, green: 0.9, blue: 0.9) // light gray
        )
        
        currentTheme = mintTheme
    }
    
    private func setupThemeBinding() {
        // Update theme whenever personality type or gender changes
        Publishers.CombineLatest($personalityType, $gender)
            .sink { [weak self] type, gender in
                self?.updateTheme()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Personality Test Scoring
    func calculatePersonalityType(from answers: [TestAnswer]) -> PersonalityType {
        var scores: [String: Int] = [
            "E": 0, "I": 0,  // Extraversion vs Introversion
            "S": 0, "N": 0,  // Sensing vs Intuition  
            "T": 0, "F": 0,  // Thinking vs Feeling
            "J": 0, "P": 0   // Judging vs Perceiving
        ]
        
        // Score each answer based on personality dimensions
        for answer in answers {
            if let question = PersonalityQuestions.getQuestion(id: answer.questionId) {
                for (dimension, weight) in question.scoring {
                    scores[dimension, default: 0] += answer.value * weight
                }
            }
        }
        
        // Determine personality type from scores
        let e_i = scores["E", default: 0] > scores["I", default: 0] ? "E" : "I"
        let s_n = scores["S", default: 0] > scores["N", default: 0] ? "S" : "N"
        let t_f = scores["T", default: 0] > scores["F", default: 0] ? "T" : "F"
        let j_p = scores["J", default: 0] > scores["P", default: 0] ? "J" : "P"
        
        let typeString = e_i + s_n + t_f + j_p
        
        // Store individual dimension scores
        self.testScores = scores
        
        return PersonalityType(rawValue: typeString) ?? .infp
    }
    
    // Get personality image name
    func getPersonalityImageName() -> String? {
        guard let type = personalityType else { return nil }
        return PersonalityTheme.mediaName(for: type, gender: gender, isVideo: false)
    }
    
    // Get personality video name  
    func getPersonalityVideoName() -> String? {
        guard let type = personalityType else { return nil }
        return PersonalityTheme.mediaName(for: type, gender: gender, isVideo: true)
    }
    
    // MARK: - Manual Setters (for testing)
    func setPersonalityType(_ type: PersonalityType) {
        personalityType = type
        userDefaults.set(type.rawValue, forKey: personalityTypeKey)
        updateTheme()
    }
    
    func setGender(_ newGender: Gender) {
        gender = newGender
        userDefaults.set(newGender.rawValue, forKey: genderKey)
        updateTheme()
    }
    
    func markTestCompleted() {
        hasCompletedTest = true
        userDefaults.set(true, forKey: testCompletedKey)
    }
}

// MARK: - Test Answer Model
struct TestAnswer {
    let questionId: String
    let value: Int // 1-5 scale typically
}

// MARK: - Notification Names
extension Notification.Name {
    static let personalityUpdated = Notification.Name("personalityUpdated")
}
