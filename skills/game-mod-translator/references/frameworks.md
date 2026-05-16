# 翻译框架识别指南

> 何时读：Step 2 需要识别游戏已安装的翻译基础设施时。

---

## 1. XUnity.AutoTranslator（Unity 通用）

**最常用的 Unity 游戏翻译框架。**

### 识别特征
```
<GameRoot>/BepInEx/config/AutoTranslatorConfig.ini
<GameRoot>/BepInEx/plugins/XUnity.AutoTranslator/
<GameRoot>/BepInEx/config/Translation/{lang}/*.txt
```

### 配置文件关键项
```ini
[General]
Language=zh_cn                    # 目标语言
FromLanguage=en                   # 源语言

[Behaviour]
FallbackFontTextMeshPro=arialuni_sdf_u2022   # 回退字体（最关键）

[Files]
Directory=config\Translation\{Lang}          # 翻译文件目录
```

### 翻译文件格式
```
# 注释行以 # 开头
原文=译文

# 示例：
Enemies=敌人
Enable All=全部启用
Disable all enemies?=确定禁用所有敌人？
```

### 字体回退
- `FallbackFontTextMeshPro` 指向 URP/TMP 字体资产名（不含扩展名）
- 常用 CJK 字体：`arialuni_sdf_u2022`（Arial Unicode MS）、`notosanscjk_sc`
- 字体文件通常在 `<GameRoot>/BepInEx/config/Translation/{lang}/Fonts/`

### 工作原理
1. 游戏启动时加载
2. Harmony Hook 拦截 TMP_Text / UGUI Text 的文本设置方法
3. 检测到英文文本 → 查翻译字典 → 替换为目标语言 → 用回退字体渲染

---

## 2. BepInEx 配置翻译

**模组自带的 BepInEx 配置文件。**

### 识别特征
```
<GameRoot>/BepInEx/config/*.cfg
```

### 格式
```ini
[SectionName]

## 英文描述
# Setting type: String
# Default value:
KeyName =
```

### 翻译方式
- 仅翻译注释行（`##` 开头的描述文本）
- 不翻译 SectionName / KeyName（它们是代码标识符）
- 生成 `.cfg` 文件覆盖原配置（用户需手动替换）

---

## 3. 游戏原生本地化

### Unity 原生
```
<GameRoot>/<GameName>_Data/StreamingAssets/Localization/
<GameRoot>/Localization/
```
格式：JSON、CSV、PO

### Unreal Engine
```
<GameRoot>/Content/Localization/<lang>/
```
格式：`.locres`（编译后）、`.po`（源文件）

### Ren'Py / 视觉小说
```
<GameRoot>/game/tl/<lang>/
```
格式：`.rpy` 翻译脚本

### RPG Maker
```
<GameRoot>/data/   （JSON 内嵌文本）
<GameRoot>/www/data/ （MV/MZ 版本）
```

---

## 4. Mod 管理器翻译

### r2modman / Thunderstore
```
<GameRoot>/BepInEx/config/Translation/
```

### Vortex Mod Manager
```
<GameRoot>/mods/<mod-name>/lang/
```

---

## 5. 常见游戏速查

| 游戏 | 引擎 | 翻译框架 | 翻译目录 |
|------|------|---------|---------|
| R.E.P.O. | Unity | XUnity.AutoTranslator | `BepInEx/config/Translation/zh_cn/` |
| Lethal Company | Unity | XUnity.AutoTranslator | `BepInEx/config/Translation/zh_cn/` |
| Content Warning | Unity | XUnity.AutoTranslator | `BepInEx/config/Translation/zh_cn/` |
| Valheim | Unity | BepInEx 配置 | `BepInEx/config/` |
| RimWorld | Unity | 游戏原生 | `Languages/` |
| Skyrim/Fallout | Creation Engine | xTranslator/ESP | `Data/Strings/` |
| Stardew Valley | XNA/MonoGame | SMAPI + Content Patcher | `Mods/<mod>/i18n/` |
| Minecraft | Java | 资源包 / Resource Pack | `assets/<mod>/lang/` |

---

## 6. 自动检测流程

```
1. ls <GameRoot>/BepInEx/config/AutoTranslatorConfig.ini → 命中 = AutoTranslator
2. ls <GameRoot>/BepInEx/config/Translation/ → 命中 = 有翻译框架
3. ls <GameRoot>/BepInEx/plugins/*Translation* → 命中 = BepInEx 翻译插件
4. ls <GameRoot>/Localization/ → 命中 = 原生本地化
5. ls <GameRoot>/BepInEx/config/*.cfg → 命中 = BepInEx 配置
6. 以上都没有 → 建议安装 XUnity.AutoTranslator
```

**框架未安装时的安装建议**：
- Thunderstore/r2modman 用户：搜索 "Chinese Translation" 或 "XUnity.AutoTranslator"
- 手动安装：从 GitHub 下载 BepInEx + XUnity.AutoTranslator
- 推荐字体：Arial Unicode MS (arialuni_sdf_u2022) 或 Noto Sans CJK
