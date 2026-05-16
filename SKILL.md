---
name: game-mod-translator
description: >
  Multi-engine game Chinese translation. Use when user wants to translate any
  game to Chinese, create translation files for game mods/plugins, or set up
  Chinese localization. Does NOT require Unity — auto-detects engine type and
  applies best strategy. Triggers: "翻译这个游戏", "汉化", "中文化", "translate
  this game", "localize game", "create Chinese translation for mod", "添加中文翻译",
  "做汉化", "Can this game be translated to Chinese".
---

# Game Mod Translator Skill (Multi-Engine)

> Auto-detect engine type → Apply best translation strategy.
> Primary: Unity (XUnity.AutoTranslator). Also handles Unreal, Godot, Ren'Py,
> RPG Maker, Source, Electron, and generic methods.

**Toolkit**: `C:\Users\xinshao\Desktop\game-mod-translator`

---

## Phase 0: Engine Detection (always first)

Check game directory for signature files. Order matters — first match wins.

### Detection Matrix

| Engine | Signature Files | Confidence |
|--------|----------------|------------|
| **Unity (Mono)** | `UnityPlayer.dll` + `MonoBepInEx/` or `*_Data/Mono/` | Very High |
| **Unity (IL2CPP)** | `UnityPlayer.dll` + `GameAssembly.dll` + `*_Data/il2cpp_data/` | Very High |
| **Unreal Engine 4/5** | `*.uproject` or `Engine/` + `Content/Paks/` | High |
| **Godot 3/4** | `*.pck` (or `*.x86_64` with godot), `project.binary` | High |
| **RPG Maker MV/MZ** | `www/data/` + `*.rpgproject` or `package.json` with "rpgmaker" | High |
| **RPG Maker VX/Ace** | `Game.exe` + `Data/` + `*.rvdata2` or `*.rgss3a` | High |
| **Ren'Py** | `renpy/` + `game/` + `*.rpy` or `*.rpa` | High |
| **Source Engine** | `gameinfo.txt` + `*.vpk` or `hl2.exe` | High |
| **Electron/Web** | `resources/app.asar` or `resources/app/` + `package.json` | High |
| **GameMaker** | `data.win` or `game.unx` + `options.ini` | Medium |
| **Java (LWJGL)** | `*.jar` + `natives/` | Medium |
| **Generic/Unknown** | Fallback: scan for text resource files | Low |

### Detection Command (run in game directory)

```bash
# Quick check
ls UnityPlayer.dll 2>/dev/null && echo "UNITY"
ls *.uproject 2>/dev/null && echo "UNREAL"
ls *.pck 2>/dev/null && echo "GODOT"
ls www/data/ 2>/dev/null && echo "RPGMAKER_MV"
ls renpy/ 2>/dev/null && echo "RENPY"
ls gameinfo.txt 2>/dev/null && echo "SOURCE"
ls resources/app.asar 2>/dev/null && echo "ELECTRON"
ls data.win 2>/dev/null && echo "GAMEMAKER"
```

---

## Phase 1: Engine-Specific Strategy

### Unity (Primary) → XUnity.AutoTranslator + CustomTranslate

**Applicability**: ~60% of modern indie/AA games. Full UI text hooking via Harmony.

**Prerequisites**: Game must have BepInEx 5.x installed.

**Workflow**:
1. Verify BepInEx at `<GameDir>/BepInEx/` + `<GameDir>/winhttp.dll`
2. Deploy engine DLLs from toolkit: `engine/plugins/XUnity.AutoTranslator/*` → game `BepInEx/plugins/`
3. Copy `engine/core/XUnity.Common.dll` → game `BepInEx/core/`
4. Copy `config/AutoTranslatorConfig.ini` → game `BepInEx/config/` (if not exists)
5. Create translation files in `BepInEx/config/Translation/zh_cn/*.txt`
6. Restart game

**Translation file format**:
```
# Exact match
Main Menu=主菜单
# Regex match (variables)
r:"^Level (\d+)$"=第 $1 关
```

**String extraction** (from DLL):
```python
import re
with open('Assembly-CSharp.dll', 'rb') as f:
    data = f.read()
for offset in range(0, len(data)-2, 2):
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
        if re.search(r'[A-Z][a-z].*[a-z]', s): print(s)
```

**Limitations**: BepInEx must be installed. For IL2CPP games, need IL2CPP-compatible BepInEx build.

---

### Unreal Engine → Locres Extraction + Re-pack OR Overlay

**Built-in localization** (UE4.20+):
- `Content/Localization/{GameName}/zh-CN/Game.locres` — localization resource file
- `Content/Localization/{GameName}/zh-CN/Game.archive` — text archive
- UE has first-class i18n with String Tables

**Workflow**:
1. Check if `Content/Paks/` or `Content/Localization/` exists
2. Use [UnrealLocres](https://github.com/akintos/UnrealLocres) CLI to export `.locres` → `.txt`:
   ```
   UnrealLocres.exe export Game.locres Game.txt
   ```
3. Translate the exported text (JSON or key=value format)
4. Re-pack: `UnrealLocres.exe import Game.txt Game.locres`
5. Place back in original path
6. Or use **UE4-DVORAK** / **FModel** for pak modding approach

**Alternative (pak modding)**:
1. Use FModel to browse `.pak` files, find text assets (String Tables, DataTables, UMG widgets)
2. Create a mod `.pak` with translated assets (higher mount priority)
3. Place in `~mods/` directory (if game supports loose loading)

**Limitations**: Complex. UE games often hard-code text in Blueprints/UMG. Pak repacking requires engine version matching. Less universal than Unity approach.

**Recommendation**: Check if fan translation already exists. UE localization is harder. For simple games, suggest hex-editing approach. For big games, point to existing UE translation community tools.

---

### Godot → Direct .po/.csv Editing

**Built-in**: Godot uses `.po` (gettext) or `.csv` for translations.

**Workflow**:
1. Find `translations/*.po` or `*.translation` files
2. If none, extract strings from `.pck` with [GodotPCKExplorer](https://github.com/DmitriySalnikov/GodotPCKExplorer)
3. Edit `.po` files directly with Poedit or text editor:
   ```
   msgid "Start Game"
   msgstr "开始游戏"
   ```
4. Place back. If `.pck` was modified, repack.

**Alternative**: If text is in `.tscn`/`.gd` scripts extracted from `.pck`:
1. Unpack `.pck` → raw project files
2. Find and translate strings in scripts
3. Godot auto-loads unpacked files over `.pck` if placed correctly

**Limitations**: If game compiled with text baked-in (no `.po`), need to re-export from source.

---

### Ren'Py → Script Translation / tl Directory

**Built-in translation system**: Ren'Py supports `game/tl/{language}/` with `.rpy` translation files.

**Workflow**:
1. Check `game/tl/` — if it exists, game has translation infrastructure
2. If not, check if `game/` has `.rpy` scripts (decompiled) or `.rpa` archives
3. If `.rpa` archives: use [UnRen](https://github.com/renpy/unrpa) to extract:
   `python unrpa.py game/scripts.rpa output/`
4. Create `game/tl/chinese/` directory
5. Generate translation template from scripts
6. Translate: Ren'Py tl format:
   ```
   # game/tl/chinese/script.rpy
   translate chinese strings:
       old "Start Game"
       new "开始游戏"
   ```
7. Use [Ren'Py SDK](https://www.renpy.org/) `Generate Translations` to create `.rpy` from source, then edit

**Limitations**: Only for Ren'Py visual novels. If game ships `.rpyc` (compiled) without `.rpa`, need Ren'Py decompiler.

---

### RPG Maker MV/MZ → JSON/JS Editing

**Workflow**:
1. Navigate to `www/data/`
2. Translate JSON data files:
   - `MapXXX.json` — map events, dialogue, names
   - `CommonEvents.json` — common event text
   - `Items.json` — item names/descriptions
   - `Skills.json` — skill names/descriptions
   - `Actors.json` — character names/profiles
   - `System.json` — system terms, menu labels
   - `Weapons.json`, `Armors.json`, `Enemies.json`, etc.
3. Also check `www/js/plugins/` for plugin config text
4. Direct text replacement in JSON values (preserve JSON structure)

**For RPG Maker VX/Ace**:
- `.rvdata2` files require [RPG Maker Trans](https://github.com/RetroMe/RPG-Maker-Trans) or similar
- Or create RGSS script patch that overrides text at runtime
- Simpler approach: use [Translator++](https://dreamsavior.net/translator-plus-plus/)

**Limitations**: MV/MZ is easy (plain JSON). VX/Ace harder (binary ruby marshal). Font support: need CJK font, replace `gamefont.css` or `mainfontface` in database.

---

### Source Engine (Valve) → Resource/CloseCaption

**Workflow**:
1. Find `resource/` directory
2. Translate `closecaption_*.txt` — subtitles
3. Translate `resource/*.txt` — UI labels, game text
4. If `.vpk` packed: use GCFScape to extract, translate, repack
5. Some games support `custom/` folder for loose file override

**Limitations**: Each Source game differs (TF2 vs Portal vs L4D). Some need VPK repacking. Font support: Source supports CJK with appropriate font files.

---

### Electron / Web → ASAR Unpack + JSON i18n

**Workflow**:
1. Unpack `resources/app.asar`:
   ```bash
   npx asar extract app.asar app-unpacked
   ```
2. Find i18n/locale files (usually `locales/zh-CN.json` or `i18n/zh.json`)
3. If no Chinese locale exists, copy `en.json` → `zh-CN.json` and translate values
4. Repack: `npx asar pack app-unpacked app.asar`

**Limitations**: Some games have webpack-hardcoded text (harder). May need to modify `index.html` or JS bundles. Fonts usually support CJK natively.

---

### Generic/Unknown Engine → Text Resource Scan

When engine can't be identified:

**Workflow**:
1. Scan for text-containing files:
   ```bash
   find . -type f \( -name "*.json" -o -name "*.xml" -o -name "*.csv" \
     -o -name "*.txt" -o -name "*.ini" -o -name "*.cfg" \
     -o -name "*.lang" -o -name "*.loc" -o -name "*.po" \) \
     -not -path "*/node_modules/*" -not -path "*/.git/*"
   ```
2. Sample each file for English text patterns
3. Identify which files are UI text vs config/logs
4. For JSON/XML: preserve structure, translate values
5. For `.csv`: translate specific columns
6. For unknown binary formats: use `strings` to extract, hex-editor to patch

**Fallback universal methods**:
- **OCR + Overlay**: For games with no accessible text files. Use OCR on screenshots → translation → d3d overlay. Tools like [Textractor](https://github.com/Artikash/Textractor) + [LunaTranslator](https://github.com/HIllya51/LunaTranslator).
- **Cheat Engine based**: Some translators hook process memory to find and replace text buffers in real-time.

---

## Phase 2: Font Consideration (all engines)

Most non-Chinese games lack CJK font glyphs. After translating text:

| Engine | Font Fix |
|--------|----------|
| Unity | `FallbackFontTextMeshPro=arialuni_sdf_u2022` in AutoTranslatorConfig |
| Unreal | Replace font asset in localization or use font override mod |
| Godot | Replace `.ttf`/`.otf` font files or DynamicFont settings |
| RPG Maker MV/MZ | Edit `fonts/gamefont.css`, replace `.ttf` with CJK-supporting font |
| Ren'Py | `style.default.font = "font.ttf"` in `gui.rpy`, use CJK font |
| Source | Add CJK font to `resource/` and update `ClientScheme.res` |
| Electron | Usually supports CJK natively (OS font fallback) |

Recommended CJK fonts: Noto Sans CJK, Source Han Sans, Microsoft YaHei, SimHei

---

## Toolkit Directory Structure

```
C:\Users\xinshao\Desktop\game-mod-translator/
├── engine/                          # Unity engine DLLs (XUnity.AutoTranslator)
│   ├── plugins/XUnity.AutoTranslator/
│   │   ├── Translators/CustomTranslate.dll
│   │   └── *.dll
│   └── core/XUnity.Common.dll
├── config/AutoTranslatorConfig.ini  # Template config
├── translations/zh_cn/_README.txt   # Format guide
├── setup.ps1 / setup.sh             # Unity deployment scripts
└── SKILL.md                         # This file
```

---

## Decision Flow Summary

```
User: "translate this game"
    │
    ├── Engine recognized?
    │   ├── Unity → Deploy XUnity.AutoTranslator + create txt files
    │   ├── Unreal → Extract locres → translate → repack (or recommend tools)
    │   ├── Godot → Direct .po/.csv editing
    │   ├── Ren'Py → Create tl/chinese/ directory + translate .rpy
    │   ├── RPG Maker MV/MZ → Edit www/data/*.json directly
    │   ├── RPG Maker VX/Ace → Use RPG Maker Trans or Translator++
    │   ├── Source → Edit resource/*.txt, GCFScape for .vpk
    │   ├── Electron → Unpack asar, add zh-CN locale, repack
    │   └── Other → Scan for text files, suggest fallback tools
    │
    └── Just want mod config translated?
        └── Create translation txt directly in BepInEx/config/Translation/zh_cn/
```
