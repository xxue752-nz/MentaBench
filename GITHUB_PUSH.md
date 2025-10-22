# 推送到 GitHub 的步骤

## ✅ 已完成的设置

1. ✅ Git 仓库已初始化
2. ✅ llama.cpp 已设置为 Git Submodule
3. ✅ .gitignore 已配置，排除大文件
4. ✅ 初始提交已完成

## 📊 仓库大小分析

- **项目总大小**: 305MB
- **Git 仓库**: 199MB
- **主要内容**: 
  - 源代码和项目文件: ~2MB
  - llamacpp-framework submodule: ~99MB (只作为引用推送)
  - 数据集: ~4MB
  - 资源文件: ~2MB

**推送到 GitHub 时的实际大小**: 约 8-10MB
- Submodule 只存储引用，不存储实际内容
- GitHub 会显示指向 llama.cpp 官方仓库的链接

## 🚀 推送步骤

### 1. 在 GitHub 上创建新仓库

访问 https://github.com/new 创建仓库：
- Repository name: `MentaBench`
- Description: "Mental health AI model evaluation on iOS using llama.cpp"
- **不要**勾选 "Initialize this repository with a README"
- Public 或 Private（根据需要）

### 2. 连接远程仓库并推送

```bash
cd /Users/ericx/Desktop/MentaBench

# 添加远程仓库（替换 YOUR_USERNAME）
git remote add origin https://github.com/YOUR_USERNAME/MentaBench.git

# 推送主分支
git branch -M main
git push -u origin main
```

### 3. 验证推送成功

访问你的 GitHub 仓库，你应该看到：
- ✅ 所有源代码文件
- ✅ `llamacpp-framework` 显示为子模块（带有 @ commit hash）
- ✅ README.md 和 SETUP.md
- ✅ 数据集文件
- ❌ 没有 .gguf 模型文件（被 .gitignore 排除）
- ❌ 没有编译产物（build-* 目录）

## 📦 被排除的大文件

以下文件/目录**不会**被推送到 GitHub：

### 模型文件（~7GB+）
- `MentaBench/Menta.gguf`
- `MentaBench/Phi-4-mini-instruct-Q4_K_M.gguf`
- `MentaBench/qwen3-4b_Q4_K_M.gguf`

### 编译产物
- `llamacpp-framework/build-*/`
- `MentaBench/llamacpp_framework.xcframework/`

### 训练数据和检查点（~15GB+）
- `Menta（trained-qwen3-4b-instruct-2507）/` 整个目录

## 💡 模型文件托管建议

由于模型文件太大，建议使用以下平台托管：

### 1. Hugging Face（推荐）
```bash
# 安装 Hugging Face CLI
pip install huggingface_hub

# 上传模型
huggingface-cli upload YOUR_USERNAME/mentabench-models Menta.gguf
```

### 2. Google Drive
- 上传到 Google Drive
- 获取共享链接
- 在 README 中更新下载链接

### 3. GitHub Releases
- 虽然有 2GB 单文件限制，但可以拆分上传
- 不推荐，因为会占用仓库流量

### 4. Git LFS（GitHub 有限额）
- GitHub 免费账户: 1GB 存储 + 1GB/月带宽
- 需要付费扩容
- 不推荐用于这么大的模型

## 🔄 其他用户克隆项目

当其他用户克隆你的仓库时：

```bash
# 克隆包含 submodule
git clone --recursive https://github.com/YOUR_USERNAME/MentaBench.git
cd MentaBench

# 构建 llama.cpp framework
cd llamacpp-framework
./build-xcframework.sh
cd ..

# 下载模型文件（从你提供的链接）
# 将 .gguf 文件放入 MentaBench/ 目录

# 在 Xcode 中打开并运行
open MentaBench.xcodeproj
```

## ✅ 最佳实践检查清单

- [x] Git 仓库已初始化
- [x] Submodule 已正确设置
- [x] .gitignore 排除大文件
- [x] README 包含安装说明
- [x] SETUP.md 提供详细步骤
- [ ] 在 GitHub 创建仓库
- [ ] 推送代码
- [ ] 上传模型到外部托管服务
- [ ] 在 README 中更新模型下载链接
- [ ] 测试克隆和构建流程

## 🆘 常见问题

### Q: 推送时出现 "file too large" 错误？
A: 检查 .gitignore 是否正确配置。运行 `git status` 确认没有大文件被暂存。

### Q: Submodule 没有正确显示？
A: 确保 `.gitmodules` 文件已提交。运行：
```bash
git add .gitmodules
git commit -m "Update submodule configuration"
```

### Q: 如何更新 llama.cpp submodule？
A: 
```bash
cd llamacpp-framework
git pull origin master
cd ..
git add llamacpp-framework
git commit -m "Update llama.cpp submodule"
git push
```

---

**准备好推送了吗？** 按照上面的步骤 2 执行命令即可！

