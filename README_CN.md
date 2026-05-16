# Game Mod Translator · 游戏模组翻译技能

一个 [Claude Code](https://claude.ai/code) 技能，用于将游戏模组 UI/文本翻译成任意语言。
**不反编译 DLL，不修改二进制文件，零崩溃风险。**

## 它能做什么

- 从编译后的 `.dll` / `.exe` 模组文件中提取用户可见字符串
- 发现游戏已有的翻译基础设施（XUnity.AutoTranslator、BepInEx、游戏原生）
- 按正确格式生成翻译文件
- 检查 CJK（中日韩）字体支持
- 支持 Unity、Unreal、RPG Maker、Minecraft 等多种游戏引擎

## 安装

```bash
# 克隆到 Claude Code skills 目录
git clone https://github.com/xinshao/game-mod-translator.git

# 或直接复制技能文件夹
cp -r skills/game-mod-translator ~/.claude/skills/
```

## 使用示例

```
你: 帮我把这个模组汉化成中文
    模组文件: C:\...\SpawnManager.dll
    游戏目录: C:\...\REPO\

Claude Code:
  1. 从 DLL 提取 80+ 个 UI 字符串 ✓
  2. 发现游戏已安装 XUnity.AutoTranslator ✓
  3. 检查翻译目录 → Spawn Manager 缺少翻译 ✗
  4. 生成翻译文件 → UI_Mod.txt（724B → 5KB）✓
  5. 确认中文字体已配置 ✓
  6. 完成！重启游戏即可看到中文界面。
```

## 支持的游戏/引擎

| 引擎/平台 | 翻译方式 | 代表游戏 |
|----------|---------|---------|
| Unity + BepInEx | XUnity.AutoTranslator | R.E.P.O.、Lethal Company、Content Warning |
| Unity + BepInEx | BepInEx 配置翻译 | Valheim |
| Unreal Engine | .locres / .po | Satisfactory、Ark |
| RPG Maker | JSON 语言文件 | 各类独立游戏 |
| Minecraft Java | 资源包 / Resource Pack | 各种模组 |
| Stardew Valley | SMAPI + i18n | 各种 SMAPI 模组 |
| Skyrim/Fallout | ESP/Strings 翻译 | 各种 Creation Engine 模组 |

## 核心原则

```
编译好的 DLL → 不修改（崩溃风险）
运行时翻译框架 → 拦截文本 → 查表替换 → 安全稳定
```

**铁律**：
- ❌ 绝不反编译 DLL 改字符串
- ❌ 绝不直接修改二进制文件
- ✅ 优先发现游戏已安装的翻译基础设施
- ✅ 翻译文件纯文本格式 `原文=译文`

## 目录结构

```
game-mod-translator/
├── README.md / README_CN.md
├── skills/
│   └── game-mod-translator/
│       ├── SKILL.md              # 主工作流
│       ├── manifest.json         # 技能元数据
│       ├── references/           # 渐进式参考文档
│       │   ├── frameworks.md     # 翻译框架识别
│       │   ├── dll-analysis.md   # 二进制字符串提取
│       │   ├── font-solutions.md # 字体方案
│       │   └── troubleshooting.md
│       └── scripts/
│           └── extract_strings.py # DLL 字符串提取工具
```

## 依赖

- Python 3.8+（用于 `extract_strings.py`）
- Claude Code 或兼容的 AI 编程助手

## 许可证

MIT
