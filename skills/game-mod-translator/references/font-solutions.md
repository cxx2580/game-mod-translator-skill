# 游戏字体解决方案

> 何时读：Step 4 需要检查目标语言字体支持时。

---

## 核心问题

游戏引擎（Unity、Unreal 等）默认字体通常只包含 Latin-1（西欧字符集），
不包含 CJK（中文/日文/韩文）字形。翻译完成后如果字体不支持，所有
译文都会显示为方块（□□□）或空白。

---

## 按引擎分类

### Unity 游戏

#### 方案 1：XUnity.AutoTranslator 回退字体（最常用）

在 `AutoTranslatorConfig.ini` 中：

```ini
[Behaviour]
FallbackFontTextMeshPro=arialuni_sdf_u2022
```

**字体文件位置**：`BepInEx/config/Translation/{lang}/Fonts/arialuni_sdf_u2022`

**推荐 CJK 字体资产**：
| 字体名 | 覆盖字符集 | 文件大小 | 获取方式 |
|--------|----------|---------|---------|
| `arialuni_sdf_u2022` | CJK + 阿拉伯 + 西里尔 | ~22MB | Chinese Translation mod (Thunderstore) |
| `notosanscjk_sc` | 简体中文 + 日文 + 韩文 | ~16MB | Google Noto Fonts |
| `sourcehansans_sc` | 简体中文 | ~8MB | Adobe Source Han Sans |

#### 方案 2：AutoKFontPatcher（韩国社区方案）

自动注入字体 bundle 到游戏 Steam 本地文件。

```
依赖：BepInEx + RPKP
机制：启动时替换/注入字体资源（.bundle）
```

#### 方案 3：FontPatcher 组件

动态替换游戏中缺少 CJK 字形的字体，支持正则匹配字体名称。

#### 方案 4：BepInEx 字体插件

```
<GameRoot>/BepInEx/plugins/*Font*/*FontPatcher*.dll
```

### Unreal Engine 游戏

- 字体路径：`<GameRoot>/Content/UI/Fonts/`
- 替换方式：制作含 CJK 的 `.ufont` / `.ttf`，覆盖原字体文件
- 注意：需同时保留原字体的其他字符集

### RPG Maker 游戏

- 字体路径：`<GameRoot>/fonts/`
- 替换方式：将中文字体文件重命名为原字体文件名

### Java (Minecraft) 游戏

- 资源包 → `assets/minecraft/font/`
- 添加含 CJK 的 `.ttf` 字体 + 修改 `default.json` 的 font providers

---

## 验证方法

### 1. 检查翻译目录是否存在字体
```bash
ls <GameRoot>/BepInEx/config/Translation/zh_cn/Fonts/
```

### 2. 检查 AutoTranslator 配置
```bash
grep -i "fallbackfont" <GameRoot>/BepInEx/config/AutoTranslatorConfig.ini
```

### 3. 游戏内验证
- 确保含有中文文本的 UI 元素显示正常（不是方块）
- 测试特殊字符：·「」『』—…

---

## 常见问题

| 问题 | 原因 | 解决 |
|------|------|------|
| 译文显示方块 □□□ | 字体缺少 CJK 字形 | 配置 FallbackFontTextMeshPro |
| 译文完全不显示 | AutoTranslator 没加载 | 检查 BepInEx 日志 `LogOutput.log` |
| 部分字符方块（如「」） | 字体不含全角标点 | 换用 Arial Unicode MS 或 Noto Sans |
| 字体模糊 | TMP 字体资产分辨率太低 | 用高分辨率重新生成字体资产 |
