# Game Mod Translator

A [Claude Code](https://claude.ai/code) skill for translating game mod UI/text into any language — without decompiling DLLs, without modifying binaries, zero crash risk.

## What it does

- Extracts user-facing strings from compiled `.dll` / `.exe` mod files
- Discovers existing translation infrastructure (XUnity.AutoTranslator, BepInEx, game-native)
- Generates translation files in the correct format
- Checks font support for CJK (Chinese/Japanese/Korean) characters
- Works with Unity, Unreal Engine, RPG Maker, Minecraft, and more

## Installation

```bash
# Clone into your Claude Code skills directory
git clone https://github.com/cxx2580/game-mod-translator-skill.git

# Or copy the skill folder directly
cp -r skills/game-mod-translator-skill ~/.claude/skills/
```

## Quick Start

```
You: Translate this mod to Chinese for me
     Mod file: C:\...\SpawnManager.dll
     Game dir: C:\...\REPO\

Claude Code:
  1. Extracts 80+ UI strings from the DLL
  2. Discovers XUnity.AutoTranslator already installed
  3. Checks translation directory, identifies missing entries
  4. Generates translation file → UI_Mod.txt
  5. Confirms CJK font is configured ✓
  6. Done — restart the game.
```

## Supported Games

Any game with mod support, including:

- **Unity + BepInEx**: R.E.P.O., Lethal Company, Content Warning, Valheim, etc.
- **Unreal Engine**: Satisfactory, Ark, Conan Exiles, etc.
- **RPG Maker**: Various indie games
- **Minecraft**: Java Edition mods
- **Stardew Valley**: SMAPI mods
- **Skyrim/Fallout**: Creation Engine mods

## How it works

```
Mod DLL (compiled)
    ↓ extract_strings.py
All UI strings (English)
    ↓ scan game directory
Translation framework found? (AutoTranslator / native / config)
    ↓
Generate translation file (English=TargetLang)
    ↓
Font check (CJK support)
    ↓
Done — restart game
```

**Key principle**: Never decompile or modify DLLs. Always use the game's existing
translation framework to inject translated text at runtime.

## File Structure

```
game-mod-translator-skill/
├── README.md                    # This file
├── README_CN.md                 # Chinese version
├── skills/
│   └── game-mod-translator-skill/
│       ├── SKILL.md             # Main skill workflow
│       ├── manifest.json        # Skill metadata
│       ├── references/
│       │   ├── frameworks.md    # Translation framework guide
│       │   ├── dll-analysis.md  # Binary string extraction
│       │   ├── font-solutions.md # CJK font guide
│       │   └── troubleshooting.md
│       └── scripts/
│           └── extract_strings.py
```

## Requirements

- Python 3.8+ (for `extract_strings.py`)
- Claude Code or compatible AI coding agent
- Node.js / npm (if using with Claude Code CLI)

## License

MIT
