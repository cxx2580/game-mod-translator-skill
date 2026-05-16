#!/bin/bash
# === Game Mod Translator Setup (Bash) ===
# 将 XUnity.AutoTranslator + CustomTranslate 翻译引擎部署到 Unity 游戏
# 用法: ./setup.sh <游戏根目录>
# 示例: ./setup.sh "/c/Program Files/Steam/steamapps/common/MyGame"

set -e

GAME_DIR="${1:?请指定游戏根目录}"
TOOLKIT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 检查目标是否为 Unity 游戏
check_unity_game() {
    local dir="$1"
    # 检查 Unity 典型特征文件
    if [ -d "$dir/${GAME_NAME}_Data" ] || [ -f "$dir/UnityPlayer.dll" ] || [ -f "$dir/GameAssembly.dll" ]; then
        return 0
    fi
    # 检查子目录
    for d in "$dir"/*_Data; do
        if [ -d "$d" ]; then
            GAME_NAME="$(basename "$d" _Data)"
            return 0
        fi
    done
    return 1
}

# 检查 BepInEx 是否已安装
check_bepinex() {
    [ -d "$1/BepInEx" ] && [ -f "$1/winhttp.dll" ] && [ -f "$1/doorstop_config.ini" ]
}

echo "=== Game Mod Translator Setup ==="
echo "目标: $GAME_DIR"

# 检测 Unity 游戏
if ! check_unity_game "$GAME_DIR"; then
    echo "错误: 未检测到 Unity 游戏特征文件 (UnityPlayer.dll / *_Data / GameAssembly.dll)"
    echo "请确认路径正确，或手动指定游戏名: GAME_NAME=xxx $0 $GAME_DIR"
    exit 1
fi
echo "检测到 Unity 游戏: $GAME_NAME"

# 检查 BepInEx
if ! check_bepinex "$GAME_DIR"; then
    echo ""
    echo "============================================="
    echo " BepInEx 未安装！请先安装 BepInEx 5.x:"
    echo " 1. 下载: https://github.com/BepInEx/BepInEx/releases"
    echo " 2. 解压到游戏根目录: $GAME_DIR"
    echo " 3. 运行一次游戏生成配置文件"
    echo " 4. 重新执行此脚本"
    echo "============================================="
    exit 1
fi
echo "BepInEx: OK"

# 创建目录结构
mkdir -p "$GAME_DIR/BepInEx/plugins/XUnity.AutoTranslator/Translators"
mkdir -p "$GAME_DIR/BepInEx/core"
mkdir -p "$GAME_DIR/BepInEx/config/Translation/zh_cn"

# 复制引擎文件
echo "安装引擎核心..."
cp -r "$TOOLKIT_DIR/engine/plugins/XUnity.AutoTranslator/"* "$GAME_DIR/BepInEx/plugins/XUnity.AutoTranslator/"
cp "$TOOLKIT_DIR/engine/core/XUnity.Common.dll" "$GAME_DIR/BepInEx/core/"

# 复制配置（如不存在）
if [ ! -f "$GAME_DIR/BepInEx/config/AutoTranslatorConfig.ini" ]; then
    cp "$TOOLKIT_DIR/config/AutoTranslatorConfig.ini" "$GAME_DIR/BepInEx/config/"
    echo "配置: AutoTranslatorConfig.ini (新建)"
else
    echo "配置: AutoTranslatorConfig.ini (已存在，跳过)"
fi

# 复制翻译模板
if [ ! -f "$GAME_DIR/BepInEx/config/Translation/zh_cn/_README.txt" ]; then
    cp "$TOOLKIT_DIR/translations/zh_cn/_README.txt" "$GAME_DIR/BepInEx/config/Translation/zh_cn/"
fi

echo ""
echo "=== 安装完成 ==="
echo "引擎: BepInEx/plugins/XUnity.AutoTranslator/"
echo "配置: BepInEx/config/AutoTranslatorConfig.ini"
echo "翻译目录: BepInEx/config/Translation/zh_cn/"
echo ""
echo "下一步: 创建翻译文件"
echo "  在 BepInEx/config/Translation/zh_cn/ 下新建 .txt 文件"
echo "  格式: 英文原文=中文翻译"
echo "  参考: BepInEx/config/Translation/zh_cn/_README.txt"
echo ""
echo "重启游戏生效。"
