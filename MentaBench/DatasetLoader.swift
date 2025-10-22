//
//  DatasetLoader.swift
//  MentaBench
//
//  Created by Assistant on 2025-01-10.
//

import Foundation

// MARK: - Dataset Item
struct DatasetItem {
    let id: String
    let data: [String: Any]
    let expectedOutput: String?
}

// MARK: - Dataset Loader
class DatasetLoader {
    static let shared = DatasetLoader()
    
    private init() {}
    
    func loadDataset(for taskType: TaskType, maxSamples: Int = 10) -> [DatasetItem] {
        print("DEBUG: Loading dataset for task type: \(taskType.rawValue)")
        guard let config = TaskManager.shared.getTaskConfig(for: taskType) else {
            print("ERROR: No config found for task type: \(taskType)")
            return []
        }
        
        print("DEBUG: Config - datasetFile: \(config.datasetFile), labelColumn: \(config.labelColumn), textColumn: \(config.textColumn)")
        
        let fileName = config.datasetFile
        print("DEBUG: Dataset file name: \(fileName)")
        
        // Handle both simple filenames and paths with subdirectories
        var fileURL: URL?
        if fileName.contains("/") {
            // Handle paths with subdirectories (e.g., "datasets/databricks_dolly.json")
            let components = fileName.components(separatedBy: "/")
            let directory = components.dropLast().joined(separator: "/")
            let filename = components.last!
            let nameWithoutExtension = filename.replacingOccurrences(of: ".json", with: "").replacingOccurrences(of: ".csv", with: "")
            let fileExtension = filename.hasSuffix(".json") ? "json" : "csv"
            
            fileURL = Bundle.main.url(forResource: nameWithoutExtension, withExtension: fileExtension, subdirectory: directory)
        } else {
            // Handle simple filenames (e.g., "databricks_dolly.json")
            let nameWithoutExtension = fileName.replacingOccurrences(of: ".json", with: "").replacingOccurrences(of: ".csv", with: "")
            let fileExtension = fileName.hasSuffix(".json") ? "json" : "csv"
            
            fileURL = Bundle.main.url(forResource: nameWithoutExtension, withExtension: fileExtension)
        }
        
        guard let url = fileURL else {
            print("ERROR: Dataset file not found: \(fileName)")
            print("DEBUG: Tried to find file at: \(fileURL?.path ?? "nil")")
            print("DEBUG: Bundle main path: \(Bundle.main.bundlePath)")
            return []
        }
        
        print("DEBUG: Found dataset file at: \(url.path)")
        
        do {
            let data = try Data(contentsOf: url)
            
            if fileName.hasSuffix(".json") {
                return loadJSONDataset(data: data, taskType: taskType, maxSamples: maxSamples)
            } else if fileName.hasSuffix(".csv") {
                return loadCSVDataset(data: data, taskType: taskType, maxSamples: maxSamples)
            }
        } catch {
            print("ERROR: Failed to load dataset \(fileName): \(error)")
        }
        
        return []
    }
    
    private func loadJSONDataset(data: Data, taskType: TaskType, maxSamples: Int) -> [DatasetItem] {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            // All new tasks use CSV datasets, not JSON
            print("ERROR: All new tasks use CSV datasets, JSON loading not supported for: \(taskType)")
            return []
        } catch {
            print("ERROR: Failed to parse JSON: \(error)")
            return []
        }
    }
    
    private func loadCSVDataset(data: Data, taskType: TaskType, maxSamples: Int) -> [DatasetItem] {
        guard let csvString = String(data: data, encoding: .utf8) else {
            print("ERROR: Failed to convert CSV data to string")
            return []
        }
        
        let lines = csvString.components(separatedBy: .newlines)
        print("DEBUG: Total lines in CSV file: \(lines.count)")
        guard lines.count > 1 else {
            print("ERROR: CSV file is empty or has no headers")
            return []
        }
        
        // Parse headers with proper CSV parsing
        guard let headers = parseCSVLine(lines.first ?? "") else {
            print("ERROR: Failed to parse CSV headers")
            return []
        }
        
        // Debug: Print available columns
        print("DEBUG: Available columns in CSV: \(headers)")
        
        var items: [DatasetItem] = []
        let dataLines = lines.dropFirst() // Skip header
        print("DEBUG: Data lines count (excluding header): \(dataLines.count)")
        print("DEBUG: Max samples requested: \(maxSamples)")
        
        for (index, line) in dataLines.enumerated() {
            if index >= maxSamples { 
                print("DEBUG: Reached max samples limit (\(maxSamples))")
                break 
            }
            
            if !line.isEmpty {
                guard let values = parseCSVLine(line) else {
                    print("ERROR: Failed to parse CSV line \(index + 2)")
                    continue
                }
                
                var record: [String: String] = [:]
                
                for (headerIndex, header) in headers.enumerated() {
                    if headerIndex < values.count {
                        record[header] = values[headerIndex]
                    }
                }
                
                print("DEBUG: Processing line \(index + 1), record keys: \(Array(record.keys))")
                let item = createDatasetItem(from: record, taskType: taskType)
                items.append(item)
            } else {
                print("DEBUG: Skipping empty line \(index + 1)")
            }
        }
        
        print("DEBUG: Successfully loaded \(items.count) items from CSV")
        
        return items
    }
    
    // Helper function to properly parse CSV lines with quoted fields
    private func parseCSVLine(_ line: String) -> [String]? {
        var fields: [String] = []
        var currentField = ""
        var inQuotes = false
        var i = line.startIndex
        
        while i < line.endIndex {
            let char = line[i]
            
            if char == "\"" {
                if inQuotes {
                    // Check if this is an escaped quote
                    let nextIndex = line.index(after: i)
                    if nextIndex < line.endIndex && line[nextIndex] == "\"" {
                        currentField += "\""
                        i = line.index(after: nextIndex)
                        continue
                    } else {
                        inQuotes = false
                    }
                } else {
                    inQuotes = true
                }
            } else if char == "," && !inQuotes {
                fields.append(currentField)
                currentField = ""
            } else {
                currentField += String(char)
            }
            
            i = line.index(after: i)
        }
        
        fields.append(currentField)
        return fields
    }
    
    // MARK: - JSON Dataset Loaders
    
    private func loadQuestionAnsweringDataset(json: Any, maxSamples: Int) -> [DatasetItem] {
        guard let items = json as? [[String: Any]] else {
            print("ERROR: Invalid JSON format for question answering dataset")
            return []
        }
        
        var datasetItems: [DatasetItem] = []
        
        for (index, item) in items.enumerated() {
            if index >= maxSamples { break }
            
            if let question = item["question"] as? String,
               let answer = item["answer"] as? String,
               let context = item["context"] as? String {
                
                let data: [String: Any] = [
                    "question": question,
                    "context": context
                ]
                
                let datasetItem = DatasetItem(
                    id: "qa_\(index)",
                    data: data,
                    expectedOutput: answer
                )
                
                datasetItems.append(datasetItem)
            }
        }
        
        return datasetItems
    }
    
    private func loadSummarizationDataset(json: Any, maxSamples: Int) -> [DatasetItem] {
        guard let items = json as? [[String: Any]] else {
            print("ERROR: Invalid JSON format for summarization dataset")
            return []
        }
        
        var datasetItems: [DatasetItem] = []
        
        for (index, item) in items.enumerated() {
            if index >= maxSamples { break }
            
            if let document = item["document"] as? String,
               let summary = item["summary"] as? String {
                
                let data: [String: Any] = [
                    "document": document
                ]
                
                let datasetItem = DatasetItem(
                    id: "sum_\(index)",
                    data: data,
                    expectedOutput: summary
                )
                
                datasetItems.append(datasetItem)
            }
        }
        
        return datasetItems
    }
    
    private func loadSQLGenerationDataset(json: Any, maxSamples: Int) -> [DatasetItem] {
        guard let items = json as? [[String: Any]] else {
            print("ERROR: Invalid JSON format for SQL generation dataset")
            return []
        }
        
        var datasetItems: [DatasetItem] = []
        
        for (index, item) in items.enumerated() {
            if index >= maxSamples { break }
            
            if let question = item["question"] as? String,
               let answer = item["answer"] as? String,
               let context = item["context"] as? String {
                
                let data: [String: Any] = [
                    "question": question,
                    "context": context
                ]
                
                let datasetItem = DatasetItem(
                    id: "sql_\(index)",
                    data: data,
                    expectedOutput: answer
                )
                
                datasetItems.append(datasetItem)
            }
        }
        
        return datasetItems
    }
    
    private func loadTrustSafetyDataset(json: Any, maxSamples: Int) -> [DatasetItem] {
        guard let items = json as? [[String: Any]] else {
            print("ERROR: Invalid JSON format for trust & safety dataset")
            return []
        }
        
        var datasetItems: [DatasetItem] = []
        
        for (index, item) in items.enumerated() {
            if index >= maxSamples { break }
            
            if let question = item["question"] as? String,
               let answer = item["answer"] as? String,
               let context = item["context"] as? String {
                
                let data: [String: Any] = [
                    "question": question,
                    "context": context
                ]
                
                let datasetItem = DatasetItem(
                    id: "ts_\(index)",
                    data: data,
                    expectedOutput: answer
                )
                
                datasetItems.append(datasetItem)
            }
        }
        
        return datasetItems
    }
    
    // MARK: - CSV Dataset Loaders
    
    private func createDatasetItem(from record: [String: String], taskType: TaskType) -> DatasetItem {
        let id = "\(taskType.rawValue)_\(record["id"] ?? "unknown")"
        
        switch taskType {
        case .task1Stress:
            // For dreaddit_StressAnalysis - Sheet1.csv: columns are "text", "label"
            let text = record["text"] ?? ""
            let label = record["label"] ?? "0"  // Directly use label from CSV
            
            let data: [String: Any] = ["text": text]
            return DatasetItem(id: id, data: data, expectedOutput: label)
            
        case .task2DepressionBinary:
            // For Reddit_depression_dataset.csv: columns are "text", "label" 
            let text = record["text"] ?? ""
            let rawLabel = record["label"] ?? "minimum"
            
            // Map text labels to binary numeric labels
            let label: String
            switch rawLabel.lowercased() {
            case "minimum": label = "0"  // No depression
            case "mild", "moderate", "severe": label = "1"  // Depression present
            default: label = "0"  // Default to no depression
            }
            
            print("DEBUG Task2: rawLabel='\(rawLabel)' → mappedLabel='\(label)'")
            let data: [String: Any] = ["text": text]
            return DatasetItem(id: id, data: data, expectedOutput: label)
            
        case .task3DepressionSeverity:
            // For Reddit_depression_dataset.csv: 4-level depression severity
            let text = record["text"] ?? ""
            let rawLabel = record["label"] ?? "minimum"
            
            // Map text labels to numeric labels
            let label: String
            switch rawLabel.lowercased() {
            case "minimum": label = "0"
            case "mild": label = "1"
            case "moderate": label = "2"
            case "severe": label = "3"
            default: label = "0"  // Default to minimum
            }
            
            print("DEBUG Task3: rawLabel='\(rawLabel)' → mappedLabel='\(label)'")
            let data: [String: Any] = ["text": text]
            return DatasetItem(id: id, data: data, expectedOutput: label)
            
        case .task4SuicideIdeation:
            // For SDCNL.csv: columns are "title", "selftext", "is_suicide"
            print("DEBUG Task4: Available record keys: \(Array(record.keys))")
            
            // Use correct column names from the actual CSV file
            let title = record["title"] ?? ""
            let selftext = record["selftext"] ?? ""
            let label = record["is_suicide"] ?? "0"
            
            let text = "\(title)\n\n\(selftext)".trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Check if we have valid content
            if text.isEmpty {
                print("WARNING Task4: Empty text content for record \(id)")
                return DatasetItem(id: id, data: ["text": ""], expectedOutput: "0")
            }
            
            print("DEBUG Task4: title='\(title)', selftext='\(selftext.prefix(50))...', label='\(label)', combined_text='\(text.prefix(100))...'")
            let data: [String: Any] = ["text": text]
            return DatasetItem(id: id, data: data, expectedOutput: label)
            
        case .task5SuicideRiskBinary:
            // For 500_Reddit_user_posts_labels.csv: columns are "Post", "Label"
            let text = record["Post"] ?? ""
            let rawLabel = record["Label"] ?? "Supportive"
            
            // Map text labels to binary numeric labels
            // Supportive (no risk) -> 0, others (Indicator/Ideation/Behavior/Attempt) -> 1
            let label: String
            switch rawLabel {
            case "Supportive": label = "0"
            case "Indicator", "Ideation", "Behavior", "Attempt": label = "1"
            default: label = "0"  // Default to no risk
            }
            
            let data: [String: Any] = ["text": text]
            return DatasetItem(id: id, data: data, expectedOutput: label)
            
        case .task6SuicideRiskSeverity:
            // For 500_Reddit_user_posts_labels.csv: 5-level suicide risk severity
            let text = record["Post"] ?? ""
            let rawLabel = record["Label"] ?? "Supportive"
            
            // Map text labels to numeric labels (1-5)
            let label: String
            switch rawLabel {
            case "Supportive": label = "1"
            case "Indicator": label = "2"
            case "Ideation": label = "3"
            case "Behavior": label = "4"
            case "Attempt": label = "5"
            default: label = "1"  // Default to Supportive (lowest risk)
            }
            
            let data: [String: Any] = ["text": text]
            return DatasetItem(id: id, data: data, expectedOutput: label)
            
        default:
            print("ERROR: Unsupported task type for CSV dataset: \(taskType)")
            return DatasetItem(id: id, data: [:], expectedOutput: nil)
        }
    }
}
