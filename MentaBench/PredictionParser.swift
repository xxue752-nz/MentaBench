//
//  PredictionParser.swift
//  MentaBench
//
//  Intelligent prediction parser - Optimized based on Python implementation
//  Provides multi-layer fallback mechanism to ensure valid predictions
//

import Foundation

class PredictionParser {
    
    /// Main parsing function - intelligently parse model output based on task type
    static func parse(_ text: String, for taskType: TaskType) -> Int {
        let normalized = text.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        switch taskType {
        case .task1Stress:
            return parseStress(normalized)
        case .task2DepressionBinary:
            return parseDepressionBinary(normalized)
        case .task3DepressionSeverity:
            return parseDepressionSeverity(normalized)
        case .task4SuicideIdeation:
            return parseSuicideIdeation(normalized)
        case .task5SuicideRiskBinary:
            return parseSuicideRiskBinary(normalized)
        case .task6SuicideRiskSeverity:
            return parseSuicideRiskSeverity(normalized)
        }
    }
    
    // MARK: - Task-Specific Parsers
    
    /// Task 1: Binary Stress Detection (0 or 1)
    private static func parseStress(_ text: String) -> Int {
        let stressKeywords = ["1", "stressed", "stress", "yes", "overwhelmed", "pressure"]
        
        if stressKeywords.contains(where: { text.contains($0) }) {
            return 1
        }
        
        let noStressKeywords = ["0", "no", "not stressed", "calm", "relaxed"]
        if noStressKeywords.contains(where: { text.contains($0) }) {
            return 0
        }
        
        // Fallback: extract first number
        return extractFirstNumber(from: text, defaultValue: 0)
    }
    
    /// Task 2: Binary Depression Detection (0 or 1)
    private static func parseDepressionBinary(_ text: String) -> Int {
        let depressionKeywords = ["1", "depressed", "depression", "yes", "sad", "hopeless"]
        
        if depressionKeywords.contains(where: { text.contains($0) }) {
            return 1
        }
        
        let noDepressionKeywords = ["0", "no", "not depressed", "happy", "fine"]
        if noDepressionKeywords.contains(where: { text.contains($0) }) {
            return 0
        }
        
        return extractFirstNumber(from: text, defaultValue: 0)
    }
    
    /// Task 3: Depression Severity (0-3: minimal, mild, moderate, severe)
    private static func parseDepressionSeverity(_ text: String) -> Int {
        // Check for explicit numbers first
        if text.contains("0") || text.contains("minimal") || text.contains("minimum") {
            return 0
        } else if text.contains("1") || text.contains("mild") {
            return 1
        } else if text.contains("2") || text.contains("moderate") {
            return 2
        } else if text.contains("3") || text.contains("severe") {
            return 3
        }
        
        // Fallback: extract number with bounds
        let num = extractFirstNumber(from: text, defaultValue: 1)
        return max(0, min(3, num))  // Clamp to [0, 3]
    }
    
    /// Task 4: Binary Suicide Ideation (0 or 1)
    private static func parseSuicideIdeation(_ text: String) -> Int {
        let ideationKeywords = ["1", "suicidal", "ideation", "yes", "kill myself", "end it"]
        
        if ideationKeywords.contains(where: { text.contains($0) }) {
            return 1
        }
        
        let noIdeationKeywords = ["0", "no", "not suicidal", "safe"]
        if noIdeationKeywords.contains(where: { text.contains($0) }) {
            return 0
        }
        
        return extractFirstNumber(from: text, defaultValue: 0)
    }
    
    /// Task 5: Binary Suicide Risk (0 or 1)
    private static func parseSuicideRiskBinary(_ text: String) -> Int {
        let riskKeywords = ["1", "risk", "suicide", "yes", "indicator", "danger"]
        
        if riskKeywords.contains(where: { text.contains($0) }) {
            return 1
        }
        
        let noRiskKeywords = ["0", "no", "supportive", "safe"]
        if noRiskKeywords.contains(where: { text.contains($0) }) {
            return 0
        }
        
        return extractFirstNumber(from: text, defaultValue: 0)
    }
    
    /// Task 6: Suicide Risk Severity (1-5: supportive, indicator, ideation, behavior, attempt)
    private static func parseSuicideRiskSeverity(_ text: String) -> Int {
        // Check for explicit numbers first
        if text.contains("1") || text.contains("supportive") {
            return 1
        } else if text.contains("2") || text.contains("indicator") {
            return 2
        } else if text.contains("3") || text.contains("ideation") {
            return 3
        } else if text.contains("4") || text.contains("behavior") {
            return 4
        } else if text.contains("5") || text.contains("attempt") {
            return 5
        }
        
        // Fallback: extract number with bounds
        let num = extractFirstNumber(from: text, defaultValue: 2)
        return max(1, min(5, num))  // Clamp to [1, 5]
    }
    
    // MARK: - Helper Functions
    
    /// Extract first number from text using regex
    private static func extractFirstNumber(from text: String, defaultValue: Int) -> Int {
        let pattern = "\\d+"
        
        if let range = text.range(of: pattern, options: .regularExpression) {
            let numberStr = String(text[range])
            if let number = Int(numberStr) {
                return number
            }
        }
        
        return defaultValue
    }
    
    /// Parse with confidence score (for future use)
    static func parseWithConfidence(_ text: String, for taskType: TaskType) -> (prediction: Int, confidence: Double) {
        let prediction = parse(text, for: taskType)
        
        // Simple confidence heuristic: if text contains exact number, high confidence
        let normalized = text.lowercased()
        let hasExactNumber = normalized.range(of: "\\b\(prediction)\\b", options: .regularExpression) != nil
        let confidence = hasExactNumber ? 0.9 : 0.6
        
        return (prediction, confidence)
    }
}

