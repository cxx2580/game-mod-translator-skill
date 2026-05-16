---
name: game-mod-translator
description: >
  Unity game Chinese translation using XUnity.AutoTranslator + CustomTranslate.
  Use when user wants to translate any Unity game to Chinese, create translation
  files for Unity mods/plugins, or set up Chinese localization for a Unity game.
  Triggers: "翻译这个游戏", "汉化", "中文化", "translate this game", "localize
  Unity game", "create Chinese translation for mod", "添加中文翻译", "做汉化".
  Also use when user asks to translate BepInEx plugin config text or mod UI.
---

# Game Mod Translator Skill

> Deploy XUnity.AutoTranslator + CustomTranslate engine to any Unity game.
> Add Chinese translation files. Zero online API needed.

**Toolkit**: `C:\Users\xinshao\Desktop\game-mod-translator`
**Engine**: XUnity.AutoTranslator 5.6.1 + CustomTranslate (offline local translation)

---

## Architecture

```
Target Game/
├── BepInEx/                          # Required: BepInEx 5.x pre-installed
│   ├── core/
│   │   └── XUnity.Common.dll         # Shared utilities
│   ├── plugins/
│   │   └── XUnity.AutoTranslator/    # Translation engine
│   │       ├── *.Core.dll            # Text hooking engine (the core)
│   │       ├── *Plugin.BepInEx.dll   # BepInEx plugin bridge
│   │       ├── ExIni.dll             # INI parser
│   │       ├── BatterUpgradeUI.dll   # UI utilities
│   │       ├── FileCopyPreLoader.dll # Preloader
│   │       ├── *ResourceRedirector*  # Asset redirection
│   │       └── Translators/
│   │           └── CustomTranslate.dll  # Local file translator
│   └── config/
│       ├── AutoTranslatorConfig.ini  # Engine config
│       └── Translation/
│           └── zh_cn/                # Chinese translation files (*.txt)
│               ├── Menu.txt
│               ├── GameUI.txt
│               └── ...
├── doorstop_config.ini               # BepInEx boot config
└── winhttp.dll                       # BepInEx proxy DLL
```

**How it works**: XUnity.AutoTranslator.Core hooks Unity UI text components (TextMeshPro, UGUI, IMGUI) via Harmony patches. Before text reaches GPU, CustomTranslate intercepts and does a dictionary lookup against `Translation/zh_cn/*.txt`. If found → replaces with Chinese. If not found → passes through unchanged.

---

## Setup Workflow

### Step 1: Verify BepInEx

```
Check: <GameDir>/BepInEx/ exists, <GameDir>/winhttp.dll exists
Check: <GameDir>/doorstop_config.ini exists
```

If missing: tell user to install BepInEx 5.x from https://github.com/BepInEx/BepInEx/releases
Unzip to game root, run game once to generate configs.

### Step 2: Deploy Engine

Copy from toolkit to game:

| From (Toolkit) | To (Game) |
|---|---|
| `engine/plugins/XUnity.AutoTranslator/*` | `BepInEx/plugins/XUnity.AutoTranslator/` |
| `engine/core/XUnity.Common.dll` | `BepInEx/core/` |

If `AutoTranslatorConfig.ini` doesn't exist: copy from `config/`.
If exists: skip (don't overwrite user config).

### Step 3: Create Translation Files

Create `.txt` files in `<GameDir>/BepInEx/config/Translation/zh_cn/`.

Format:
```
# Comment
English text=中文翻译
r:"^regex pattern (.*)$"=替换 $1
```

Rules:
- UTF-8 encoding (no BOM)
- `#` starts a comment line
- `=` separates key and value (first `=` only)
- Regex: `r:"pattern"=replacement` with `$1`, `$2` capture groups
- `\n` for newlines in values
- Exact match preferred over regex for static text
- File name doesn't matter — all `.txt` files are loaded

### Step 4: Find Strings to Translate

Method to find UI strings:
1. **Read game/mod DLL** with Python UTF-16LE string extraction:
   ```python
   import re
   with open('Assembly-CSharp.dll', 'rb') as f:
       data = f.read()
   # Extract .NET user strings (UTF-16LE null-terminated)
   step = 2
   for offset in range(0, len(data)-step, step):
       chars = []
       end = offset
       while end < len(data)-1:
           b1, b2 = data[end], data[end+1]
           if b1 == 0 and b2 == 0: break
           if 0x20 <= b1 <= 0x7e and b2 == 0:
               chars.append(chr(b1)); end += 2
           else: break
       if len(chars) >= 4:
           s = ''.join(chars)
           # Keep strings that look like UI text
           if re.search(r'[A-Z][a-z].*[a-z]', s): print(s)
   ```
2. **Read BepInEx config files** (`.cfg`) for mod config descriptions
3. **Run game with `EnableSilentMode=False`** to log untranslated strings to BepInEx console (advanced)

### Step 5: Test

Restart game. If text still English:
1. Check BepInEx console for errors
2. Verify file encoding is UTF-8
3. Verify exact spelling matches
4. Try regex pattern if text has embedded variables

---

## Quick Setup (Automated)

Run setup script from toolkit:
```powershell
# PowerShell
.\setup.ps1 -GameDir "D:\Steam\steamapps\common\MyGame"

# Bash
./setup.sh "/c/Program Files/Steam/steamapps/common/MyGame"
```

This copies engine files, creates directories, and installs config template.

---

## Translation File Templates

### Simple static text
```
# Game UI
Main Menu=主菜单
Settings=设置
Start Game=开始游戏
Quit=退出
Back=返回
Yes=是
No=否
OK=确定
Cancel=取消
```

### Config section headers (REPOConfig / BepInEx config UI)
```
General=通用
Effects=效果
Vanilla=原版
Modded=模组
```

### Dynamic text with variables (regex)
```
r:"^Enable sharing for (.+)$"=启用共享：$1
r:"^Kill (.*?)$"=击杀 $1
r:"^You can only have (\d+) save files$"=你只能有 $1 个存档文件
```

### Log levels / enum values
```
Off=关
Debug=调试
Verbose=详细
Low=低
Medium=中
High=高
```

---

## Limitations

- **Text only**: Cannot translate text baked into textures/images (use Texture translation cautiously)
- **Unity UI only**: Text in custom shaders or non-standard rendering won't be caught
- **IL2CPP games**: BepInEx must be IL2CPP-compatible build; engine works but may need bleeding-edge BepInEx
- **Font fallback**: Chinese chars need a font with CJK glyphs; set `FallbackFontTextMeshPro=arialuni_sdf_u2022` in config

---

## Toolkit Directory

```
C:\Users\xinshao\Desktop\game-mod-translator/
├── engine/                          # Core DLLs, ready to deploy
│   ├── plugins/XUnity.AutoTranslator/
│   │   ├── Translators/CustomTranslate.dll
│   │   └── *.dll
│   └── core/XUnity.Common.dll
├── config/AutoTranslatorConfig.ini  # Clean template
├── translations/zh_cn/_README.txt   # Format guide
├── setup.ps1                        # Windows automated setup
├── setup.sh                         # Unix automated setup
└── SKILL.md                         # This file (reference copy)
```
