# Case Study: Translating R.E.P.O. Spawn Manager Mod

> 用 ClaudeCode 将 R.E.P.O. 游戏的 Enemy And Valuable Spawn Manager 模组从英文汉化为中文的完整过程。

## 背景

- **游戏**: R.E.P.O. (2025 合作恐怖游戏)
- **模组**: Enemy And Valuable Spawn Manager v0.6.9
- **作者**: SoundedSquash
- **文件**: `SpawnManager.dll` (60KB, .NET/Mono)
- **框架**: BepInEx + MenuLib
- **目标**: 将模组 UI 从英文翻译为简体中文

## 过程

### 第 1 步：分析 DLL

模组只有一个编译后的 `SpawnManager.dll`，没有源代码、没有配置文件、没有 JSON/XML 资源文件。所有 UI 文本硬编码在 DLL 中。

**提取字符串**：

```bash
python scripts/extract_strings.py SpawnManager.dll --encoding auto --min-len 4 --classify
```

使用 Python 正则从二进制中提取 UTF-16LE 编码的字符串（.NET #US 堆）。

**输出**：80+ 条 UI 字符串，分为：

| 类别 | 数量 | 示例 |
|------|------|------|
| UI 标签 | 12 | `Enemies`, `Valuables`, `Items`, `Levels` |
| 开关文本 | 8 | `Enable All`, `Disable All` |
| 弹窗提示 | 10 | `Disable all enemies?`, `Enable all Levels?` |
| 配置描述 | 32 | `Comma-separated list of enemy names to disable...` |
| 尺寸标签 | 7 | `01 Tiny` ~ `07 Very Tall` |
| 日志消息 | 15 | `[RemoveItems] Removed item` |

### 第 2 步：关键决策——不能反编译

初始想法是反编译 DLL → 改 C# 源码中的字符串 → 重新编译。

ClaudeCode 分析后指出：
- .NET String Heap 是编译时生成的，修改字符串长度会破坏元数据偏移
- 轻则 UI 乱码，重则游戏崩溃
- Unity 原生字体只支持拉丁字符，中文会显示为方块（□□□）
- **结论**: 反编译方案风险太高，不可行

### 第 3 步：发现翻译基础设施

ClaudeCode 扫描游戏目录后发现了关键信息：

```
<REPO>/BepInEx/config/AutoTranslatorConfig.ini  ← XUnity.AutoTranslator 已安装
<REPO>/BepInEx/config/Translation/zh_cn/        ← 中文翻译目录已存在
```

检查结果：
- ✓ XUnity.AutoTranslator 已安装并配置
- ✓ 回退字体 `arialuni_sdf_u2022` 已配置（Arial Unicode MS，支持 CJK）
- ✓ 翻译目录 `zh_cn/` 已存在，敌人名/物品名/游戏 UI 已翻译
- ✗ Spawn Manager 模组的 UI 未被翻译

### 第 4 步：生成翻译文件

目标文件：`<REPO>/BepInEx/config/Translation/zh_cn/UI_Mod.txt`

格式：`英文=中文`，一行一条。

翻译要点：
1. 保留所有格式化占位符：`{0}` `{1}` 原样不动
2. 保留富文本标签：`<sprite name=...>` 原样不动
3. 按类别分组，用 `# 注释` 分隔
4. 尺寸标签保留数字前缀

**翻译对照**（部分）：

| 英文原文 | 中文翻译 |
|---------|---------|
| Enemy/Valuable Spawn Manager | 敌人/贵重物品生成管理器 |
| Spawn Manager | 生成管理器 |
| Enable All | 全部启用 |
| Disable all enemies? | 确定禁用所有敌人？ |
| Comma-separated list of enemy names to disable... | 逗号分隔的要禁用的敌人名称列表... |
| Arena | 竞技场 |
| Shops (keep one) | 商店 (保留一个) |
| Default Valuable | 默认贵重物品 |
| 01 Tiny | 01 微型 |
| 07 Very Tall | 07 超高型 |

### 第 5 步：验证

- 翻译条目: 80+ 条
- 文件大小: 724 B → ~5 KB
- 字体: Arial Unicode MS 已配置，CJK 显示正常
- 覆盖范围: 主菜单按钮、子菜单页面、弹窗确认、配置描述、尺寸标签、日志消息

## 关键经验

1. **编译好的 DLL 不要试图反编译改字符串** — 用运行时翻译框架是唯一安全的方式
2. **先扫描游戏目录再动手** — 往往已经有人装好了翻译基础设施，只是缺翻译内容
3. **格式化占位符是绝对红线** — `{0}` `{1}` 动了就崩
4. **中文字体是硬前提** — 翻译前先确认 FallbackFontTextMeshPro
5. **一行代码没写** — 整个过程是纯分析和文本生成，不涉及编译或二进制修改

## 文件清单

- 输入: `SpawnManager.dll` (60KB)
- 输出: `UI_Mod.txt` (5KB, 80+ 条翻译)
- 路径: `<REPO>/BepInEx/config/Translation/zh_cn/UI_Mod.txt`
