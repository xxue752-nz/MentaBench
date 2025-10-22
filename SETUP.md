# MentaBench Setup Guide

## Git Submodule 设置步骤

### 1. 初始化 Git 仓库

```bash
cd /Users/ericx/Desktop/MentaBench
git init
```

### 2. 备份并删除 llamacpp-framework 目录

```bash
# 如果需要，先备份（可选）
# cp -r llamacpp-framework ../llamacpp-framework-backup

# 删除现有的 llamacpp-framework
rm -rf llamacpp-framework
```

### 3. 添加 llama.cpp 作为 submodule

```bash
# 添加官方 llama.cpp 仓库作为 submodule
git submodule add https://github.com/ggerganov/llama.cpp.git llamacpp-framework
```

### 4. 初始化并更新 submodule

```bash
git submodule update --init --recursive
```

### 5. 首次提交

```bash
git add .
git commit -m "Initial commit with llama.cpp as submodule"
```

### 6. 连接到 GitHub 仓库

```bash
# 创建 GitHub 仓库后，添加远程仓库
git remote add origin https://github.com/YOUR_USERNAME/MentaBench.git
git branch -M main
git push -u origin main
```

---

## 构建 llama.cpp Framework

在克隆项目后，需要构建 llama.cpp framework：

```bash
cd llamacpp-framework
./build-xcframework.sh
```

这会生成所需的 `llamacpp_framework.xcframework` 文件。

---

## 克隆项目（其他用户）

其他用户克隆项目时需要包含 submodule：

```bash
# 克隆时包含 submodule
git clone --recursive https://github.com/YOUR_USERNAME/MentaBench.git

# 或者先克隆再初始化 submodule
git clone https://github.com/YOUR_USERNAME/MentaBench.git
cd MentaBench
git submodule update --init --recursive
```

---

## 模型文件

由于模型文件过大，需要单独下载：

1. **Menta 微调模型**: [下载链接]
2. **Qwen3-4B 量化模型**: [下载链接]
3. **Phi-4-mini 量化模型**: [下载链接]

下载后将 `.gguf` 文件放入 `MentaBench/` 目录。

---

## 故障排除

### Submodule 更新问题

```bash
# 更新 submodule 到最新版本
git submodule update --remote llamacpp-framework

# 重置 submodule
git submodule deinit -f llamacpp-framework
git submodule update --init
```

### Framework 构建失败

确保已安装 Xcode Command Line Tools：
```bash
xcode-select --install
```

