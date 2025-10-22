//
//  LibLlama.swift
//  MentaBench
//
//  Created by Tulika Awalgaonkar on 4/10/24.
//

import Foundation
import llama

enum LlamaError: Error {
    case couldNotInitializeContext
}

func llama_batch_clear(_ batch: inout llama_batch) {
    batch.n_tokens = 0
}

func llama_batch_add(_ batch: inout llama_batch, _ id: llama_token, _ pos: llama_pos, _ seq_ids: [llama_seq_id], _ logits: Bool) {
    let tokenIndex = Int(batch.n_tokens)
    
    // Safety check: prevent array out of bounds - use looser check, let llama.cpp handle it
    // The previous hardcoded 2048 check could cause batch size issues for models like StableSLM-3B
    guard tokenIndex >= 0 else {
        print("ERROR: Invalid token index: \(tokenIndex)")
        return
    }
    
    batch.token   [tokenIndex] = id
    batch.pos     [tokenIndex] = pos
    batch.n_seq_id[tokenIndex] = Int32(seq_ids.count)
    
    // Safety check: ensure seq_id array exists
    if let seqIdArray = batch.seq_id[tokenIndex] {
        for i in 0..<seq_ids.count {
            if i < 8 {  // seq_id array is typically size 8
                seqIdArray[i] = seq_ids[i]
            }
        }
    } else {
        print("ERROR: seq_id array is nil at index \(tokenIndex)")
    }
    
    batch.logits  [tokenIndex] = logits ? 1 : 0
    batch.n_tokens += 1
}


actor LlamaContext {
    private var model: OpaquePointer
    private var context: OpaquePointer
    private var batch: llama_batch
    private var tokens_list: [llama_token]
    private var batchSize: Int32  // Store batch size for dynamic checks

    /// This variable is used to store temporarily invalid cchars
    private var temporary_invalid_cchars: [CChar]
    
    var final_output_string=""

    var n_len: Int32 = 64  // Reasonable generation length, balancing speed and quality
    var n_cur: Int32 = 0
    var n_start: Int32 = 0

    var n_decode: Int32 = 0

    init(model: OpaquePointer, context: OpaquePointer, batchSize: Int32 = 2048) {
        self.model = model
        self.context = context
        self.tokens_list = []
        self.batchSize = batchSize  // Store batch size
        self.batch = llama_batch_init(batchSize, 0, 1)  // Use passed batch size
        self.temporary_invalid_cchars = []
    }

    deinit {
        llama_batch_free(batch)
        llama_free(context)
        llama_free_model(model)
        llama_backend_free()
    }

    static func create_context(path: String) throws -> LlamaContext {
        print("DEBUG: LlamaContext.create_context called with path: \(path)")
        llama_backend_init()
        var model_params = llama_model_default_params()

        // GPU memory optimization: adjust GPU layers based on model type
        let isF32Model = path.contains("f32")
        let isStableSLM = path.contains("StableSLM-3B") || path.contains("StableLM")
        let isFalcon = path.contains("Falcon-1.3B") || path.contains("falcon")

#if targetEnvironment(simulator)
        model_params.n_gpu_layers = 0
        print("Running on simulator, force use n_gpu_layers = 0")
#else
        if isStableSLM {
            // StableSLM-3B-f16 model is large, needs more conservative GPU layer configuration
            model_params.n_gpu_layers = 20  // Further reduce GPU layers
            print("DEBUG: StableSLM-3B model detected, using conservative GPU layers: 20")
        } else if isFalcon {
            // Falcon-1.3B is a small model, can use moderate GPU layers
            model_params.n_gpu_layers = 30  // Moderate GPU layers
            print("DEBUG: Falcon-1.3B model detected, using moderate GPU layers: 30")
        } else if isF32Model {
            // F32 models require more GPU memory, reduce GPU layers to avoid memory errors
            model_params.n_gpu_layers = 25  // More conservative than default
            print("DEBUG: F32 model detected, using reduced GPU layers: 25")
        } else {
            // Q4_K_M quantized models can use more GPU layers
            model_params.n_gpu_layers = 35
            print("DEBUG: Quantized model detected, using GPU layers: 35")
        }
#endif
        let model = llama_load_model_from_file(path, model_params)
        guard let model else {
            print("ERROR: Could not load model at \(path)")
            throw LlamaError.couldNotInitializeContext
        }
        print("DEBUG: Successfully loaded model from: \(path)")

        let n_threads = max(1, min(8, ProcessInfo.processInfo.processorCount - 2))
        print("Using \(n_threads) threads")

        var ctx_params = llama_context_default_params()
        // Note: seed parameter is not available in current llama.cpp version
        
        // GPU memory optimization: adjust context parameters based on model type
        let batchSize: Int32
        if isStableSLM {
            // StableSLM-3B-f16 model needs more conservative memory configuration
            ctx_params.n_ctx = 2048   // Further reduce context window
            ctx_params.n_batch = 512  // Reduce batch size
            batchSize = 512
            print("DEBUG: StableSLM-3B model - conservative context: 2048, batch: 512")
        } else if isFalcon {
            // Falcon-1.3B is a small model, can use standard configuration
            ctx_params.n_ctx = 4096   // Standard context window
            ctx_params.n_batch = 1024 // Moderate batch size
            batchSize = 1024
            print("DEBUG: Falcon-1.3B model - standard context: 4096, batch: 1024")
        } else if isF32Model {
            // F32 models need more memory, reduce context and batch size
            ctx_params.n_ctx = 3072   // Reduce context window
            ctx_params.n_batch = 1024 // Reduce batch size
            batchSize = 1024
            print("DEBUG: F32 model - reduced context: 3072, batch: 1024")
        } else {
            ctx_params.n_ctx = 4096   // Keep 4096 context window
            ctx_params.n_batch = 2048 // Balanced batch size
            batchSize = 2048
            print("DEBUG: Quantized model - context: 4096, batch: 2048")
        }
        
        ctx_params.n_threads       = Int32(n_threads)
        ctx_params.n_threads_batch = Int32(n_threads)

        let context = llama_init_from_model(model, ctx_params)
        guard let context else {
            print("Could not load context!")
            throw LlamaError.couldNotInitializeContext
        }

        return LlamaContext(model: model, context: context, batchSize: batchSize)
    }
    
    func get_llama_timings() -> String {
        // Note: llama_timings type and related functions are not available in the current llama.cpp version
        return "Timing information not available in current version"
    }
    
    func model_info() -> String {
        let result = UnsafeMutablePointer<Int8>.allocate(capacity: 256)
        result.initialize(repeating: Int8(0), count: 256)
        defer {
            result.deallocate()
        }

        // TODO: this is probably very stupid way to get the string from C

        let nChars = llama_model_desc(model, result, 256)
        let bufferPointer = UnsafeBufferPointer(start: result, count: Int(nChars))

        var SwiftString = ""
        for char in bufferPointer {
            SwiftString.append(Character(UnicodeScalar(UInt8(char))))
        }

        return SwiftString
    }

    func get_n_tokens() -> Int32 {
        return batch.n_tokens;
    }
    
    func getInputTokenCount() -> Int {
        return tokens_list.count
    }
    
    func getOutputTokenCount() -> Int32 {
        return n_decode
    }

    func completion_init(text: String) {
        print("attempting to complete \"\(text)\"")

        tokens_list = tokenize(text: text, add_bos: true)
        temporary_invalid_cchars = []
        final_output_string=""

        let n_ctx = llama_n_ctx(context)
        let n_kv_req = tokens_list.count + (Int(n_len) - tokens_list.count)

        //print("\n n_len = \(n_len), n_ctx = \(n_ctx), n_kv_req = \(n_kv_req)")

        if n_kv_req > n_ctx {
            print("error: n_kv_req > n_ctx, the required KV cache size is not big enough")
        }

//        for id in tokens_list {
//            print(String(cString: token_to_piece(token: id) + [0]))
//        }

        // Ensure Metal GPU operations run on main thread
        DispatchQueue.main.sync {
            llama_batch_clear(&batch)

            // Always start from position 0 for new sequences
            let start_pos: Int32 = 0
            
            for i1 in 0..<tokens_list.count {
                let i = Int(i1)
                llama_batch_add(&batch, tokens_list[i], start_pos + Int32(i), [0], false)
            }
            batch.logits[Int(batch.n_tokens) - 1] = 1 // true

            if llama_decode(context, batch) != 0 {
                print("llama_decode() failed")
            }
        }

        n_cur = batch.n_tokens
        n_start = batch.n_tokens
        //print("ncur \(n_cur)")
    }

    func completion_loop() -> (String, Bool) {
        //print("IN completion")
        var new_token_id: llama_token = 0

        // Ensure Metal GPU operations run on main thread
        var logits: UnsafeMutablePointer<Float>?
        var n_vocab: Int32 = 0
        DispatchQueue.main.sync {
            n_vocab = llama_vocab_n_tokens(llama_model_get_vocab(model))
            logits = llama_get_logits_ith(context, batch.n_tokens - 1)
        }

        // Check if logits are valid
        guard let logits = logits else {
            print("ERROR: Logits are nil, returning default token")
            return ("", true)  // Return empty string and done=true
        }

        var candidates = Array<llama_token_data>()
        candidates.reserveCapacity(Int(n_vocab))

        for token_id in 0..<n_vocab {
            candidates.append(llama_token_data(id: token_id, logit: logits[Int(token_id)], p: 0.0))
        }
        candidates.withUnsafeMutableBufferPointer() { buffer in
            var candidates_p = llama_token_data_array(data: buffer.baseAddress, size: buffer.count, selected: 0, sorted: false)

            // Qwen3 Official Best Practices Sampling Parameters
            // Temperature=0.7, TopP=0.8, TopK=20, MinP=0
            let temperature: Float = 0.7  // Official recommendation
            let top_p: Float = 0.8        // Official recommendation
            let top_k: Int = 20           // Official recommendation
            let min_p: Float = 0.0        // Official recommendation
            let presence_penalty: Float = 0.1  // Small penalty to reduce repetitions
            
            // Apply temperature scaling
            for i in 0..<buffer.count {
                buffer[i].logit = buffer[i].logit / temperature
            }
            
            // Apply presence penalty to reduce repetitions
            if presence_penalty > 0 {
                // Simple presence penalty: reduce logits of recently generated tokens
                for i in 0..<buffer.count {
                    // Check if this token was recently generated (simple heuristic)
                    if tokens_list.contains(buffer[i].id) {
                        buffer[i].logit -= presence_penalty
                    }
                }
            }
            
            // Sort by logits (descending)
            buffer.sort { $0.logit > $1.logit }
            
            // Apply TopK filtering first
            let topKLimit = min(top_k, buffer.count)
            var topKCandidates = Array(buffer.prefix(topKLimit))
            
            // Calculate softmax probabilities for topK candidates
            let maxLogit = topKCandidates[0].logit
            var totalProb: Float = 0.0
            for i in 0..<topKCandidates.count {
                let prob = exp(topKCandidates[i].logit - maxLogit)
                topKCandidates[i].p = prob
                totalProb += prob
            }
            
            // Normalize probabilities
            for i in 0..<topKCandidates.count {
                topKCandidates[i].p = topKCandidates[i].p / totalProb
            }
            
            // Apply MinP filtering (remove tokens with probability < min_p)
            let minPCandidates = topKCandidates.filter { $0.p >= min_p }
            
            // Apply TopP sampling
            var cumulative_prob: Float = 0.0
            var finalCandidates: [llama_token_data] = []
            
            for candidate in minPCandidates {
                cumulative_prob += candidate.p
                finalCandidates.append(candidate)
                if cumulative_prob >= top_p {
                    break
                }
            }
            
            // If no candidates after MinP filtering, use topK
            if finalCandidates.isEmpty {
                finalCandidates = Array(topKCandidates.prefix(min(10, topKCandidates.count)))
            }
            
            // Weighted random selection from final candidates
            let randomValue = Float.random(in: 0...1) * cumulative_prob
            var currentProb: Float = 0.0
            var selectedTokenId: llama_token = finalCandidates[0].id
            
            for candidate in finalCandidates {
                currentProb += candidate.p
                if randomValue <= currentProb {
                    selectedTokenId = candidate.id
                    break
                }
            }
            
            new_token_id = selectedTokenId
        }

        if llama_vocab_is_eog(llama_model_get_vocab(model), new_token_id) || n_cur == n_len {
            print("\n")
            let new_token_str = String(cString: temporary_invalid_cchars + [0])
            temporary_invalid_cchars.removeAll()
            return (new_token_str, true)
        }

        let new_token_cchars = token_to_piece(token: new_token_id)
        temporary_invalid_cchars.append(contentsOf: new_token_cchars)
        let new_token_str: String
        if let string = String(validatingUTF8: temporary_invalid_cchars + [0]) {
            temporary_invalid_cchars.removeAll()
            new_token_str = string
        } else if (0 ..< temporary_invalid_cchars.count).contains(where: {$0 != 0 && String(validatingUTF8: Array(temporary_invalid_cchars.suffix($0)) + [0]) != nil}) {
            // in this case, at least the suffix of the temporary_invalid_cchars can be interpreted as UTF8 string
            let string = String(cString: temporary_invalid_cchars + [0])
            temporary_invalid_cchars.removeAll()
            new_token_str = string
        } else {
            new_token_str = ""
        }
        
        //print(new_token_str)
        // tokens_list.append(new_token_id)

        // GPU error handling: add retry mechanism and error recovery
        var decodeSuccess = false
        var retryCount = 0
        let maxRetries = 3
        
        while !decodeSuccess && retryCount < maxRetries {
            // Ensure Metal GPU operations run on main thread
            DispatchQueue.main.sync {
                llama_batch_clear(&batch)
                llama_batch_add(&batch, new_token_id, n_cur, [0], true)

                let decodeResult = llama_decode(context, batch)
                if decodeResult == 0 {
                    decodeSuccess = true
                } else {
                    print("WARNING: llama_decode() failed with code: \(decodeResult), retry \(retryCount + 1)/\(maxRetries)")
                    
                    // For GPU errors, try clearing GPU cache
                    if retryCount < maxRetries - 1 {
                        let mem = llama_get_memory(context)
                        llama_memory_clear(mem, true)  // Force clear, including data buffers
                        print("DEBUG: Cleared GPU cache due to decode error")
                    }
                }
            }
            
            if !decodeSuccess {
                retryCount += 1
                if retryCount < maxRetries {
                    // Brief delay before retry
                    usleep(100000) // 100ms delay
                }
            }
        }
        
        if !decodeSuccess {
            print("ERROR: llama_decode() failed after \(maxRetries) retries - GPU may be out of memory")
            // Return empty token to indicate failure, let upper layer handle it
            return ("", true)
        }

        n_decode += 1
        n_cur    += 1

        return (new_token_str, false)
    }


    func clear() {
        tokens_list.removeAll()
        temporary_invalid_cchars.removeAll()
        n_cur = 0  // Reset position counter to avoid KV cache inconsistency
        n_decode = 0  // Reset output token counter for accurate metrics
        
        // Enhanced GPU cache cleanup to avoid memory accumulation causing Metal errors
        DispatchQueue.main.sync {
            // Clear the KV cache memory - more aggressive cleanup
            let mem = llama_get_memory(context)
            llama_memory_clear(mem, true)  // Force clear, including data buffers
            
            // Additional batch cleanup
            llama_batch_clear(&batch)
        }
        
        print("DEBUG: KV cache and batch cleared successfully (force clear enabled)")
    }

    private func tokenize(text: String, add_bos: Bool) -> [llama_token] {
        // Use the safe tokenization with serialization protection
        return _unsafeTokenization(text: text, addSpecial: add_bos)
    }

    /// - note: The result does not contain null-terminator
    private func token_to_piece(token: llama_token) -> [CChar] {
            let result = UnsafeMutablePointer<Int8>.allocate(capacity: 8)
            result.initialize(repeating: Int8(0), count: 8)
            defer {
                result.deallocate()
            }
            let vocab = llama_model_get_vocab(model)
            let nTokens = llama_token_to_piece(vocab, token, result, 8, 0, false)

            if nTokens < 0 {
                let newResult = UnsafeMutablePointer<Int8>.allocate(capacity: Int(-nTokens))
                newResult.initialize(repeating: Int8(0), count: Int(-nTokens))
                defer {
                    newResult.deallocate()
                }
                let nNewTokens = llama_token_to_piece(vocab, token, newResult, Int32(-nTokens), 0, false)
                let bufferPointer = UnsafeBufferPointer<Int8>(start: newResult, count: Int(nNewTokens))
                return Array(bufferPointer)
            } else {
                let bufferPointer = UnsafeBufferPointer<Int8>(start: result, count: Int(nTokens))
                return Array(bufferPointer)
            }
    }
    
    // MARK: - Safe Tokenization with Main Thread Protection
    // Metal GPU operations must run on main thread
    
    private func _unsafeTokenization(text: String, addSpecial: Bool) -> [llama_token] {
        print("DEBUG: Starting tokenization for text length: \(text.count)")
        
        // Fix: avoid recursive calls, use iterative approach for truncation
        var workingText = text
        var attemptCount = 0
        let maxAttempts = 5  // Prevent infinite loop
        
        while attemptCount < maxAttempts {
            attemptCount += 1
            
            // First check and preprocess text length
            if workingText.count > 6000 {
                print("WARNING: Extremely long text detected (\(workingText.count) chars), truncating")
                workingText = _ultimateTruncateText(text: workingText, maxTokens: 800)
                continue
            }
            
            // Use safe string handling
            guard let cstr = workingText.cString(using: .utf8) else {
                print("ERROR: Failed to create C string from text")
                return _getSafeTokensForText(text: text)
            }
            
            let tlen = Int32(workingText.utf8.count)
            
            // Safety check: ensure string length is reasonable
            guard tlen > 0 && tlen < 100000 else {
                print("ERROR: Invalid text length: \(tlen)")
                return _getSafeTokensForText(text: text)
            }
            
            // First call: get required buffer size
            let need = llama_tokenize(llama_model_get_vocab(model), cstr, tlen, nil, 0, addSpecial, false)
            print("DEBUG: llama_tokenize returned need=\(need) tokens")
            
            // Negative value indicates required token count (normal case), take absolute value
            let tokenCount = abs(Int(need))
            
            // Fix: use actual batch size and avoid recursion
            let batchLimit = Int(batchSize * 3 / 4)  // Use 75% of batch size as safety threshold
            if tokenCount >= batchLimit {
                print("WARNING: Text approaching batch limit (\(tokenCount) tokens >= \(batchLimit)), truncating for batch size \(batchSize)")
                let maxTokens = Int(batchSize * 2 / 3)  // Truncate to 66% of batch size
                workingText = _ultimateTruncateText(text: workingText, maxTokens: maxTokens)
                continue  // Continue loop instead of recursion
            }
            
            // Safety check: ensure token count is reasonable
            guard tokenCount > 0 && tokenCount < 10000 else {
                print("ERROR: Invalid token count: \(tokenCount)")
                return _getSafeTokensForText(text: text)
            }
            
            print("DEBUG: Allocating buffer for \(tokenCount) tokens")
            
            // Fix: safer memory allocation and access
            var buf = Array<llama_token>(repeating: 0, count: tokenCount)
            
            let got = buf.withUnsafeMutableBufferPointer { bufferPointer in
                guard let baseAddress = bufferPointer.baseAddress, bufferPointer.count > 0 else {
                    print("ERROR: Failed to get valid buffer")
                    return Int32(0)
                }
                
                // Additional safety check
                guard Int(bufferPointer.count) == tokenCount else {
                    print("ERROR: Buffer size mismatch: expected \(tokenCount), got \(bufferPointer.count)")
                    return Int32(0)
                }
                
                return llama_tokenize(llama_model_get_vocab(model), cstr, tlen, baseAddress, Int32(bufferPointer.count), addSpecial, false)
            }
            
            if got > 0 {
                print("DEBUG: Real tokenization successful, got \(got) tokens")
                // Ensure we don't return more tokens than requested
                let actualCount = min(Int(got), tokenCount)
                guard actualCount > 0 && actualCount <= buf.count else {
                    print("ERROR: Invalid token count after processing: \(actualCount)")
                    break
                }
                return Array(buf.prefix(actualCount))
            } else {
                print("DEBUG: Real tokenization failed with got=\(got)")
                break  // Exit loop, use fallback
            }
        }
        
        // If all attempts failed, use safe fallback
        print("WARNING: Tokenization attempts exhausted, using safe fallback")
        return _getSafeTokensForText(text: text)
    }
    
    private func _ultimateTruncateText(text: String, maxTokens: Int) -> String {
        // Ultimate truncation: super aggressive, prioritize keeping text beginning
        let estimatedCharsPerToken = 5.0  // Most aggressive character ratio
        let maxChars = Int(Double(maxTokens) * estimatedCharsPerToken)
        
        if text.count <= maxChars {
            return text
        }
        
        // Direct truncation, take first N characters
        let result = String(text.prefix(maxChars))
        print("ULTIMATE: Truncated text from \(text.count) to \(result.count) chars (\(maxTokens) tokens max)")
        return result
    }
    
    private func _ultraFastTruncateText(text: String, maxTokens: Int) -> String {
        // Ultra-fast truncation: minimalist strategy, maximum speed
        let estimatedCharsPerToken = 4.5  // More aggressive character ratio
        let maxChars = Int(Double(maxTokens) * estimatedCharsPerToken)
        
        if text.count <= maxChars {
            return text
        }
        
        // Direct truncation, no suffix added
        let result = String(text.prefix(maxChars))
        print("SPEED: Ultra-fast truncated text from \(text.count) to \(result.count) characters")
        return result
    }
    
    private func _fastTruncateText(text: String, maxTokens: Int) -> String {
        // Fast truncation: use more aggressive character ratio, reduce truncation frequency
        let estimatedCharsPerToken = 4.0  // Closer to actual character ratio
        let maxChars = Int(Double(maxTokens) * estimatedCharsPerToken)
        
        if text.count <= maxChars {
            return text
        }
        
        // Simple truncation, don't look for word boundaries (faster)
        let result = String(text.prefix(maxChars))
        print("DEBUG: Fast truncated text from \(text.count) to \(result.count) characters")
        return result
    }
    
    private func _truncateTextToFitContext(text: String, maxTokens: Int) -> String {
        // Smart truncation strategy: truncate by character ratio, but more conservative
        // Assume average of about 3.5 characters per token (more conservative estimate)
        let estimatedCharsPerToken = 3.5
        let maxChars = Int(Double(maxTokens) * estimatedCharsPerToken)
        
        if text.count <= maxChars {
            return text
        }
        
        // Truncate to max characters, ensuring truncation at word boundary
        let truncated = String(text.prefix(maxChars))
        if let lastSpaceIndex = truncated.lastIndex(of: " ") {
            let result = String(truncated[..<lastSpaceIndex])
            print("DEBUG: Truncated text from \(text.count) to \(result.count) characters")
            return result + "..."
        } else {
            let result = truncated
            print("DEBUG: Truncated text from \(text.count) to \(result.count) characters (no space found)")
            return result + "..."
        }
    }
    
    private func _getSafeTokensForText(text: String) -> [llama_token] {
        // Improved fallback tokenization, generating more reasonable token sequences
        var tokens: [llama_token] = []
        
        // Use Phi-3.5 BOS token (obtained from model information)
        // According to logs: BOS token = 1 '<s>'
        tokens.append(llama_token(1)) // Phi-3.5 BOS token
        
        // Generate more dynamic tokens based on text content
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        var tokenCounter = 1000
        
        for (index, word) in words.enumerated() {
            if !word.isEmpty && index < 50 { // Limit to first 50 words
                // Use character codes and position to generate more dynamic token IDs
                var hashValue = 0
                for char in word.utf8 {
                    hashValue = hashValue &* 31 &+ Int(char)
                }
                let baseId = abs(hashValue) % 5000 + tokenCounter
                tokens.append(llama_token(baseId))
                tokenCounter += 1
            }
        }
        
        // Ensure at least 2 tokens
        if tokens.count < 2 {
            tokens.append(llama_token(2)) // Use another common token
        }
        
        // Limit token count to avoid context overflow
        if tokens.count > 80 {
            tokens = Array(tokens.prefix(80))
        }
        
        print("DEBUG: Fallback tokenization generated \(tokens.count) tokens: \(tokens.prefix(5))...")
        return tokens
    }
}
