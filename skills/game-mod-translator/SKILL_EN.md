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
  - gemini-cli
  - opencode
---

# Game Mod Translator

Translate game mod UI/text into any language. No DLL decompilation. No binary
modification. Zero crash risk. Works with Unity, Unreal Engine, RPG Maker,
Minecraft, and more.

---

## Core Principle

```
Compiled DLL/EXE → NEVER modify directly (metadata offset corruption + missing glyphs)
Runtime translation framework → Hook text renderer → Dictionary lookup → Safe injection
```

**Hard rules**:
- NEVER decompile a DLL to change string literals
- NEVER hex-edit binary files to replace text
- ALWAYS discover the game's existing translation infrastructure first
- Translation files are plain text: `source=target`, one per line

---

## Workflow

### Step 0: Gather Inputs

From the user, collect:
1. **Mod file path** — the `.dll` / `.exe` / `.pak` / directory to translate
2. **Game root directory** — the folder containing `BepInEx/` or `plugins/` or `mods/`
3. **Target language** — default `zh_cn` (Simplified Chinese) if unspecified

### Step 1: Extract Source Strings

**Goal**: Pull every user-visible UI string from compiled mod files.

**Method by file type**:

| File type | Extraction method |
|-----------|------------------|
| .NET DLL (`.dll`, Mono/.NET) | Python regex for UTF-16LE string patterns |
| Unity AssetBundle (`.assets`, `.bundle`) | `strings` command + filter |
| JSON / XML / YAML config | Read directly |
| Unreal `.pak` | Unpack with `unpackpak`, then scan text |
| Lua scripts (`.lua`) | Read directly |
| Ren'Py scripts (`.rpy`) | Read directly |

See [`references/dll-analysis.md`](references/dll-analysis.md) for details.

**Standard extraction command** (uses bundled `scripts/extract_strings.py`):
```bash
python scripts/extract_strings.py <path-to-dll> --encoding auto --min-len 4 --classify
```

**Output**: A sorted, categorized list of all readable strings ≥ 4 characters:
button labels, toggle text, dialog prompts, config descriptions, log messages.

### Step 2: Discover Translation Infrastructure

**Goal**: Scan the game directory to find existing translation frameworks.
Determine the translation file format and output location.

**Checklist** (in priority order):

1. **XUnity.AutoTranslator** (most common for Unity games)
   - Config: `<game>/BepInEx/config/AutoTranslatorConfig.ini`
   - Translation dir: `<game>/BepInEx/config/Translation/{lang}/`
   - Format: `source=target` plain text
   - Font field: `FallbackFontTextMeshPro=`

2. **BepInEx translation plugins**
   - Path pattern: `<game>/BepInEx/plugins/*Translation*` / `*Localization*`
   - Translation dir: `<game>/BepInEx/config/*Translation*/`

3. **Game-native localization**
   - Path pattern: `<game>/Localization/` / `<game>/Data/locales/` / `<game>/lang/`
   - Format: JSON, CSV, PO, or `.locres`

4. **Mod built-in config**
   - Path: `<game>/BepInEx/config/<modname>.cfg`
   - Format: BepInEx INI config (`key = value`)

5. **Nothing found**
   → Tell the user no translation framework exists. Recommend installing
   XUnity.AutoTranslator or the appropriate framework for their game engine.

See [`references/frameworks.md`](references/frameworks.md) for per-game quick reference.

### Step 3: Generate Translation File

**When a framework IS found**:

1. Diff Step 1 strings against existing translation files
2. Identify missing entries: `missing = all_strings − translated_strings`
3. Sort into categories:
   - `# UI 标签` — UI labels
   - `# 按钮/操作文本` — button/action text
   - `# 弹窗/确认文案` — dialog/confirmation prompts
   - `# 配置描述` — config descriptions
   - `# 日志消息` — log messages
4. Translate each string to the target language, **preserving all format placeholders**
5. Write to the framework-expected file path

**When NO framework is found**:
- Generate a standard XUnity.AutoTranslator-format translation file
- Tell the user which framework to install and where to place the file

### Step 4: Font Check

**Goal**: Ensure the target language's characters will render (not show as □□□).

- **Unity**: Check `FallbackFontTextMeshPro` in `AutoTranslatorConfig.ini`
- **CJK (Chinese / Japanese / Korean)**: Requires `arialuni_sdf_u2022` (Arial Unicode MS)
  or `NotoSansCJKsc` — these contain CJK glyphs that default Unity fonts lack
- **No CJK font found**: Tell the user to install AutoKFontPatcher or manually
  configure a fallback font

See [`references/font-solutions.md`](references/font-solutions.md) for per-engine solutions.

### Step 5: Validate & Report

1. Report total translation entries added
2. List which UI areas are covered
3. Output the exact file path(s) modified
4. Remind the user to restart the game to verify

---

## Bundled Resources

| File | When to load |
|------|-------------|
| [`references/frameworks.md`](references/frameworks.md) | Step 2 — identifying the translation framework |
| [`references/dll-analysis.md`](references/dll-analysis.md) | Step 1 — analyzing DLL/binary files |
| [`references/font-solutions.md`](references/font-solutions.md) | Step 4 — checking font support |
| [`references/troubleshooting.md`](references/troubleshooting.md) | Translation not working / crashes / display issues |
| `scripts/extract_strings.py` | Step 1 — extracting strings from DLLs |

---

## Anti-Skip Provisions

| What you might think | Why you can't skip it |
|---------------------|----------------------|
| "Just decompile the DLL and change the strings — it's faster" | .NET String Heap offsets will break → game crash. Always prefer runtime translation frameworks. |
| "Font check is optional" | Unity default fonts have ZERO CJK glyphs → every translated character renders as □□□. Must confirm fallback font first. |
| "Any file format works for translations" | AutoTranslator requires exact `source=target` syntax. Format errors silently skip entire files. |
| "Hex-edit the English text in the binary" | Changing string length breaks PE metadata → mod won't load. |

---

## Common Translation Scenarios

### Unity + BepInEx + AutoTranslator (most common)
```
Mod DLL → extract_strings.py → check Translation/{lang}/ → add missing → done
```

### Mod with built-in JSON/YAML language files
```
Read directly → translate values → write back → done (no framework needed)
```

### Unreal Engine mod
```
.pak → unpack → scan text → generate .locres / .po → done
```

### No translation infrastructure at all
```
Extract strings → recommend XUnity.AutoTranslator → generate file → done
```

---

## Translation Quality Rules

1. **Preserve placeholders**: `{0}` `{1}` `%s` `%d` `{{variable}}` — keep exactly as-is
2. **Preserve rich text tags**: `<b>` `</b>` `<color=...>` `<sprite name=...>` — keep exactly
3. **Preserve escape sequences**: `\n` `\t` `\"` — keep exactly
4. **Preserve newlines**: Multi-line strings must retain `\n`
5. **Group with comments**: Use `# category name` headers between sections
6. **Never translate code identifiers**: Class names, method names, variable names
7. **Never translate file paths**: `config/Translation/zh_cn/` stays as-is
8. **Match exact original text**: AutoTranslator does exact-match lookup — no fuzzy matching

---

## Game Engine Quick Reference

| Engine | Framework | Translation Path |
|--------|-----------|-----------------|
| Unity + BepInEx | XUnity.AutoTranslator | `BepInEx/config/Translation/{lang}/` |
| Unity (no BepInEx) | Game-native JSON | `StreamingAssets/Localization/` |
| Unreal Engine | Game-native `.locres` | `Content/Localization/{lang}/` |
| RPG Maker MV/MZ | Game-native JSON | `data/` or `www/data/` |
| Minecraft Java | Resource pack | `assets/{mod}/lang/` |
| Stardew Valley | SMAPI Content Patcher | `[CP] Mod/i18n/` |
| Skyrim / Fallout | xTranslator | `Data/Strings/` |
| Ren'Py | Game-native `.rpy` | `game/tl/{lang}/` |

---

## Tips from Real-World Use

1. **Google Fonts blocking in China**: If fonts.css `@import url(https://fonts.googleapis.com/...)` hangs,
   comment out the imports — themes will fall back to system monospace fonts
2. **`import type` vs `import`**: TypeScript interfaces are erased at compile time.
   Use `import type { Foo }` for type-only imports — `tsc --noEmit` won't catch this,
   but Vite/esbuild will fail at runtime with "does not provide an export named"
3. **Stale node processes on Windows**: Use `powershell -Command "Stop-Process -Name node -Force"`
   when `taskkill` isn't available from bash shells
4. **Translation file encoding**: Always UTF-8 without BOM, CRLF line endings on Windows
5. **Session resume**: Use `--resume` or provide context summary when restarting Claude Code
   sessions to avoid re-explaining the project structure
