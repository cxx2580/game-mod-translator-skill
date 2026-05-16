---
name: game-mod-translator
version: 1.0.0
description: >
  Translate game mod UI/localization files into any target language without
  decompiling DLLs. Works with Unity (BepInEx/XUnity.AutoTranslator),
  Unreal Engine, and other mod frameworks. Analyzes compiled mod binaries,
  discovers existing translation infrastructure, and generates translation
  files safely — no binary modification, no crash risk. Use when user asks
  to "translate mod", "localize game mod", "汉化模组", "翻译mod", or needs
  to convert mod UI text from one language to another.
license: MIT
homepage: https://github.com/xinshao/game-mod-translator
compat:
  - claude-code
  - claude-ai
  - cursor
  - codex-cli
---

# Game Mod Translator

把游戏模组的 UI/文本翻译成任意语言。不反编译 DLL，不动二进制文件，零崩溃风险。

---

## 核心原则

```
编译好的 DLL/EXE → 不直接修改（元数据偏移崩溃 + 字体缺失）
运行时翻译框架 → 拦截文本渲染 → 查表替换 → 安全稳定
```

**铁律**：
- 绝对不反编译 DLL 改字符串
- 绝对不直接修改二进制文件
- 优先发现游戏已安装的翻译基础设施
- 翻译文件纯文本，格式 = `原文=译文`，一行一条

---

## 工作流

### Step 0：识别目标

从用户获取：
1. 模组文件路径（DLL / EXE / pak / 目录）
2. 游戏目录（含 BepInEx / plugins / mods 的根目录）
3. 目标语言（默认简体中文 `zh_cn`）

### Step 1：提取源字符串

**目标**：从编译后的模组文件中提取所有用户可见的 UI 字符串。

**方法按文件类型**：
| 文件类型 | 提取方式 |
|---------|---------|
| .NET DLL (.dll, Mono/.NET) | Python 正则提取 UTF-16LE 字符串模式 |
| Unity AssetBundle (.assets, .bundle) | `strings` 命令 + 过滤 |
| JSON/XML/YAML 配置 | 直接读取 |
| Unreal .pak | 先用 `unpackpak` 解包，再扫文本 |
| Lua 脚本 (.lua) | 直接读取 |

详见 [`references/dll-analysis.md`](references/dll-analysis.md)。

**Python 提取 .NET DLL 字符串的标准脚本**（已在 `scripts/extract_strings.py`）：
```bash
python scripts/extract_strings.py <path-to-dll> --encoding utf16le --min-len 4
```

**输出**：所有长度 ≥4 的可读字符串列表，包含 UI 标签、按钮文本、弹窗文案、配置描述。

### Step 2：发现翻译基础设施

**目标**：检查游戏目录，找到已有的翻译框架，确定翻译文件格式和位置。

**检查清单**（按优先级）：

1. **XUnity.AutoTranslator**（Unity 游戏通用）
   - 路径：`<game>/BepInEx/config/AutoTranslatorConfig.ini`
   - 翻译目录：`<game>/BepInEx/config/Translation/{lang}/`
   - 格式：`原文=译文` 纯文本
   - 字体配置：`FallbackFontTextMeshPro=` 字段

2. **BepInEx 翻译插件**
   - 路径：`<game>/BepInEx/plugins/*Translation*`、`*Localization*`
   - 翻译目录：`<game>/BepInEx/config/*Translation*/`

3. **游戏原生本地化**
   - 路径：`<game>/Localization/`、`<game>/Data/locales/`、`<game>/lang/`
   - 格式：JSON、CSV、PO 文件

4. **模组内置配置**
   - 路径：`<game>/BepInEx/config/<modname>.cfg`
   - 格式：BepInEx 配置（`key = value`）

5. **什么都没找到**
   → 告知用户当前游戏无翻译基础设施，建议安装 XUnity.AutoTranslator 或对应框架。

详见 [`references/frameworks.md`](references/frameworks.md)。

### Step 3：生成翻译文件

**已找到翻译框架**：

1. 对比 Step 1 提取的字符串与已有翻译文件
2. 识别缺失翻译（`missing = all_strings - translated_strings`）
3. 按类别分组：
   - 按钮标签 / UI 标签
   - 开关文本 / 选项
   - 弹窗确认
   - 配置项描述
   - 日志消息
4. 逐条翻译为中文，**保留 `{0}` `{1}` 等格式化占位符**
5. 按框架格式写入翻译文件

**没有翻译框架**：
- 生成标准 XUnity.AutoTranslator 格式的翻译文件
- 提醒用户安装对应框架

### Step 4：字体检查

**目标**：确保目标语言字符能正常渲染。

- Unity 游戏：检查 `FallbackFontTextMeshPro` 是否配置支持目标语言字符集的字体
- 中文/日文/韩文：需要 `arialuni_sdf_u2022`（Arial Unicode MS）或 `NotoSansCJKsc`
- 没有合适字体：告知用户安装 AutoKFontPatcher 或手动配置回退字体

详见 [`references/font-solutions.md`](references/font-solutions.md)。

### Step 5：验证与报告

1. 列出所有翻译条目数量
2. 标注哪些 UI 区域被覆盖
3. 输出翻译文件路径
4. 提醒用户重启游戏验证

---

## 捆绑资源

| 文件 | 何时加载 |
|------|---------|
| [`references/frameworks.md`](references/frameworks.md) | 需要在 Step 2 识别翻译框架时 |
| [`references/dll-analysis.md`](references/dll-analysis.md) | 需要在 Step 1 分析 DLL/二进制文件时 |
| [`references/font-solutions.md`](references/font-solutions.md) | 需要在 Step 4 检查字体支持时 |
| [`references/troubleshooting.md`](references/troubleshooting.md) | 翻译不正确显示或游戏崩溃时 |
| `scripts/extract_strings.py` | 需要在 Step 1 从 DLL 提取字符串时 |

---

## 防跳过条款

| 你可能会想 | 为什么不能跳过 |
|-----------|--------------|
| "直接反编译 DLL 改字符串更快" | .NET String Heap 偏移会被破坏 → 游戏崩溃。永远用运行时翻译框架替代。 |
| "字体检查可以跳过" | Unity 默认字体无 CJK 字形 → 翻译后全是方块。必须先确认回退字体。 |
| "翻译文件格式随便写" | AutoTranslator 严格 `=` 分隔，格式错误会导致整文件被忽略。 |
| "直接改二进制里的英文" | 字符串长度变化 → PE 元数据破损 → 模组无法加载。 |

---

## 常见模组翻译场景

### Unity + BepInEx + AutoTranslator（最常见）
```
模组 DLL → extract_strings.py → 查 Translation/zh_cn/ → 补翻译 → 完成
```

### 模组自带 JSON/YAML 语言文件
```
直接读取 → 翻译 → 写回 → 完成（无需任何框架）
```

### Unreal Engine 模组
```
.pak → unpackpak → 扫文本 → 生成 .locres/.po → 完成
```

### 无任何翻译基础设施
```
提取字符串 → 建议安装 XUnity.AutoTranslator → 生成翻译文件 → 完成
```

---

## 翻译质量规范

1. **保留占位符**：`{0}` `{1}` `%s` `%d` `{{variable}}` 必须原样保留
2. **保留富文本标签**：`<b>` `</b>` `<color=...>` `<sprite name=...>` 原样保留
3. **保留转义序列**：`\n` `\t` `\"` 原样保留
4. **保留换行符**：多行原文中的 `\n` 不删除
5. **分类分组**：UI 标签、弹窗、配置描述、日志消息用 `# 注释` 分隔
6. **不翻译代码标识符**：类名、方法名、变量名不翻译
7. **不翻译文件路径**：`config/Translation/zh_cn/` 等路径不翻译
8. **原文必须完全匹配**：AutoTranslator 做精确匹配查找，多空格/少换行都会导致匹配失败

---

## 实战经验

1. **国内 Google Fonts 被墙**：如果 `fonts.css` 中 `@import url(https://fonts.googleapis.com/...)` 阻塞页面加载，注释掉所有 @import 行，主题会降级到系统等宽字体
2. **`import type` vs `import`**：TypeScript interface 编译后会被擦除。类型导入必须用 `import type { Foo }`，`tsc --noEmit` 不会报错但 Vite/esbuild 运行时会炸 "does not provide an export named"
3. **Windows 残留 node 进程**：bash 里 `taskkill` 不可用时用 `powershell -Command "Stop-Process -Name node -Force"`
4. **翻译文件编码**：必须 UTF-8 无 BOM，换行 CRLF
5. **会话恢复**：Claude Code 会话断开后，新会话用 `--resume` 或提供上下文摘要，避免重新解释项目结构
