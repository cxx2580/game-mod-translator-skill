# Game Mod Translator

Universal multi-engine game localization toolkit + Claude Code Skill. **No binary modification, zero crash risk.**

## Supported Engines

| Engine | Method | Difficulty | Examples |
|--------|--------|:----------:|----------|
| **Unity** | BepInEx + XUnity.AutoTranslator + txt | Easy | R.E.P.O., Lethal Company, Valheim |
| **Ren'Py** | `tl/{lang}/*.rpy` translation files | Easy | Visual novels |
| **RPG Maker MV/MZ** | Direct `www/data/*.json` editing | Easy | Indie RPGs |
| **RPG Maker VX/Ace** | Translator++ / RGSS script patches | Medium | Older RPG Maker games |
| **Godot** | `.po` / `.csv` translation editing | Easy | Cassette Beasts, Brotato |
| **Source (Valve)** | `resource/closecaption_*.txt` | Medium | Portal, L4D, TF2 |
| **Electron/Web** | Unpack asar → add locale → repack | Easy | Web-based games |
| **Unreal Engine** | Locres extract/translate/repack | Hard | Satisfactory, Ark |
| **GameMaker** | UndertaleModTool text extraction | Medium | Undertale, Hotline Miami |
| **Unknown** | Text resource scan / OCR fallback | — | Any game |

## Installation

```bash
git clone https://github.com/cxx2580/game-mod-translator.git ~/.claude/skills/game-mod-translator/
```

## Usage

```
You: Translate this mod to Chinese
     Mod: C:\...\SharedUpgradesPlus.dll
     Game: C:\...\REPO\

Claude:
  1. Detect: Unity + BepInEx ✓
  2. Extract UI strings from DLL ✓
  3. AutoTranslator installed ✓
  4. Generate Translation/zh_cn/SharedUpgradesPlus.txt (75 entries) ✓
  5. Done! Restart game to apply.
```

```
You: Translate this RPG Maker game
     Game: D:\Games\MyRPG\

Claude:
  1. Detect: RPG Maker MV ✓
  2. Found www/data/ JSON files ✓
  3. Translate Maps, Items, Skills, System terms ✓
  4. Copy CJK font to fonts/ ✓
  5. Done!
```

## Structure

```
game-mod-translator/
├── engine/plugins/XUnity.AutoTranslator/  # Unity runtime engine DLLs
├── engine/core/XUnity.Common.dll
├── config/AutoTranslatorConfig.ini         # Config template
├── translations/zh_cn/_README.txt          # Translation format guide
├── scripts/extract_strings.py              # DLL string extractor
├── references/                             # Reference docs
│   ├── frameworks.md                       # Translation framework detection
│   ├── dll-analysis.md                     # Binary string extraction
│   ├── font-solutions.md                   # CJK font solutions
│   └── troubleshooting.md                  # Common issues
├── setup.ps1 / setup.sh                    # Unity deployment scripts
├── README.md / README_CN.md
└── SKILL.md                                # Skill definition
```

## How It Works

```
Unity:     Harmony Hook UI Render → Intercept English → Lookup .txt Dict → Replace
Other:     Read/Edit text resource files directly (JSON/XML/PO/RPY)
```

**Rules:**
- Never decompile DLLs to modify strings
- Never patch binary files
- Prefer existing game translation infrastructure
- Pure text translation: `Source=Translation`

## Dependencies

- Python 3.8+ (`extract_strings.py`)
- BepInEx 5.x (Unity only, user pre-installs)
- Claude Code or compatible AI assistant

## License

MIT
