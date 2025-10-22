# MentaBench - Mental Health AI Model Evaluation on iOS

MentaBench is an iOS benchmarking application for evaluating mental health classification models on mobile devices. The project benchmarks **Menta**, our custom-trained mental health model based on Qwen3-4B (fine-tuned via LoRA), against baseline models including Microsoft's Phi-4-mini (3.8B) and Alibaba's Qwen3-4B-Instruct-2507. The benchmark evaluates model performance across 6 mental health classification tasks: stress detection, depression detection and severity classification, suicide ideation detection, suicide risk assessment, and multi-level risk severity classification. All inference runs entirely on-device using llama.cpp with Metal GPU acceleration, providing comprehensive metrics including accuracy, latency (TTFT), throughput (ITPS/OTPS), memory usage, and CPU utilization. This platform enables direct comparison between specialized fine-tuned models and general-purpose language models for mental health applications.

## Features

- **On-Device AI Inference**: Run state-of-the-art language models entirely on your iOS device
- **Multiple Task Support**: Evaluate models across 6 different mental health classification tasks
- **Model Comparison**: Compare performance across multiple models including:
  - Menta (Fine-tuned mental health model)
  - Phi-4-mini
  - Qwen3-4B-Instruct
  - StableSLM-3B
  - Falcon-1.3B
- **Performance Metrics**: Comprehensive metrics including:
  - Accuracy
  - Time-to-First-Token (TTFT)
  - Input/Output Tokens Per Second (ITPS/OTPS)
  - Output Evaluation Time (OET)
  - Memory Usage
  - CPU Usage
- **Batch Processing**: Efficient batch processing with automatic memory management
- **Real-time Monitoring**: Track evaluation progress in real-time

## Mental Health Classification Tasks

The app evaluates models on 6 key mental health classification tasks:

### 1. Stress Detection (Binary)
- **Dataset**: Dreaddit Stress Analysis
- **Classes**: Stressed (1) vs. Not Stressed (0)
- **Description**: Identifies stress indicators in social media posts

### 2. Depression Detection (Binary)
- **Dataset**: Reddit Depression Dataset
- **Classes**: Depressed (1) vs. Not Depressed (0)
- **Description**: Detects presence of depression symptoms

### 3. Depression Severity (4-Level)
- **Dataset**: Reddit Depression Dataset
- **Classes**: Minimal (0), Mild (1), Moderate (2), Severe (3)
- **Description**: Classifies depression severity levels

### 4. Suicide Ideation (Binary)
- **Dataset**: SDCNL
- **Classes**: Ideation Present (1) vs. Not Present (0)
- **Description**: Identifies suicidal thoughts and ideation

### 5. Suicide Risk (Binary)
- **Dataset**: Reddit User Posts
- **Classes**: High Risk (1) vs. Low Risk (0)
- **Description**: Assesses overall suicide risk level

### 6. Suicide Risk Severity (5-Level)
- **Dataset**: Reddit User Posts
- **Classes**: Supportive (1), Indicator (2), Ideation (3), Behavior (4), Attempt (5)
- **Description**: Classifies suicide risk into detailed severity levels

## Models

### Menta (Primary Benchmark Model)
**Our custom-trained mental health model** - A specialized model fine-tuned for mental health classification tasks.

- **Base Model**: Qwen3-4B
- **Parameters**: ~4B
- **Training**: LoRA fine-tuning on mental health datasets
- **Specialty**: Optimized for the 6 mental health classification tasks in this benchmark
- **Format**: F32 (Full precision, 2.3GB)
- **File**: `Menta.gguf`
- **Description**: This is the primary model developed and trained specifically for mental health text classification. It has been fine-tuned to understand nuanced mental health language patterns including stress indicators, depression symptoms, and suicide risk factors across various severity levels.

### Phi-4-mini (Baseline Comparison)
**Microsoft's efficient reasoning model** - A compact yet powerful language model.

- **Developer**: Microsoft Research
- **Parameters**: 3.8B
- **Architecture**: Transformer-based decoder
- **Specialty**: Strong reasoning capabilities and instruction following
- **Format**: Q4_K_M quantization (2.3GB)
- **File**: `Phi-4-mini-instruct-Q4_K_M.gguf`
- **Description**: The Phi-4-mini is Microsoft's latest compact language model designed for efficient deployment on edge devices. Despite its smaller size, it demonstrates impressive reasoning abilities and serves as an excellent baseline for comparing against specialized models.

### Qwen3-4B-Instruct (Baseline Comparison)
**Alibaba's multilingual instruction model** - Version 2507 (July 2025 release).

- **Developer**: Alibaba Cloud (Qwen Team)
- **Parameters**: 4B
- **Version**: Qwen3-4B-Instruct-2507
- **Specialty**: Excellent instruction following, multilingual support, and general reasoning
- **Format**: Q4_K_M quantization (2.3GB)
- **File**: `qwen3-4b_Q4_K_M.gguf`
- **Description**: Qwen3-4B-Instruct is the base model for our Menta fine-tune. This instruction-tuned version provides strong baseline performance across diverse tasks. The 2507 version includes improvements in instruction following and contextual understanding.


---

### Model Comparison Summary

| Model | Parameters | Specialty | Format | Size | Purpose |
|-------|-----------|-----------|---------|------|---------|
| **Menta** | 4B | Mental Health Fine-tuned | F32 | 2.3GB | Primary evaluation target |
| **Phi-4-mini** | 3.8B | General reasoning | Q4_K_M | 2.3GB | General-purpose baseline |
| **Qwen3-4B-Instruct** | 4B | Instruction following | Q4_K_M | 2.3GB | Base model baseline |
| StableSLM-3B | 3B | Efficient inference | F16 | 5.2GB | Additional comparison |
| Falcon-1.3B | 1.3B | Edge deployment | Q8_0 | Variable | Additional comparison |

## Requirements

- iOS 16.0 or later
- Xcode 15.0 or later
- iPhone with Apple Silicon (A14 Bionic or later recommended)
- At least 4GB of available storage for model files
- Minimum 4GB RAM recommended

## Installation

### 1. Clone the repository with submodules:
```bash
# Clone with submodules (includes llama.cpp framework)
git clone --recursive https://github.com/yourusername/MentaBench.git
cd MentaBench

# Or if you already cloned without --recursive:
git submodule update --init --recursive
```

### 2. Build llama.cpp framework:
```bash
cd llamacpp-framework
./build-xcframework.sh
cd ..
```

This will generate the `llamacpp_framework.xcframework` needed for the project.

### 3. Download model files:

Due to file size limitations, model files are not included in the repository. Download them separately:

**Required Models:**
- **Menta.gguf** (~2.3GB) - [Download Link](https://your-hosting-service/Menta.gguf)
- **Phi-4-mini-instruct-Q4_K_M.gguf** (~2.3GB) - [Download from Hugging Face](https://huggingface.co/microsoft/phi-4-mini)
- **qwen3-4b_Q4_K_M.gguf** (~2.3GB) - [Download from Hugging Face](https://huggingface.co/Qwen/Qwen3-4B-Instruct)

Place downloaded `.gguf` files in the `MentaBench/` directory.

### 4. Open and build the project:
```bash
open MentaBench.xcodeproj
```

- Select your target device (iOS 16.0+)
- Press Cmd+R to build and run

## Usage

1. **Launch the App**: Open MentaBench on your iOS device

2. **Select Model**: Choose an AI model from the dropdown menu

3. **Choose Task**: Select one of the 6 mental health classification tasks

4. **Set Sample Count**: Choose how many samples to evaluate (10, 50, 100, 500, 1000, 2000, 3000)

5. **Start Evaluation**: Tap "Start Evaluation" to begin the benchmark

6. **View Results**: Monitor real-time progress and view comprehensive metrics upon completion

## Project Structure

```
MentaBench/
├── MentaBench/
│   ├── MentalHealthAIApp.swift    # App entry point
│   ├── ContentView.swift          # Main UI
│   ├── LlamaState.swift           # Model state management and evaluation logic
│   ├── LibLlama.swift             # llama.cpp Swift wrapper
│   ├── Tasks.swift                # Task definitions and configurations
│   ├── PromptGenerator.swift     # Prompt template generation
│   ├── PredictionParser.swift    # Intelligent response parsing
│   ├── BatchProcessor.swift      # Batch processing and memory management
│   ├── DatasetLoader.swift       # Dataset loading utilities
│   └── utils.swift                # Helper utilities
├── llamacpp-framework/            # llama.cpp submodule (Git Submodule)
├── datasets/                      # Mental health datasets
└── SETUP.md                       # Detailed setup instructions
```

## Performance Metrics

The app provides detailed performance metrics for each evaluation:

- **Accuracy**: Percentage of correct predictions
- **TTFT** (Time-to-First-Token): Latency before first token generation
- **ITPS** (Input Tokens Per Second): Input processing speed
- **OTPS** (Output Tokens Per Second): Generation speed
- **OET** (Output Evaluation Time): Average time per sample
- **Memory Usage**: RAM consumption (total and model-specific)
- **CPU Usage**: Processor utilization during inference
- **OOM Statistics**: Out-of-memory error tracking

## Technical Details

### Optimization Techniques

- **GPU Acceleration**: Leverages Metal GPU for accelerated inference
- **Batch Processing**: Processes samples in configurable batches
- **Memory Management**: Automatic memory cleanup to prevent OOM errors
- **Context Window Optimization**: Adaptive context sizing based on model type
- **Token Sampling**: Optimized sampling with temperature, top-p, and top-k

### Prompt Engineering

The app uses carefully crafted prompts for each task:
- Detailed task-specific instructions
- Clear classification criteria with examples
- Consistent formatting across all tasks
- Model-specific prompt templates (Qwen3 vs. Phi-4 formats)

## Dataset Information

All datasets are included in the app bundle:

- **Dreaddit**: Stress analysis from Reddit posts
- **Reddit Depression**: Depression classification dataset
- **SDCNL**: Suicide ideation detection
- **Reddit User Posts**: Multi-level suicide risk assessment

## Citation

If you use this work in your research, please cite:

```bibtex
@software{mentabench2025,
  title={MentaBench: Mental Health AI Model Evaluation on iOS},
  author={Your Name},
  year={2025},
  url={https://github.com/yourusername/MentaBench}
}
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Built on [llama.cpp](https://github.com/ggerganov/llama.cpp) for efficient LLM inference
- Uses models from Alibaba (Qwen), Microsoft (Phi), Stability AI, and TII (Falcon)
- Mental health datasets from various research projects

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for:
- Bug fixes
- New features
- Additional models
- Performance improvements
- Documentation enhancements

## Disclaimer

This application is for research and benchmarking purposes only. It should not be used as a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of qualified health providers with any questions regarding mental health conditions.

## Contact

For questions or feedback, please open an issue on GitHub or contact [your email].

---

**Note**: This is a research project focused on evaluating AI model performance for mental health tasks on mobile devices. The models and evaluations are intended for academic and research purposes.

