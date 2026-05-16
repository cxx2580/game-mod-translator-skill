# Skill Creation Log: game-mod-translator

> 从零开始创建一个可复用的 Claude Code 技能，并发布到 GitHub 的完整记录。

## 需求分析

在成功汉化 R.E.P.O. Spawn Manager 模组后，发现这个流程有通用价值：

- 不限于特定游戏，Unity/Unreal/RPG Maker 等引擎的模组都需要翻译
- 核心流程固定：提取字符串 → 发现框架 → 生成翻译 → 检查字体
- 需要防呆设计：新手容易被"反编译 DLL"的思路误导

决定把这个流程封装为一个 **Claude Code Skill**，让任何人用它来翻译任意游戏的模组。

## 设计参考

分析了两类 Claude Code 技能的结构：

### 参考来源

| 技能 | 来源 | 特点 |
|------|------|------|
| drawio-skill | Agents365-ai | 完整工作流 + references/ + scripts/ + 防跳过 + 自检循环 |
| caveman | 独立 | 极简单文件 SKILL.md |
| garden-skills | ConardLi | 多技能包，manifest.json 严格校验 |
| agent-skills | addyosmani | 22 技能包，YAML frontmatter 规范 |

### 选定结构

采用 drawio-skill 的完整格式：

```
skills/game-mod-translator/
├── SKILL.md              # 主工作流（5 步 + 防跳过 + 质量规范）
├── SKILL_EN.md           # 英文版
├── manifest.json         # 元数据 + 兼容声明 + 标签
├── references/           # 渐进式披露，按需加载
│   ├── frameworks.md     # 翻译框架识别（6 类）
│   ├── dll-analysis.md   # 二进制字符串提取（3 种方案）
│   ├── font-solutions.md # CJK 字体方案（按引擎）
│   └── troubleshooting.md
└── scripts/
    └── extract_strings.py # 通用 DLL 字符串提取工具
```

## 实现过程

### SKILL.md 设计

**触发条件**（写在 frontmatter `description` 中）：
```
Use when user asks to "translate mod", "localize game mod",
"汉化模组", "翻译mod"...
```

**5 步工作流**：
1. Step 0 — 识别目标（收集模组路径、游戏目录、目标语言）
2. Step 1 — 提取源字符串（按文件类型选提取方法）
3. Step 2 — 发现翻译基础设施（5 级优先级检查）
4. Step 3 — 生成翻译文件（对比已有→分类→翻译→写入）
5. Step 4 — 字体检查（确保 CJK 字符能渲染）
6. Step 5 — 验证与报告

**防跳过条款**：
| 想跳过 | 为什么不能 |
|--------|-----------|
| "反编译 DLL 改字符串" | String Heap 偏移破坏 → 崩溃 |
| "字体检查跳过" | 无 CJK 字形 → 全方块 |
| "格式随便写" | AutoTranslator 严格 `=` 分隔 |
| "直接改二进制" | PE 元数据破损 |

### extract_strings.py 设计

支持 3 种编码模式的字符串提取：
- UTF-16LE（.NET #US 堆，最常见）
- UTF-16BE（备选）
- ASCII（通用二进制）

功能：
- `--min-len N` 最小长度过滤
- `--encoding auto` 自动尝试所有编码
- `--classify` 自动分类（label/button/dialog/config_desc/log_format/size_label）
- `--ui-only` 仅显示 UI 可能字符串（过滤元数据）
- `--output file.txt` 输出到文件

### 发布流程

1. 目录结构调整为 `skills/game-mod-translator/`（Claude Code 发现约定）
2. 创建 `manifest.json`（name, version, compat, tags）
3. 中英双语 README.md + README_CN.md
4. `.gitignore` 排除 `__pycache__` / `.venv` / OS 文件
5. GitHub 创建仓库 → `git init` → `git push`

## 踩坑记录

### 坑 1：GitHub 用户名
- SKILL.md frontmatter 中 `homepage` 写的是 `xinshao/game-mod-translator`
- 实际 GitHub 账号是 `cxx2580`
- 修正：全部 4 个文件中的 `xinshao` → `cxx2580`

### 坑 2：Git Push SSL 失败
- Windows + 国内网络环境下 `git push` 报 SSL/TLS handshake 失败
- 解决：本地有代理 `http://127.0.0.1:7897`，git 默认不用
- 修正：`git -c http.proxy=http://127.0.0.1:7897 push`

### 坑 3：README.md 中英文混杂
- 英文 README.md 的 Quick Start 部分写了中文对话示例
- 修正：全部替换为英文

## 文件清单

```
game-mod-translator/
├── .gitignore
├── README.md                          # 英文说明
├── README_CN.md                       # 中文说明
├── docs/
│   ├── case-study-repo-spawn-manager.md  # 实战案例
│   └── skill-creation-log.md             # 本文
└── skills/
    └── game-mod-translator/
        ├── SKILL.md                   # 中文主技能
        ├── SKILL_EN.md                # 英文版
        ├── manifest.json
        ├── references/
        │   ├── dll-analysis.md
        │   ├── font-solutions.md
        │   ├── frameworks.md
        │   └── troubleshooting.md
        └── scripts/
            └── extract_strings.py
```

## 后续改进方向

- [ ] 支持更多翻译框架（WeMod、Vortex 等）
- [ ] 添加自动化测试（eval 触发/不触发用例）
- [ ] 支持批量翻译多个模组
- [ ] 集成机器翻译 API 减少人工校对
- [ ] 生成翻译后的验证截图
