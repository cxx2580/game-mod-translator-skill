# Game Mod Translator · 游戏翻译工具包

通用多引擎游戏汉化工具包 + Claude Code Skill。**不改二进制，零崩溃风险。**

## 支持引擎

| 引擎 | 翻译方式 | 难度 | 代表游戏 |
|------|----------|:----:|----------|
| **Unity** | BepInEx + XUnity.AutoTranslator + txt | 低 | R.E.P.O., Lethal Company, Valheim |
| **Ren'Py** | `tl/chinese/*.rpy` 翻译文件 | 低 | 视觉小说类 |
| **RPG Maker MV/MZ** | 直接编辑 `www/data/*.json` | 低 | 各类独立 RPG |
| **RPG Maker VX/Ace** | Translator++ / RGSS 脚本补丁 | 中 | 老式 RPG Maker 游戏 |
| **Godot** | 编辑 `.po` / `.csv` 翻译文件 | 低 | Cassette Beasts, Brotato |
| **Source (Valve)** | `resource/closecaption_*.txt` | 中 | Portal, L4D, TF2 |
| **Electron/Web** | 解包 asar → 加语言包 → 重打包 | 低 | 各类网页游戏 |
| **Unreal Engine** | Locres 提取/翻译/重打包 | 高 | Satisfactory, Ark |
| **GameMaker** | UndertaleModTool 文本提取 | 中 | Undertale, Hotline Miami |
| **未知引擎** | 文本资源扫描 / OCR 兜底方案 | — | 任意游戏 |

## 安装

```bash
# 克隆到 Claude Code skills 目录
git clone https://github.com/cxx2580/game-mod-translator.git ~/.claude/skills/game-mod-translator/

# 或复制到技能目录
cp -r . ~/.claude/skills/game-mod-translator/

# 拷贝引擎 DLL（仅 Unity 需要）
# 已包含在 engine/ 目录中，skill 激活后自动部署
```

## 使用示例

```
你: 帮我把这个模组汉化成中文
    模组文件: C:\...\SharedUpgradesPlus.dll
    游戏目录: C:\...\REPO\

Claude:
  1. 检测引擎: Unity + BepInEx ✓
  2. 从 DLL 提取 UI 字符串 ✓
  3. AutoTranslator 已安装 ✓
  4. 生成 Translation/zh_cn/SharedUpgradesPlus.txt ✓
  5. 75 条翻译条目，UTF-8 编码 ✓
  6. 完成！重启游戏生效。
```

```
你: 这个 Ren'Py 游戏能汉化吗？
    游戏目录: D:\Games\Doki Doki Literature Club

Claude:
  1. 检测引擎: Ren'Py ✓
  2. 发现 game/tl/ 目录（已有翻译基础设施）✓
  3. 提取 game/script.rpy 文本 ✓
  4. 创建 game/tl/chinese/ 翻译文件 ✓
  5. 完成！
```

## 目录结构

```
game-mod-translator/
├── engine/                               # Unity 运行时翻译引擎
│   ├── plugins/XUnity.AutoTranslator/    # 8 个 DLL + CustomTranslate
│   └── core/XUnity.Common.dll
├── config/AutoTranslatorConfig.ini       # 引擎配置模板
├── translations/zh_cn/_README.txt        # 翻译格式说明
├── scripts/extract_strings.py            # DLL 字符串提取工具
├── references/                           # 参考文档（按需加载）
│   ├── frameworks.md                     # 翻译框架识别
│   ├── dll-analysis.md                   # 二进制字符串提取原理
│   ├── font-solutions.md                 # 中文字体方案
│   └── troubleshooting.md                # 常见问题排查
├── setup.ps1 / setup.sh                  # Unity 一键部署脚本
├── README.md / README_CN.md
└── SKILL.md                              # Skill 定义（在 .claude/skills/）
```

## 核心原理

```
Unity:   Harmony Hook UI 渲染 → 拦截英文 → 查 .txt 字典 → 替换中文
其他引擎: 直接读取/编辑文本资源文件（JSON/XML/PO/RPY）
```

**铁律：**
- 不反编译 DLL 修改字符串（崩溃风险）
- 不修改二进制文件
- 优先利用游戏已有的翻译基础设施
- 纯文本翻译文件 `原文=译文`

## 依赖

- Python 3.8+（`extract_strings.py`）
- BepInEx 5.x（仅 Unity 引擎，需用户预装）
- Claude Code 或兼容 AI 编程助手

## 许可证

MIT
