# Game Mod Translator · 游戏模组翻译

A [Claude Code](https://claude.ai/code) skill for translating game mod UI/text into any language — without decompiling DLLs, without modifying binaries, zero crash risk.

一个 [Claude Code](https://claude.ai/code) 技能，把游戏模组 UI/文本翻译成任意语言。不反编译 DLL，不修改二进制，零崩溃风险。

---

## What it does / 它能做什么

- Extracts user-facing strings from compiled `.dll` / `.exe` mod files
- Discovers existing translation infrastructure (XUnity.AutoTranslator, BepInEx, game-native)
- Generates translation files in the correct format
- Checks font support for CJK (Chinese/Japanese/Korean) characters
- Works with Unity, Unreal Engine, Godot, RPG Maker, Ren'Py, and more

- 从编译后的 `.dll` / `.exe` 模组文件中提取用户可见字符串
- 发现游戏已有的翻译基础设施（XUnity.AutoTranslator、BepInEx、游戏原生）
- 按正确格式生成翻译文件
- 检查 CJK（中日韩）字体支持
- 支持 Unity、Unreal、Godot、RPG Maker、Ren'Py 等多种引擎

---

## Quick Start / 快速开始

```
You: Translate this mod to Chinese for me
     Mod file: C:\...\SpawnManager.dll
     Game dir: C:\...\REPO\

Claude Code:
  1. Extracts 80+ UI strings from the DLL
  2. Discovers XUnity.AutoTranslator already installed
  3. Checks translation directory, identifies missing entries
  4. Generates translation file -> UI_Mod.txt
  5. Confirms CJK font is configured
  6. Done -- restart the game.
```

```
你: 帮我把这个模组汉化成中文
    模组文件: C:\...\SpawnManager.dll
    游戏目录: C:\...\REPO\

Claude Code:
  1. 从 DLL 提取 80+ 个 UI 字符串
  2. 发现游戏已安装 XUnity.AutoTranslator
  3. 检查翻译目录 → 生成管理器缺少翻译
  4. 生成翻译文件 → UI_Mod.txt
  5. 确认中文字体已配置
  6. 完成！重启游戏即可看到中文界面。
```

---

## Supported Engines / 支持引擎

| Engine | Method | Examples |
|--------|--------|----------|
| Unity + BepInEx | XUnity.AutoTranslator | R.E.P.O., Lethal Company, Content Warning, Valheim |
| Unity + BepInEx | BepInEx config translation | Various mods |
| Unreal Engine | .locres / .po | Satisfactory, Ark |
| Godot 3/4 | .po / .csv | Various indie games |
| RPG Maker MV/MZ | JSON editing | Various indie games |
| RPG Maker VX/Ace | .rvdata2 / .rgss3a | Various indie games |
| Ren'Py | tl/ directory | Visual novels |
| Source Engine | .vpk / gameinfo | Half-Life 2 mods, Portal mods |
| Electron/Web | .asar / .json | Various |
| GameMaker | data.win | Various indie games |

---

## Core Principle / 核心原则

```
编译好的 DLL → 不修改（崩溃风险）
运行时翻译框架 → 拦截文本 → 查表替换 → 安全稳定
```

**Hard rules / 铁律**：
- NEVER decompile a DLL to change string literals / 不反编译 DLL 改字符串
- NEVER hex-edit binary files / 不直接修改二进制
- ALWAYS discover existing translation infrastructure first / 优先发现已有的翻译基础设施
- Translation files are plain text: `source=target` / 翻译文件纯文本 `原文=译文`

---

## File Structure / 目录结构

```
game-mod-translator-skill/
├── README.md                     # This file
├── .gitignore
├── config/
│   └── AutoTranslatorConfig.ini  # Engine config template
├── engine/                       # Core DLLs, ready to deploy
│   ├── core/XUnity.Common.dll
│   └── plugins/XUnity.AutoTranslator/
├── references/                   # Per-engine guides
│   ├── dll-analysis.md
│   ├── font-solutions.md
│   ├── frameworks.md
│   └── troubleshooting.md
├── scripts/
│   └── extract_strings.py        # DLL string extraction
├── translations/zh_cn/
├── setup.ps1                     # Windows automated setup
└── setup.sh                      # Unix automated setup
```

---

## Requirements / 依赖

- Python 3.8+ (for `extract_strings.py`)
- Claude Code or compatible AI coding agent

---

## License / 许可证

MIT
