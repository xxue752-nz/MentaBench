//
//  BatchProcessor.swift
//  MentaBench
//
//  Batch processing and memory management tools
//  Optimized based on Python implementation
//

import Foundation

/// Batch processing configuration
struct BatchConfig {
    /// Number of samples per batch
    let batchSize: Int
    /// Memory cleanup interval (cleanup every N batches)
    let memoryCleanupInterval: Int
    /// Whether to show detailed progress
    let showDetailedProgress: Bool
    
    static let `default` = BatchConfig(
        batchSize: 20,
        memoryCleanupInterval: 5,
        showDetailedProgress: true
    )
    
    static let fast = BatchConfig(
        batchSize: 50,
        memoryCleanupInterval: 10,
        showDetailedProgress: false
    )
    
    static let lowMemory = BatchConfig(
        batchSize: 10,
        memoryCleanupInterval: 2,
        showDetailedProgress: true
    )
}

/// Batch processor - manage data batches and memory
class BatchProcessor {
    
    private let config: BatchConfig
    private var processedCount: Int = 0
    
    init(config: BatchConfig = .default) {
        self.config = config
    }
    
    /// Calculate batch information
    func calculateBatches(totalSamples: Int) -> (numBatches: Int, lastBatchSize: Int) {
        let numBatches = (totalSamples + config.batchSize - 1) / config.batchSize
        let lastBatchSize = totalSamples % config.batchSize == 0 ? config.batchSize : totalSamples % config.batchSize
        return (numBatches, lastBatchSize)
    }
    
    /// Get batch range
    func getBatchRange(batchIndex: Int, totalSamples: Int) -> Range<Int> {
        let start = batchIndex * config.batchSize
        let end = min(start + config.batchSize, totalSamples)
        return start..<end
    }
    
    /// Check if memory cleanup is needed
    func shouldCleanupMemory(afterBatch batchIndex: Int) -> Bool {
        return (batchIndex + 1) % config.memoryCleanupInterval == 0
    }
    
    /// Execute memory cleanup
    func cleanupMemory() {
        autoreleasepool {
            // iOS autorelease pool cleanup
        }
        
        // Trigger garbage collection suggestion
        #if DEBUG
        print("🧹 Memory cleanup executed")
        #endif
    }
    
    /// Update progress
    func updateProgress(currentBatch: Int, totalBatches: Int, currentSample: Int, totalSamples: Int) -> String {
        let percentage = Double(currentSample) / Double(totalSamples) * 100.0
        return String(format: "Batch %d/%d (%.1f%% - %d/%d samples)", 
                     currentBatch, totalBatches, percentage, currentSample, totalSamples)
    }
    
    /// Generate batch processing report
    func generateReport(totalSamples: Int, totalTime: TimeInterval) -> String {
        let samplesPerSecond = Double(totalSamples) / totalTime
        return """
        📊 Batch Processing Report:
        - Total samples: \(totalSamples)
        - Batch size: \(config.batchSize)
        - Total time: \(String(format: "%.2f", totalTime))s
        - Speed: \(String(format: "%.2f", samplesPerSecond)) samples/sec
        - Memory cleanups: \(totalSamples / (config.batchSize * config.memoryCleanupInterval))
        """
    }
}

/// Memory monitor
class MemoryMonitor {
    
    /// Get current memory usage (MB)
    static func getCurrentMemoryUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Double(info.resident_size) / 1024.0 / 1024.0  // Convert to MB
        }
        return 0
    }
    
    /// Log memory usage
    static func logMemoryUsage(prefix: String = "") {
        let usage = getCurrentMemoryUsage()
        print("\(prefix)Memory usage: \(String(format: "%.2f", usage)) MB")
    }
    
    /// Check if close to memory limit
    static func isMemoryPressureHigh() -> Bool {
        let usage = getCurrentMemoryUsage()
        return usage > 800.0  // Over 800MB considered high pressure
    }
}

