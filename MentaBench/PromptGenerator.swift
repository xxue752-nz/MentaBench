//
//  PromptGenerator.swift
//  MentaBench
//
//  Prompt variant generator - Based on Python implementation
//  Provides multiple prompt variants to improve model generalization
//

import Foundation

/// Prompt components
struct PromptComponents {
    let contexts: [String]
    let questions: [String]
    let constraint: String
}

/// Prompt generator
class PromptGenerator {
    
    /// Generate random prompt for specified task
    static func generatePrompt(for taskType: TaskType, text: String, useRandomVariant: Bool = true) -> String {
        let components = getPromptComponents(for: taskType)
        
        // Randomly select or use first one
        let context = useRandomVariant ? 
            components.contexts.randomElement() ?? components.contexts[0] :
            components.contexts[0]
        
        let question = useRandomVariant ?
            components.questions.randomElement() ?? components.questions[0] :
            components.questions[0]
        
        // Use Qwen3's ChatML format
        return """
        <|im_start|>system
        \(context)
        
        \(components.constraint)
        <|im_end|>
        <|im_start|>user
        Post text: \(text)
        
        \(question)
        <|im_end|>
        <|im_start|>assistant
        """
    }
    
    /// Get prompt components for task
    private static func getPromptComponents(for taskType: TaskType) -> PromptComponents {
        switch taskType {
            
        case .task1Stress:
            return PromptComponents(
                contexts: [
                    "You are an expert mental health analyst with 15+ years of experience in stress detection and assessment.",
                    "As a clinical psychologist, evaluate the mental well-being indicated in this social media post.",
                    "As a mental health professional, assess the stress indicators in this post.",
                    "You are a trained psychologist specializing in stress assessment from social media content.",
                    "As an experienced therapist, analyze the stress levels expressed in this text."
                ],
                questions: [
                    "Does the author of this post appear to be stressed?",
                    "Is the poster stressed?",
                    "Does this post indicate stress?",
                    "Is there evidence of stress in this post?",
                    "Does the person show signs of being stressed?"
                ],
                constraint: """
                IMPORTANT: 
                - Respond with ONLY `0` or `1`
                - `1` means stressed, `0` means not stressed
                - Do not reply anything else
                """
            )
            
        case .task2DepressionBinary:
            return PromptComponents(
                contexts: [
                    "You are a clinical psychologist specializing in depression assessment with expertise in social media mental health screening.",
                    "As a mental health professional, evaluate the depression indicators in this social media post.",
                    "You are an expert in identifying depression from social media text.",
                    "As a trained therapist, assess the mental state conveyed in this post.",
                    "You are a psychologist with experience in depression detection from online content."
                ],
                questions: [
                    "Is the poster depressed?",
                    "Does the author show signs of depression?",
                    "Is there evidence of depression in this post?",
                    "Does this post indicate depression?",
                    "Is the person experiencing depression?"
                ],
                constraint: """
                IMPORTANT:
                - Respond with ONLY `0` or `1`
                - `1` means depression, `0` means no depression
                - Do not reply anything else
                """
            )
            
        case .task3DepressionSeverity:
            return PromptComponents(
                contexts: [
                    "You are a clinical psychologist specializing in depression severity assessment.",
                    "As a mental health professional, rate the depression level in this social media post.",
                    "You are an expert in classifying depression severity from text.",
                    "As a trained psychiatrist, evaluate the depression level expressed in this post.",
                    "You are a psychologist with expertise in assessing depression severity."
                ],
                questions: [
                    "Which level is the person depressed?",
                    "What is the depression severity level?",
                    "How severe is the person's depression?",
                    "Rate the depression level of this person.",
                    "What level of depression does this post indicate?"
                ],
                constraint: """
                IMPORTANT:
                - Respond with ONLY `0`, `1`, `2`, or `3`
                - `0` means minimal, `1` means mild, `2` means moderate, `3` means severe
                - Do not reply anything else
                """
            )
            
        case .task4SuicideIdeation:
            return PromptComponents(
                contexts: [
                    "You are a crisis intervention specialist with expertise in identifying suicidal ideation.",
                    "As a mental health professional, assess the suicide risk in this social media post.",
                    "You are trained in detecting suicidal thoughts from text.",
                    "As a crisis counselor, evaluate the suicidal ideation indicators in this post.",
                    "You are an expert in suicide risk assessment from online content."
                ],
                questions: [
                    "Does the post indicate suicidal ideation?",
                    "Is there evidence of suicidal thoughts in this post?",
                    "Does the author express suicidal ideation?",
                    "Are there signs of suicidal thinking in this post?",
                    "Does this post show suicidal ideation?"
                ],
                constraint: """
                IMPORTANT:
                - Respond with ONLY `0` or `1`
                - `1` means suicidal ideation, `0` means not suicidal ideation
                - Do not reply anything else
                """
            )
            
        case .task5SuicideRiskBinary:
            return PromptComponents(
                contexts: [
                    "You are a suicide prevention specialist evaluating suicide risk indicators.",
                    "As a crisis intervention expert, assess the suicide risk in this social media post.",
                    "You are trained in identifying suicide risk factors from text.",
                    "As a mental health professional, evaluate the suicide risk level in this post.",
                    "You are an expert in suicide risk assessment."
                ],
                questions: [
                    "Does the user show at least an indicator of suicide risk?",
                    "Is there evidence of suicide risk indicators in this post?",
                    "Does the author show signs of suicide risk?",
                    "Is there any level of suicide risk in this post?",
                    "Does this post indicate suicide risk?"
                ],
                constraint: """
                IMPORTANT:
                - Respond with ONLY `0` or `1`
                - `1` means at least indicator of suicide risk, `0` means not at risk
                - Do not reply anything else
                """
            )
            
        case .task6SuicideRiskSeverity:
            return PromptComponents(
                contexts: [
                    "You are a crisis intervention specialist trained in classifying suicide risk severity levels.",
                    "As a suicide prevention expert, rate the suicide risk level in this social media post.",
                    "You are trained in assessing suicide risk severity from online content.",
                    "As a mental health professional, classify the suicide risk level in this post.",
                    "You are an expert in suicide risk severity assessment."
                ],
                questions: [
                    "Which level of suicide risk does the person have?",
                    "What is the suicide risk level in this post?",
                    "Classify the suicide risk level expressed here.",
                    "How would you assess the suicide risk in this post?",
                    "What severity level of suicide risk is indicated?"
                ],
                constraint: """
                IMPORTANT:
                - Respond with ONLY `1`, `2`, `3`, `4`, or `5`
                - `1` = Supportive (no risk)
                - `2` = Indicator (indirect signs)
                - `3` = Ideation (suicidal thoughts)
                - `4` = Behavior (suicide-related actions)
                - `5` = Attempt (actual attempts)
                - Do not reply anything else
                """
            )
        }
    }
    
    /// Generate simple prompt with standardized format (for quick testing)
    static func generateSimplePrompt(for taskType: TaskType, text: String) -> String {
        return generatePrompt(for: taskType, text: text, useRandomVariant: false)
    }
    
    /// Get all prompt variants (for analysis)
    static func getAllVariants(for taskType: TaskType) -> (contexts: [String], questions: [String]) {
        let components = getPromptComponents(for: taskType)
        return (components.contexts, components.questions)
    }
}

