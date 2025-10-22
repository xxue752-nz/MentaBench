# MentaBench - Requirements and Dependencies

This document outlines the system requirements, dependencies, and prerequisites for building and running MentaBench.

## System Requirements

### Hardware Requirements

#### Minimum Requirements
- **Device**: iPhone with A14 Bionic chip or later
- **RAM**: 4GB minimum
- **Storage**: 15GB free space (13GB for models + 2GB for app and datasets)
- **Display**: Any iPhone screen size

#### Recommended Requirements
- **Device**: iPhone 13 Pro or later (A15 Bionic or newer)
- **RAM**: 6GB or more
- **Storage**: 20GB free space
- **Display**: iPhone with 6.1" or larger screen for better viewing

### Software Requirements

#### Development Environment
- **macOS**: 13.0 (Ventura) or later
- **Xcode**: 15.0 or later
- **iOS SDK**: iOS 16.0 SDK or later
- **Command Line Tools**: Xcode Command Line Tools installed

#### Target Platform
- **iOS Version**: 16.0 or later
- **Architecture**: arm64 (Apple Silicon)
- **Deployment Target**: iPhone only (iPad not tested)

## Dependencies

### Frameworks and Libraries

#### Native iOS Frameworks
```
Foundation.framework
SwiftUI.framework
SwiftData.framework
Metal.framework (for GPU acceleration)
CoreML.framework
```

#### Third-Party Dependencies

##### 1. llama.cpp Framework
- **Version**: Latest (included as xcframework)
- **Purpose**: LLM inference engine
- **Location**: `llamacpp_framework.xcframework/`
- **License**: MIT License
- **Features Used**:
  - Metal GPU acceleration
  - GGUF model format support
  - Batched inference
  - KV cache management

##### 2. Bundled Components
All dependencies are bundled with the project:
- llama.cpp framework (pre-built xcframework)
- No CocoaPods required
- No Swift Package Manager dependencies
- No Carthage dependencies

## Model Files

### Required Model Files (GGUF format)

All model files should be placed in the `MentaBench/` directory:

#### 1. Menta (Primary Model - Custom-Trained)
```
File: Menta.gguf
Size: ~2.3GB
Format: F32 (Full precision)
Parameters: ~4B
Base Model: Qwen3-4B
Training: LoRA fine-tuning on mental health datasets
Required: Yes (default model)
```
**Description**: Our custom-trained model specifically fine-tuned for mental health classification tasks. This is the primary evaluation target of this benchmark, optimized to understand stress indicators, depression symptoms, and suicide risk factors.

#### 2. Phi-4-mini (Baseline - Microsoft)
```
File: Phi-4-mini-instruct-Q4_K_M.gguf
Size: ~2.3GB
Format: Q4_K_M (Quantized)
Parameters: 3.8B
Developer: Microsoft Research
Required: Optional (recommended for baseline comparison)
```
**Description**: Microsoft's compact language model with strong reasoning capabilities. Serves as a general-purpose baseline to evaluate how specialized fine-tuning (Menta) compares against a capable general model.

#### 3. Qwen3-4B-Instruct-2507 (Baseline - Alibaba)
```
File: qwen3-4b_Q4_K_M.gguf
Size: ~2.3GB
Format: Q4_K_M (Quantized)
Parameters: 4B
Version: 2507 (July 2025)
Developer: Alibaba Cloud (Qwen Team)
Required: Optional (recommended for baseline comparison)
```
**Description**: The base model used for Menta fine-tuning. This instruction-tuned model provides a baseline to measure the impact of mental health-specific fine-tuning.

#### 4. StableSLM-3B
```
File: StableSLM-3B-f16.gguf
Size: ~5.2GB
Format: F16 (Half precision)
Required: Optional
Source: Stability AI
```

#### 5. Falcon-1.3B
```
File: Falcon-1.3B-q8_0.gguf
Size: ~169MB
Format: Q8_0 (Quantized)
Required: Optional
Source: TII UAE
```

### Model Conversion
If you need to convert models to GGUF format:
```bash
# Using llama.cpp convert script
python3 llamacpp-framework/convert_hf_to_gguf.py \
    --outfile model.gguf \
    --outtype f16 \
    model_directory/
```

## Dataset Files

### Required Datasets

All datasets should be in `MentaBench/datasets/dataset/`:

#### 1. Dreaddit Stress Analysis
```
File: dreaddit_StressAnalysis - Sheet1.csv
Columns: text, label
Samples: ~3,000
Task: Stress Detection (Binary)
```

#### 2. Reddit Depression Dataset
```
File: Reddit_depression_dataset.csv
Columns: text, label
Samples: ~7,500
Tasks: 
  - Depression Detection (Binary)
  - Depression Severity (4-level)
```

#### 3. SDCNL (Suicide Detection)
```
File: SDCNL.csv
Columns: title, selftext, is_suicide
Samples: ~500
Task: Suicide Ideation Detection (Binary)
```

#### 4. Reddit User Posts
```
File: 500_Reddit_user_posts_labels.csv
Columns: Post, Label
Samples: 500
Tasks:
  - Suicide Risk (Binary)
  - Suicide Risk Severity (5-level)
```

## Build Requirements

### Xcode Configuration

#### Project Settings
```
Bundle Identifier: com.yourcompany.MentaBench
Deployment Target: iOS 16.0
Swift Version: 5.9 or later
Optimization Level: -O (Release), -Onone (Debug)
```

#### Build Settings
```
ENABLE_BITCODE: NO
METAL_ENABLE_DEBUG_INFO: YES (Debug)
SWIFT_OPTIMIZATION_LEVEL: -O (Release)
GCC_OPTIMIZATION_LEVEL: 3 (Release)
```

#### Code Signing
- Development: Automatic signing
- Distribution: Manual signing with provisioning profile

### Memory Configuration

#### App Memory Limits
```
GPU Memory: Up to 3GB (adaptive per model)
CPU Memory: 2-4GB working set
KV Cache: 512MB - 2GB (adaptive)
Batch Size: 512 - 2048 tokens (adaptive)
```

## Development Tools

### Recommended Tools
- **Git**: Version control (2.30+)
- **Git LFS**: For large model files (optional)
- **Python 3.8+**: For model conversion scripts (optional)
- **Terminal**: For command-line operations

### Optional Tools
- **Instruments**: Performance profiling
- **Console.app**: Log viewing
- **Activity Monitor**: Memory tracking

## Performance Requirements

### Inference Performance
- **Time-to-First-Token (TTFT)**: < 2 seconds
- **Output Token Speed (OTPS)**: 5-15 tokens/sec (varies by model)
- **Input Processing (ITPS)**: 50-200 tokens/sec
- **Memory Usage**: < 4GB RAM (with cleanup)

### Battery Requirements
- **Evaluation Session**: ~5-10% battery per 100 samples
- **Recommended**: Keep device plugged in for long evaluations
- **Thermal**: Device may warm up during extended use

## Network Requirements

### Initial Setup
- **Internet**: Required for initial model download (if not bundled)
- **Size**: 13GB+ total download for all models

### Runtime
- **Internet**: Not required (all inference is on-device)
- **Privacy**: No data sent to external servers

## Installation Steps

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/MentaBench.git
cd MentaBench
```

### 2. Verify Model Files
```bash
ls -lh MentaBench/*.gguf
# Should show 5 model files
```

### 3. Verify Dataset Files
```bash
ls -lh MentaBench/datasets/dataset/*.csv
# Should show 4 CSV files
```

### 4. Open in Xcode
```bash
open MentaBench.xcodeproj
```

### 5. Configure Signing
- Select your development team in Xcode
- Update bundle identifier if needed

### 6. Build and Run
- Select target device (iPhone)
- Press Cmd+R to build and run

## Troubleshooting

### Common Issues

#### 1. Model Not Found
**Error**: "Model file not found"
**Solution**: Ensure .gguf files are added to Xcode project target

#### 2. Out of Memory
**Error**: App crashes during inference
**Solution**: 
- Close other apps
- Reduce batch size in code
- Use smaller models (Falcon-1.3B)

#### 3. Slow Performance
**Issue**: Low tokens/second
**Solution**:
- Enable Metal GPU acceleration
- Check device thermal state
- Ensure Release build configuration

#### 4. Dataset Not Loading
**Error**: "Dataset file not found"
**Solution**: Verify CSV files are in correct directory and added to Xcode target

## Testing Requirements

### Unit Testing
- Swift Testing framework (built-in)
- Coverage target: Core logic functions

### Device Testing
- Test on physical device (required)
- Simulator not recommended (no Metal support)

### Compatibility Testing
Tested on:
- iPhone 13 Pro (iOS 16.0+)
- iPhone 14 Pro (iOS 17.0+)
- iPhone 15 Pro (iOS 17.0+)

## License Requirements

### Project License
- MIT License (see LICENSE file)

### Dependencies Licenses
- llama.cpp: MIT License
- Mental health datasets: Research use only

### Model Licenses
- Menta: Research use
- Phi-4-mini: Microsoft Research License
- Qwen3: Apache 2.0
- StableSLM: Apache 2.0
- Falcon: Apache 2.0

## Compliance Requirements

### Data Privacy
- All inference is on-device
- No data sent to external servers
- HIPAA/GDPR: User responsible for compliance in production use

### Medical Disclaimer
- Research purposes only
- Not FDA approved
- Not for clinical diagnosis
- See DISCLAIMER in README

## Version History

### Current Version: 1.0.0
- Initial release
- 6 mental health classification tasks
- 5 model support
- Comprehensive metrics tracking

## Support and Contact

For requirements-related questions:
- Open an issue on GitHub
- Check documentation in `/docs`
- Contact: [your email]

---

**Last Updated**: 2025-01-22
**Document Version**: 1.0

