//
//  Tasks.swift
//  MentaBench
//
//  Created by Assistant on 2025-01-10.
//

import Foundation

// MARK: - Task Types
enum TaskType: String, CaseIterable {
    case task1Stress = "task1_stress"
    case task2DepressionBinary = "task2_depression_binary"
    case task3DepressionSeverity = "task3_depression_severity"
    case task4SuicideIdeation = "task4_suicide_ideation"
    case task5SuicideRiskBinary = "task5_suicide_risk_binary"
    case task6SuicideRiskSeverity = "task6_suicide_risk_severity"
}

// MARK: - Task Configuration
struct TaskConfig {
    let type: TaskType
    let name: String
    let datasetFile: String
    let labelColumn: String
    let textColumn: String
    let numClasses: Int
    let classNames: [String]
    let promptTemplate: String
    let maxTokens: Int32
    let weight: Double
    let defaultValue: String
    
    var isBinaryClassification: Bool {
        return numClasses == 2
    }
    
    static let allTasks: [TaskConfig] = [
        // Task 1: Stress Detection (Binary)
        TaskConfig(
            type: .task1Stress,
            name: "Task 1: Stress Detection",
            datasetFile: "datasets/dataset/dreaddit_StressAnalysis - Sheet1.csv",
            labelColumn: "label",
            textColumn: "text",
            numClasses: 2,
            classNames: ["0", "1"],
            promptTemplate: """
            You are an expert mental health analyst with 15+ years of experience in stress detection and assessment. Your task is to analyze Reddit posts for stress indicators with high accuracy.
            
            STRESS DETECTION CRITERIA:
            
            HIGH STRESS INDICATORS (Classify as 1):
            - Explicit stress mentions: "stressed", "overwhelmed", "can't handle", "too much pressure"
            - Anxiety symptoms: worry, panic, racing thoughts, restlessness
            - Physical stress: headaches, muscle tension, fatigue, sleep problems
            - Emotional overwhelm: frustration, irritability, feeling trapped, helplessness
            - Work/life pressure: deadlines, responsibilities, financial worries, relationship conflicts
            - Behavioral changes: social withdrawal, avoidance, substance use, appetite changes
            - Crisis language: "breaking point", "can't take it anymore", "falling apart"
            
            LOW/NO STRESS INDICATORS (Classify as 0):
            - Neutral or positive emotional tone
            - Problem-solving approach rather than overwhelmed
            - Stable daily routines and relationships
            - Seeking advice or sharing experiences without distress
            - Casual conversation or informational posts
            
            EXAMPLES:
            "I'm so stressed about my job, can't sleep" → 1 (explicit stress + sleep issues)
            "Having trouble with my roommate" → 0 (problem-solving, not overwhelmed)
            "Work is overwhelming me, I feel like I'm drowning" → 1 (overwhelmed + drowning metaphor)
            
            IMPORTANT: Respond with ONLY the number 0 or 1. No explanations.
            
            Post to analyze: {text}
            
            Classification:
            """,
            maxTokens: 8,
            weight: 1.0,
            defaultValue: "0"
        ),
        
        // Task 2: Depression Detection (Binary)
        TaskConfig(
            type: .task2DepressionBinary,
            name: "Task 2: Depression Detection (Binary)",
            datasetFile: "datasets/dataset/Reddit_depression_dataset.csv",
            labelColumn: "label",
            textColumn: "text",
            numClasses: 2,
            classNames: ["0", "1"],
            promptTemplate: """
            You are a clinical psychologist specializing in depression assessment with expertise in social media mental health screening. Analyze the following Reddit post for depression indicators.
            
            DEPRESSION DETECTION CRITERIA:
            
            DEPRESSION INDICATORS (Classify as 1):
            - Core symptoms: persistent sadness, hopelessness, emptiness, despair
            - Anhedonia: loss of interest, pleasure, motivation in activities
            - Cognitive symptoms: negative self-talk, guilt, worthlessness, suicidal thoughts
            - Physical symptoms: fatigue, sleep problems, appetite changes, low energy
            - Behavioral signs: social isolation, self-neglect, substance use
            - Language patterns: "nothing matters", "what's the point", "I'm worthless", "wish I was dead"
            - Duration: symptoms persisting for weeks or months
            
            NO DEPRESSION (Classify as 0):
            - Positive or neutral emotional state
            - Active engagement in life and relationships
            - Problem-solving mindset rather than hopelessness
            - Normal mood fluctuations without persistent negativity
            - Seeking help or sharing experiences constructively
            
            EXAMPLES:
            "I've been feeling so empty and hopeless for months" → 1 (core symptoms + duration)
            "Had a bad day at work, need advice" → 0 (temporary, seeking help)
            "Nothing brings me joy anymore, what's the point of living?" → 1 (anhedonia + suicidal ideation)
            
            IMPORTANT: Respond with ONLY the number 0 or 1. No explanations.
            
            Post to analyze: {text}
            
            Classification:
            """,
            maxTokens: 8,
            weight: 1.0,
            defaultValue: "0"
        ),
        
        // Task 3: Depression Severity Detection (4-level)
        TaskConfig(
            type: .task3DepressionSeverity,
            name: "Task 3: Depression Severity Detection",
            datasetFile: "datasets/dataset/Reddit_depression_dataset.csv",
            labelColumn: "label",
            textColumn: "text",
            numClasses: 4,
            classNames: ["0", "1", "2", "3"],
            promptTemplate: """
            You are a clinical psychologist specializing in depression severity assessment using standardized diagnostic criteria. Analyze the following Reddit post to determine depression severity level.
            
            DEPRESSION SEVERITY CRITERIA:
            
            LEVEL 0 (Minimal):
            - No significant depression symptoms
            - Normal mood and functioning
            - Occasional sadness or stress without clinical significance
            - No functional impairment
            
            LEVEL 1 (Mild):
            - 2-3 depression symptoms present
            - Mild functional impairment
            - Some difficulty with daily activities
            - Symptoms don't significantly impact work/relationships
            - Language: "feeling down", "having a rough time", "not myself lately"
            
            LEVEL 2 (Moderate):
            - 4-5 depression symptoms present
            - Moderate functional impairment
            - Noticeable impact on work, relationships, or daily activities
            - Difficulty concentrating, low energy, sleep problems
            - Language: "struggling", "can't seem to function", "everything feels hard"
            
            LEVEL 3 (Severe):
            - 6+ depression symptoms present
            - Significant functional impairment
            - Major impact on work, relationships, daily activities
            - Possible suicidal ideation, social isolation, substance use
            - Language: "can't get out of bed", "life feels meaningless", "wish I didn't exist"
            
            EXAMPLES:
            "Feeling a bit down lately" → 0 (minimal)
            "Been struggling with motivation and sleep for weeks" → 1 (mild)
            "Can't concentrate at work, everything feels overwhelming" → 2 (moderate)
            "Life feels meaningless, can't get out of bed, wish I was dead" → 3 (severe)
            
            IMPORTANT: Respond with ONLY the number 0, 1, 2, or 3. No explanations.
            
            Post to analyze: {text}
            
            Severity level:
            """,
            maxTokens: 8,
            weight: 1.2,
            defaultValue: "0"
        ),
        
        // Task 4: Suicide Ideation Detection (Binary)
        TaskConfig(
            type: .task4SuicideIdeation,
            name: "Task 4: Suicide Ideation Detection",
            datasetFile: "datasets/dataset/SDCNL.csv",
            labelColumn: "is_suicide",
            textColumn: "title+selftext",  // Combined from title and selftext columns
            numClasses: 2,
            classNames: ["0", "1"],
            promptTemplate: """
            You are a crisis intervention specialist and licensed clinical psychologist with expertise in suicide risk assessment. Analyze the following Reddit post for suicidal ideation indicators.
            
            SUICIDAL IDEATION DETECTION CRITERIA:
            
            SUICIDAL IDEATION PRESENT (Classify as 1):
            - Direct expressions: "I want to die", "I should kill myself", "I wish I was dead"
            - Method mentions: "end it all", "not worth living", "better off dead"
            - Hopelessness: "no point in going on", "nothing will get better", "can't take it anymore"
            - Burden feelings: "everyone would be better without me", "I'm a burden"
            - Death wishes: "wish I could disappear", "wish I was never born", "don't want to exist"
            - Crisis language: "breaking point", "final straw", "done with life"
            - Context clues: recent trauma, loss, overwhelming stress combined with hopelessness
            
            NO SUICIDAL IDEATION (Classify as 0):
            - No death-related thoughts or expressions
            - Problem-solving mindset despite difficulties
            - Seeking help or support
            - Expressing sadness without death wishes
            - Normal expressions of stress or depression without suicidal content
            
            EXAMPLES:
            "I want to kill myself, life isn't worth living" → 1 (direct + hopelessness)
            "Feeling really depressed and hopeless lately" → 0 (depression without death wishes)
            "Sometimes I wish I could just disappear" → 1 (death wish)
            "Going through a tough time, need advice" → 0 (seeking help)
            
            IMPORTANT: Respond with ONLY the number 0 or 1. No explanations.
            
            Post to analyze: {text}
            
            Classification:
            """,
            maxTokens: 8,
            weight: 1.2,
            defaultValue: "0"
        ),
        
        // Task 5: Suicide Risk Detection (Binary)
        TaskConfig(
            type: .task5SuicideRiskBinary,
            name: "Task 5: Suicide Risk Detection (Binary)",
            datasetFile: "datasets/dataset/500_Reddit_user_posts_labels.csv",
            labelColumn: "Label",
            textColumn: "Post",
            numClasses: 2,
            classNames: ["0", "1"],
            promptTemplate: """
            You are a licensed clinical psychologist and suicide prevention specialist with expertise in risk assessment. Analyze the following Reddit post for suicide risk indicators.
            
            SUICIDE RISK ASSESSMENT CRITERIA:
            
            HIGH RISK INDICATORS (Classify as 1):
            - Suicidal ideation: thoughts about death, dying, or suicide
            - Hopelessness: "nothing will get better", "no way out", "pointless"
            - Burden feelings: "everyone would be better without me", "I'm a burden"
            - Social isolation: "nobody cares", "completely alone", "no one understands"
            - Mental health crisis: severe depression, anxiety, PTSD, substance abuse
            - Recent trauma: loss, abuse, major life changes combined with distress
            - Access to means: mentions of methods, previous attempts
            - Warning signs: "final goodbye", "making plans", "getting affairs in order"
            
            LOW RISK (Classify as 0):
            - Seeking support or help
            - Problem-solving mindset
            - Protective factors: family, friends, treatment, future plans
            - Normal stress responses without crisis indicators
            - Coping strategies mentioned
            - No suicidal content or hopelessness
            
            EXAMPLES:
            "I want to kill myself, nobody would miss me" → 1 (ideation + burden + isolation)
            "Feeling hopeless about my situation, need support" → 0 (seeking help)
            "Life isn't worth living, I have a plan" → 1 (hopelessness + planning)
            "Going through a tough time but have good friends" → 0 (protective factors)
            
            IMPORTANT: Respond with ONLY the number 0 or 1. No explanations.
            
            Post to analyze: {text}
            
            Risk assessment:
            """,
            maxTokens: 8,
            weight: 1.5,
            defaultValue: "0"
        ),
        
        // Task 6: Suicide Risk Severity Detection (5-level)
        TaskConfig(
            type: .task6SuicideRiskSeverity,
            name: "Task 6: Suicide Risk Severity Detection",
            datasetFile: "datasets/dataset/500_Reddit_user_posts_labels.csv",
            labelColumn: "Label",
            textColumn: "Post",
            numClasses: 5,
            classNames: ["1", "2", "3", "4", "5"],
            promptTemplate: """
            You are a senior clinical psychologist and suicide prevention expert specializing in risk stratification. Analyze the following Reddit post to determine suicide risk severity level using standardized assessment protocols.
            
            SUICIDE RISK SEVERITY LEVELS:
            
            LEVEL 1 (Supportive):
            - Seeking emotional support or advice
            - No risk indicators present
            - Healthy coping mechanisms
            - Strong protective factors
            - Future-oriented thinking
            - Language: "need advice", "seeking support", "looking for help"
            
            LEVEL 2 (Indicator):
            - Early warning signs present
            - Mild to moderate distress
            - Some vulnerability factors
            - No suicidal ideation
            - Language: "struggling", "having a hard time", "feeling down"
            
            LEVEL 3 (Ideation):
            - Explicit suicidal thoughts
            - Moderate risk level
            - Needs monitoring and support
            - Some protective factors may be present
            - Language: "want to die", "life isn't worth living", "wish I was dead"
            
            LEVEL 4 (Behavior):
            - Suicide-related behaviors mentioned
            - High risk indicators
            - Immediate intervention needed
            - Possible planning or preparation
            - Language: "have a plan", "thinking about methods", "getting ready"
            
            LEVEL 5 (Attempt):
            - Evidence of suicide attempts
            - Critical risk level
            - Urgent intervention required
            - Immediate safety concerns
            - Language: "tried to kill myself", "attempted suicide", "overdosed"
            
            EXAMPLES:
            "Need advice on dealing with stress" → 1 (supportive)
            "Feeling really down and hopeless" → 2 (indicator)
            "I want to die, life is meaningless" → 3 (ideation)
            "I have a plan to end it all" → 4 (behavior)
            "I tried to overdose last week" → 5 (attempt)
            
            IMPORTANT: Respond with ONLY the number 1, 2, 3, 4, or 5. No explanations.
            
            Post to analyze: {text}
            
            Severity level:
            """,
            maxTokens: 8,
            weight: 1.5,
            defaultValue: "1"
        )
    ]
}

// MARK: - Task Manager
class TaskManager {
    static let shared = TaskManager()
    
    private init() {}
    
    func getTaskConfig(for type: TaskType) -> TaskConfig? {
        return TaskConfig.allTasks.first { $0.type == type }
    }
    
    func getAllTaskTypes() -> [TaskType] {
        return TaskType.allCases
    }
    
    func getTaskName(for type: TaskType) -> String {
        return getTaskConfig(for: type)?.name ?? type.rawValue
    }
}

// MARK: - Dataset Loading
extension TaskManager {
    func loadDataset(for taskType: TaskType) -> [String: Any]? {
        guard let config = getTaskConfig(for: taskType) else {
            print("ERROR: No config found for task type: \(taskType)")
            return nil
        }
        
        let fileName = config.datasetFile
        let filePath = Bundle.main.path(forResource: fileName.replacingOccurrences(of: ".json", with: "").replacingOccurrences(of: ".csv", with: ""), ofType: fileName.hasSuffix(".json") ? "json" : "csv")
        
        guard let path = filePath else {
            print("ERROR: Dataset file not found: \(fileName)")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            
            if fileName.hasSuffix(".json") {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                return ["data": json, "type": "json"]
            } else if fileName.hasSuffix(".csv") {
                let csvString = String(data: data, encoding: .utf8) ?? ""
                let lines = csvString.components(separatedBy: .newlines)
                let headers = lines.first?.components(separatedBy: ",") ?? []
                var records: [[String: String]] = []
                
                for line in lines.dropFirst() {
                    if !line.isEmpty {
                        let values = line.components(separatedBy: ",")
                        var record: [String: String] = [:]
                        for (index, header) in headers.enumerated() {
                            if index < values.count {
                                record[header] = values[index]
                            }
                        }
                        records.append(record)
                    }
                }
                
                return ["data": records, "type": "csv", "headers": headers]
            }
        } catch {
            print("ERROR: Failed to load dataset \(fileName): \(error)")
        }
        
        return nil
    }
}

// MARK: - Prompt Generation
extension TaskManager {
    func generatePrompt(for taskType: TaskType, with data: [String: Any], modelName: String? = nil) -> String? {
        guard let config = getTaskConfig(for: taskType) else {
            return nil
        }
        
        var prompt = config.promptTemplate
        
        // Check model type and apply optimized prompts
        if let model = modelName {
            let modelLower = model.lowercased()
            // FIX: All models use the same detailed prompt for fair comparison
            // Previously Menta and Qwen3 used minimal prompts while phi-4-mini used detailed prompts, causing unfair comparison
            if modelLower.contains("qwen3") || modelLower.contains("qwen") || modelLower.contains("mental") || modelLower.contains("menta") {
                prompt = getQwenDetailedPrompt(for: taskType, with: data)
            } else if model.contains("phi-4-mini") {
                prompt = getPhi4OptimizedPrompt(for: taskType, with: data)
            } else if modelLower.contains("stableslm") || modelLower.contains("stablelm") {
                // StableSLM-3B uses standard detailed prompt
                prompt = getQwenDetailedPrompt(for: taskType, with: data)
            } else if modelLower.contains("falcon") {
                // Falcon-1.3B uses standard detailed prompt for fair comparison
                prompt = getQwenDetailedPrompt(for: taskType, with: data)
            } else {
                // Replace placeholders for other models - all new tasks use text field
                if let text = data["text"] as? String {
                    prompt = prompt.replacingOccurrences(of: "{text}", with: text)
                }
            }
        } else {
            // Replace placeholders for other models - all new tasks use text field
            if let text = data["text"] as? String {
                prompt = prompt.replacingOccurrences(of: "{text}", with: text)
            }
        }
        
        return prompt
    }
    
    // MARK: - Phi-4 Optimized Prompts (All CSV-based tasks)
    private func getPhi4OptimizedPrompt(for taskType: TaskType, with data: [String: Any]) -> String {
        guard let text = data["text"] as? String else {
            return ""
        }
        
        switch taskType {
        case .task1Stress:
            return """
            <|system|>
            You are an expert mental health analyst with 15+ years of experience in stress detection and assessment. Your task is to analyze Reddit posts for stress indicators with high accuracy.
            
            STRESS DETECTION CRITERIA:
            
            HIGH STRESS INDICATORS (Classify as 1):
            - Explicit stress mentions: "stressed", "overwhelmed", "can't handle", "too much pressure"
            - Anxiety symptoms: worry, panic, racing thoughts, restlessness
            - Physical stress: headaches, muscle tension, fatigue, sleep problems
            - Emotional overwhelm: frustration, irritability, feeling trapped, helplessness
            - Work/life pressure: deadlines, responsibilities, financial worries, relationship conflicts
            - Behavioral changes: social withdrawal, avoidance, substance use, appetite changes
            - Crisis language: "breaking point", "can't take it anymore", "falling apart"
            
            LOW/NO STRESS INDICATORS (Classify as 0):
            - Neutral or positive emotional tone
            - Problem-solving approach rather than overwhelmed
            - Stable daily routines and relationships
            - Seeking advice or sharing experiences without distress
            - Casual conversation or informational posts
            
            EXAMPLES:
            "I'm so stressed about my job, can't sleep" → 1 (explicit stress + sleep issues)
            "Having trouble with my roommate" → 0 (problem-solving, not overwhelmed)
            "Work is overwhelming me, I feel like I'm drowning" → 1 (overwhelmed + drowning metaphor)
            
            IMPORTANT: Respond with ONLY the number 0 or 1. No explanations.<|end|>
            <|user|>
            Post text: \(text)
            
            Classification:<|end|>
            <|assistant|>
            """
            
        case .task2DepressionBinary:
            return """
            <|system|>
            You are a clinical psychologist specializing in depression assessment with expertise in social media mental health screening. Analyze the following Reddit post for depression indicators.
            
            DEPRESSION DETECTION CRITERIA:
            
            DEPRESSION INDICATORS (Classify as 1):
            - Core symptoms: persistent sadness, hopelessness, emptiness, despair
            - Anhedonia: loss of interest, pleasure, motivation in activities
            - Cognitive symptoms: negative self-talk, guilt, worthlessness, suicidal thoughts
            - Physical symptoms: fatigue, sleep problems, appetite changes, low energy
            - Behavioral signs: social isolation, self-neglect, substance use
            - Language patterns: "nothing matters", "what's the point", "I'm worthless", "wish I was dead"
            - Duration: symptoms persisting for weeks or months
            
            NO DEPRESSION INDICATORS (Classify as 0):
            - Temporary sadness with clear cause
            - Grief response to loss
            - Normal mood fluctuations
            - Expressing frustration without hopelessness
            - Seeking support proactively
            - Positive future orientation
            
            EXAMPLES:
            "I've been feeling empty for months, nothing brings me joy anymore" → 1 (anhedonia + duration)
            "I'm sad my friend moved away" → 0 (situational sadness)
            "I feel worthless and everyone would be better off without me" → 1 (worthlessness + suicidal ideation)
            
            IMPORTANT: Respond with ONLY the number 0 or 1. No explanations.<|end|>
            <|user|>
            Post text: \(text)
            
            Classification:<|end|>
            <|assistant|>
            """
            
        case .task3DepressionSeverity:
            return """
            <|system|>
            You are a psychiatrist trained in depression severity assessment using standardized scales. Classify the depression severity level from Reddit posts.
            
            SEVERITY CLASSIFICATION (0-3):
            
            0 - MINIMAL/NONE:
            - Neutral or positive mood
            - Normal functioning
            - No significant symptoms
            - Healthy coping mechanisms
            
            1 - MILD:
            - Occasional low mood
            - Minor sleep/appetite changes
            - Still functioning adequately
            - Some negative thoughts but manageable
            - "Feeling a bit down lately"
            
            2 - MODERATE:
            - Frequent sadness or emptiness
            - Noticeable impact on daily life
            - Difficulty concentrating or motivating
            - Social withdrawal beginning
            - "Can't seem to enjoy things anymore"
            
            3 - SEVERE:
            - Persistent hopelessness and despair
            - Significant functional impairment
            - Strong suicidal ideation
            - Severe isolation or self-neglect
            - Crisis-level language
            - "I can't go on like this"
            
            EXAMPLES:
            "Having a rough week but managing" → 1 (mild, temporary)
            "Lost interest in my hobbies, sleeping too much" → 2 (moderate symptoms)
            "Life has no meaning, I want to disappear" → 3 (severe, suicidal ideation)
            
            IMPORTANT: Respond with ONLY a single number 0, 1, 2, or 3. No explanations.<|end|>
            <|user|>
            Post text: \(text)
            
            Classification:<|end|>
            <|assistant|>
            """
            
        case .task4SuicideIdeation:
            return """
            <|system|>
            You are a crisis intervention specialist with expertise in suicide risk assessment. Classify suicide ideation levels from Reddit posts.
            
            CLASSIFICATION LEVELS (0-2):
            
            0 - SUPPORTIVE/NO IDEATION:
            - Offering support or resources
            - No suicidal thoughts
            - Positive coping strategies
            - Help-seeking behavior
            - "You're not alone, please reach out"
            
            1 - IDEATION:
            - Thoughts of death or dying
            - Passive suicidal ideation
            - Wishing to not exist
            - No specific plan
            - "Sometimes I wish I wouldn't wake up"
            
            2 - BEHAVIOR/ATTEMPT:
            - Active planning or preparation
            - Past suicide attempts
            - Specific methods discussed
            - Imminent risk indicators
            - Final goodbyes or giving away possessions
            - "I've decided this is the end"
            
            WARNING SIGNS FOR LEVEL 2:
            - Method specificity
            - Timeframe mentioned
            - Farewell messages
            - Past attempts referenced
            - Acute hopelessness
            
            EXAMPLES:
            "If you're struggling, please call this hotline" → 0 (supportive)
            "I sometimes think everyone would be better off without me" → 1 (passive ideation)
            "I have the pills ready, tonight is the night" → 2 (active plan, imminent)
            
            IMPORTANT: Respond with ONLY a single number 0, 1, or 2. No explanations.<|end|>
            <|user|>
            Post text: \(text)
            
            Classification:<|end|>
            <|assistant|>
            """
            
        case .task5SuicideRiskBinary:
            return """
            <|system|>
            You are a crisis intervention specialist with expertise in suicide risk assessment. Classify posts as either low risk (0) or high risk (1) for suicide.
            
            BINARY CLASSIFICATION (0-1):
            
            0 - LOW RISK:
            - Supportive or resource-sharing content
            - General mental health discussions
            - Seeking help without immediate crisis indicators
            - Coping strategies and positive messaging
            - "You're not alone, please reach out for help"
            
            1 - HIGH RISK:
            - Any mention of suicidal thoughts, plans, or behaviors
            - Expressions of hopelessness or worthlessness
            - Discussion of suicide methods or timing
            - Goodbye messages or giving away possessions
            - Past or current suicide attempts
            - "I want to die", "life isn't worth living", "have a plan"
            
            EXAMPLES:
            "If you're struggling, here are some resources" → 0 (supportive)
            "I sometimes think about ending it all" → 1 (suicidal ideation)
            "Feeling hopeless and worthless lately" → 1 (high risk indicators)
            
            IMPORTANT: Respond with ONLY the number 0 or 1. No explanations.<|end|>
            <|user|>
            Post text: \(text)
            
            Classification:<|end|>
            <|assistant|>
            """
            
        case .task6SuicideRiskSeverity:
            return """
            <|system|>
            You are a crisis intervention specialist trained in suicide risk assessment. Classify the severity level of suicide risk from Reddit posts using a 5-level scale.
            
            SEVERITY CLASSIFICATION (1-5):
            
            LEVEL 1 (Supportive):
            - Offering support, resources, or encouragement
            - Sharing positive coping strategies
            - Help-seeking behavior
            - "You're not alone, please reach out"
            
            LEVEL 2 (Indicator):
            - General expressions of distress or hopelessness
            - Mild suicidal ideation without specificity
            - Feeling worthless or that life has no meaning
            - "Sometimes I wish I wouldn't wake up"
            
            LEVEL 3 (Ideation):
            - Clear suicidal thoughts expressed
            - Wishing to die or end life
            - Passive suicidal ideation
            - "I want to die", "life isn't worth living"
            
            LEVEL 4 (Behavior):
            - Suicide-related behaviors mentioned
            - Planning or preparation discussed
            - High risk indicators present
            - "I have a plan", "thinking about methods"
            
            LEVEL 5 (Attempt):
            - Evidence of suicide attempts
            - Critical risk level
            - Immediate intervention needed
            - "I tried to kill myself", "attempted suicide"
            
            EXAMPLES:
            "Need advice on dealing with stress" → 1 (supportive)
            "Feeling really down and hopeless" → 2 (indicator)
            "I want to die, life is meaningless" → 3 (ideation)
            "I have a plan to end it all" → 4 (behavior)
            "I tried to overdose last week" → 5 (attempt)
            
            IMPORTANT: Respond with ONLY the number 1, 2, 3, 4, or 5. No explanations.<|end|>
            <|user|>
            Post text: \(text)
            
            Classification:<|end|>
            <|assistant|>
            """
        }
    }
    
    // MARK: - Prompt Variants (Optimization learned from Python implementation)
    private func getRandomContext(for taskType: TaskType) -> String {
        let contexts: [String]
        
        switch taskType {
        case .task1Stress:
            contexts = [
                "You are an expert mental health analyst with 15+ years of experience in stress detection and assessment. Your task is to analyze Reddit posts for stress indicators with high accuracy.",
                "As a clinical psychologist, evaluate the mental well-being indicated in this social media post.",
                "As a mental health professional, assess the stress indicators in this post.",
                "You are a trained psychologist specializing in stress assessment from social media content."
            ]
        case .task2DepressionBinary, .task3DepressionSeverity:
            contexts = [
                "You are a clinical psychologist specializing in depression assessment with expertise in social media mental health screening.",
                "As a mental health professional, evaluate the depression indicators in this social media post.",
                "You are an expert in identifying depression from social media text.",
                "As a trained therapist, assess the mental state conveyed in this post."
            ]
        case .task4SuicideIdeation, .task5SuicideRiskBinary, .task6SuicideRiskSeverity:
            contexts = [
                "You are a crisis intervention specialist with expertise in identifying suicidal ideation.",
                "As a mental health professional, assess the suicide risk in this social media post.",
                "You are trained in detecting suicidal thoughts from text.",
                "As a crisis counselor, evaluate the suicide risk indicators in this post."
            ]
        }
        
        return contexts.randomElement() ?? contexts[0]
    }
    
    // MARK: - Qwen3 Optimized Prompts (All CSV-based tasks)
    private func getQwenOptimizedPrompt(for taskType: TaskType, with data: [String: Any]) -> String {
        guard let text = data["text"] as? String else {
            return ""
        }
        
        // Use medium-detail prompt - balance reasoning capability and token length
        return getQwenBalancedPrompt(for: taskType, text: text)
    }
    
    // NEW: Detailed Qwen prompt, equivalent to Phi4 detail level, ensuring fair comparison
    private func getQwenDetailedPrompt(for taskType: TaskType, with data: [String: Any]) -> String {
        guard let text = data["text"] as? String else {
            return ""
        }
        
        switch taskType {
        case .task1Stress:
            return """
            <|im_start|>system
            You are an expert mental health analyst with 15+ years of experience in stress detection and assessment. Your task is to analyze Reddit posts for stress indicators with high accuracy.
            
            STRESS DETECTION CRITERIA:
            
            HIGH STRESS INDICATORS (Classify as 1):
            - Explicit stress mentions: "stressed", "overwhelmed", "can't handle", "too much pressure"
            - Anxiety symptoms: worry, panic, racing thoughts, restlessness
            - Physical stress: headaches, muscle tension, fatigue, sleep problems
            - Emotional overwhelm: frustration, irritability, feeling trapped, helplessness
            - Work/life pressure: deadlines, responsibilities, financial worries, relationship conflicts
            - Behavioral changes: social withdrawal, avoidance, substance use, appetite changes
            - Crisis language: "breaking point", "can't take it anymore", "falling apart"
            
            LOW/NO STRESS INDICATORS (Classify as 0):
            - Neutral or positive emotional tone
            - Problem-solving approach rather than overwhelmed
            - Stable daily routines and relationships
            - Seeking advice or sharing experiences without distress
            - Casual conversation or informational posts
            
            EXAMPLES:
            "I'm so stressed about my job, can't sleep" → 1 (explicit stress + sleep issues)
            "Having trouble with my roommate" → 0 (problem-solving, not overwhelmed)
            "Work is overwhelming me, I feel like I'm drowning" → 1 (overwhelmed + drowning metaphor)
            
            IMPORTANT: Respond with ONLY the number 0 or 1. No explanations.<|im_end|>
            <|im_start|>user
            Post text: \(text)
            
            Classification:<|im_end|>
            <|im_start|>assistant
            """
            
        case .task2DepressionBinary:
            return """
            <|im_start|>system
            You are a clinical psychologist specializing in depression assessment with expertise in social media mental health screening. Analyze the following Reddit post for depression indicators.
            
            DEPRESSION DETECTION CRITERIA:
            
            DEPRESSION INDICATORS (Classify as 1):
            - Persistent sadness: "always sad", "can't stop crying", "feel hopeless"
            - Loss of interest: "nothing matters", "don't care about anything", "lost motivation"
            - Worthlessness: "I'm worthless", "hate myself", "I'm a failure"
            - Fatigue: "always tired", "no energy", "exhausted all the time"
            - Sleep issues: insomnia, oversleeping, irregular sleep patterns
            - Appetite changes: significant weight loss/gain, eating disorders
            - Concentration problems: "can't focus", "brain fog", "forgetful"
            - Suicidal ideation: thoughts of death, self-harm, ending life
            
            NOT DEPRESSED INDICATORS (Classify as 0):
            - Temporary sadness with clear triggers and recovery
            - Seeking help constructively: therapy, support groups, medication
            - Problem-solving mindset: looking for solutions, taking action
            - Positive coping strategies: exercise, hobbies, social connections
            - Realistic self-assessment: acknowledging challenges but maintaining hope
            
            EXAMPLES:
            "I've been feeling really down lately, nothing seems to matter" → 1 (persistent sadness + loss of interest)
            "Had a bad day at work, but I'll bounce back" → 0 (temporary, optimistic)
            "I hate myself and want to disappear" → 1 (worthlessness + suicidal ideation)
            
            IMPORTANT: Respond with ONLY the number 0 or 1. No explanations.<|im_end|>
            <|im_start|>user
            Post text: \(text)
            
            Classification:<|im_end|>
            <|im_start|>assistant
            """
            
        case .task3DepressionSeverity:
            return """
            <|im_start|>system
            You are a psychiatrist specializing in depression assessment. Rate the depression severity level in this Reddit post.
            
            SEVERITY LEVELS:
            
            0 = MINIMAL (No depression symptoms):
            - Normal mood fluctuations
            - No significant impairment in daily functioning
            - Temporary sadness with clear recovery
            
            1 = MILD (Some symptoms, minimal impairment):
            - Occasional sadness or low mood
            - Slight decrease in interest or pleasure
            - Minor sleep or appetite changes
            - Still able to function normally
            
            2 = MODERATE (Clear symptoms, noticeable impairment):
            - Persistent sadness most days
            - Significant loss of interest in activities
            - Noticeable sleep/appetite changes
            - Difficulty concentrating
            - Some impact on work/social functioning
            
            3 = SEVERE (Intense symptoms, significant impairment):
            - Overwhelming sadness and hopelessness
            - Complete loss of interest in life
            - Severe sleep/appetite disturbances
            - Inability to concentrate or make decisions
            - Significant functional impairment
            - Possible suicidal thoughts
            
            EXAMPLES:
            "Feeling a bit down today" → 0 (minimal)
            "I've been sad lately and not enjoying things as much" → 1 (mild)
            "I'm really struggling with depression, can't focus at work" → 2 (moderate)
            "I feel completely hopeless and want to die" → 3 (severe)
            
            IMPORTANT: Respond with ONLY the number 0, 1, 2, or 3. No explanations.<|im_end|>
            <|im_start|>user
            Post text: \(text)
            
            Severity rating:<|im_end|>
            <|im_start|>assistant
            """
            
        case .task4SuicideIdeation, .task5SuicideRiskBinary, .task6SuicideRiskSeverity:
            return """
            <|im_start|>system
            You are a crisis intervention specialist with expertise in identifying suicidal ideation and risk assessment. Analyze this Reddit post for suicide risk indicators.
            
            SUICIDE RISK ASSESSMENT:
            
            HIGH RISK INDICATORS:
            - Direct statements: "I want to die", "I should kill myself", "life isn't worth living"
            - Indirect expressions: hopelessness about the future, feeling like a burden, wishing to disappear
            - Context factors: recent losses, trauma, mental health struggles, substance use
            - Planning: specific methods, timing, access to means
            - Previous attempts: history of self-harm or suicide attempts
            
            PROTECTIVE FACTORS:
            - Social support: family, friends, community connections
            - Coping strategies: therapy, medication, healthy activities
            - Future plans: goals, commitments, responsibilities
            - Help-seeking: reaching out for support, professional help
            
            RISK LEVELS:
            - 0 = LOW RISK: Supportive content, general discussions, seeking help constructively
            - 1 = HIGH RISK: Clear suicidal ideation, hopelessness, or crisis indicators
            
            EXAMPLES:
            "I'm thinking about ending it all" → 1 (direct suicidal ideation)
            "Feeling hopeless but reaching out for help" → 0 (seeking support)
            "Life has no meaning anymore" → 1 (hopelessness)
            
            IMPORTANT: Respond with ONLY the number 0 or 1. No explanations.<|im_end|>
            <|im_start|>user
            Post text: \(text)
            
            Risk assessment:<|im_end|>
            <|im_start|>assistant
            """
        }
    }
    
    // MARK: - Qwen3 Balanced Prompts (Balanced version - reasoning capability + token efficiency)
    private func getQwenBalancedPrompt(for taskType: TaskType, text: String) -> String {
        switch taskType {
        case .task1Stress:
            return """
            <|im_start|>system
            You are a mental health expert. Analyze if this post shows stress.

            Stress indicators: overwhelmed, anxious, can't handle pressure, sleep problems, irritability.
            Not stressed: neutral tone, problem-solving, seeking advice calmly.
            
            Reply ONLY 0 (not stressed) or 1 (stressed).
            <|im_end|>
            <|im_start|>user
            \(text)
            <|im_end|>
            <|im_start|>assistant
            """
        case .task2DepressionBinary:
            return """
            <|im_start|>system
            You are a psychologist. Analyze if this post shows depression.
            
            Depression signs: persistent sadness, hopelessness, loss of interest, worthlessness, suicidal thoughts.
            Not depressed: temporary sadness, seeking help constructively, problem-solving mindset.
            
            Reply ONLY 0 (not depressed) or 1 (depressed).
            <|im_end|>
            <|im_start|>user
            \(text)
            <|im_end|>
            <|im_start|>assistant
            """
        case .task3DepressionSeverity:
            return """
            <|im_start|>system
            You are a psychiatrist. Rate depression severity level.
            
            0=minimal (no symptoms), 1=mild (some symptoms, minimal impairment), 2=moderate (clear symptoms, noticeable impairment), 3=severe (intense symptoms, significant impairment).
            
            Reply ONLY 0, 1, 2, or 3.
            <|im_end|>
            <|im_start|>user
            \(text)
            <|im_end|>
            <|im_start|>assistant
            """
        case .task4SuicideIdeation:
            return """
            <|im_start|>system
            You are a crisis specialist. Detect suicidal ideation.
            
            Ideation signs: "want to die", "kill myself", "life isn't worth living", feeling like a burden, wishing to disappear.
            No ideation: no mention of death/suicide, seeking help, future planning.
            
            Reply ONLY 0 (no ideation) or 1 (has ideation).
            <|im_end|>
            <|im_start|>user
            \(text)
            <|im_end|>
            <|im_start|>assistant
            """
        case .task5SuicideRiskBinary:
            return """
            <|im_start|>system
            Suicide risk? 0 or 1.
            <|im_end|>
            <|im_start|>user
            \(text)
            <|im_end|>
            <|im_start|>assistant
            """
        case .task6SuicideRiskSeverity:
            return """
            <|im_start|>system
            Risk level 1-5?
            <|im_end|>
            <|im_start|>user
            \(text)
            <|im_end|>
            <|im_start|>assistant
            """
        }
    }
}

// MARK: - Evaluation
extension TaskManager {
    func evaluateResponse(for taskType: TaskType, predicted: String, expected: String?) -> Bool {
        guard let config = getTaskConfig(for: taskType) else {
            return false
        }
        
        let predictedValue = predicted.trimmingCharacters(in: .whitespacesAndNewlines)
        let expectedValue = expected?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        print("DEBUG: Evaluating - Predicted: '\(predictedValue)', Expected: '\(expectedValue)'")
        
        // All tasks now use numeric labels, so direct comparison
        let isCorrect = predictedValue == expectedValue
        
        // If prediction is empty or invalid, use default value
        if predictedValue.isEmpty || !config.classNames.contains(predictedValue) {
            print("DEBUG: Invalid prediction '\(predictedValue)', using default: '\(config.defaultValue)'")
            return config.defaultValue == expectedValue
        }
        
        print("DEBUG: Evaluation result: \(isCorrect)")
        return isCorrect
    }
}
