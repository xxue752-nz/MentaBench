//
//  ContentView.swift
//  MentaBench
//
//  Created by Tulika Awalgaonkar on 6/3/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject var llamaState = LlamaState()
    @State private var selectedModel: String = "Menta"
    @State private var selectedTask: String = "Task 1: Stress Detection"
    @State private var selectedExample: Int = 10
    
    // Model list - simplified to only keep essential models
    let models = [
        "Menta",
        "phi-4-mini",
        "Qwen3-4B-Instruct",
        "StableSLM-3B",
        "Falcon-1.3B"
    ]
    
    let text_examples = [10, 50, 100, 500, 1000, 2000, 3000]
    let MM_examples = [10, 25, 50, 100, 200, 500]
    
    // New task system only
    let newTaskNames = TaskType.allCases.map { TaskManager.shared.getTaskName(for: $0) }
    
    var examples: [Int] {
        return text_examples  // All remaining models are text-based
    }
        
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with solid color background (research style)
                VStack(spacing: 20) {
                    Text("Menta")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 10)
                    
                    Text("Mental Health AI Model Evaluation")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(Color(red: 0.2, green: 0.3, blue: 0.5))  // Solid professional blue
                
                // Configuration Section
                VStack(spacing: 20) {
                    VStack(spacing: 15) {
                        // Model Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Label("AI Model", systemImage: "cpu")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Picker("Select Model", selection: $selectedModel) {
                                ForEach(models, id: \.self) { model in
                                    Text(model).tag(model)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        
                        // Task Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Evaluation Task", systemImage: "list.bullet.clipboard")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Picker("Select Task", selection: $selectedTask) {
                                ForEach(newTaskNames, id: \.self) { task in
                                    Text(task)
                                        .tag(task)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        
                        // Sample Count Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Sample Count", systemImage: "number")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Picker("Select Example Count", selection: $selectedExample) {
                                ForEach(examples, id: \.self) { example in
                                    Text("\(example) samples")
                                        .tag(example)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 20)
                    .padding(.top, -20)
                    
                    // Run Button (solid color, research style)
                    Button(action: {
                        runNewTask()
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                                .font(.title2)
                            Text("Start Evaluation")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color(red: 0.2, green: 0.5, blue: 0.3))  // Solid professional green
                        .cornerRadius(8)
                    }
                    .disabled(selectedModel.isEmpty || selectedTask.isEmpty)
                    .padding(.horizontal, 20)
                    
                    // Current Input Section
                    if !llamaState.currentInput.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "doc.text")
                                    .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.5))
                                Text("Current Input")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            
                            ScrollView {
                                Text(llamaState.currentInput)
                                    .font(.system(.body, design: .default))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                            .frame(maxHeight: 120)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    
                    // Results Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.5))
                            Text("Evaluation Results")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        
                        ScrollView {
                            Text(llamaState.messageLog.isEmpty ? "No results yet. Start an evaluation to see performance metrics here." : llamaState.messageLog)
                                .font(.system(.body, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        .frame(maxHeight: 300)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
                
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func runNewTask() {
        guard let taskType = getTaskTypeFromName(selectedTask) else {
            print("ERROR: Invalid task type: \(selectedTask)")
            return
        }
        
        let modelPath = getModelPath(for: selectedModel)
        print("DEBUG: Running evaluation: \(taskType.rawValue) with model: \(selectedModel)")
        
        Task {
            llamaState.evaluateTask(
                taskType: taskType,
                modelPath: modelPath,
                modelName: selectedModel,
                maxExamples: selectedExample
            )
        }
    }
    
    private func getTaskTypeFromName(_ name: String) -> TaskType? {
        return TaskType.allCases.first(where: { TaskManager.shared.getTaskName(for: $0) == name })
    }
    
    private func getModelPath(for modelName: String) -> String {
        switch modelName {
        case "Menta":
            return "Menta.gguf"
        case "phi-4-mini":
            return "Phi-4-mini-instruct-Q4_K_M.gguf"
        case "Qwen3-4B-Instruct":
            return "qwen3-4b_Q4_K_M.gguf"
        case "StableSLM-3B":
            return "StableSLM-3B-f16.gguf"
        case "Falcon-1.3B":
            return "Falcon-1.3B-q8_0.gguf"
        default:
            return "Menta.gguf"
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
    
    
}
