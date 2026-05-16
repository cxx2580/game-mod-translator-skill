# Game Mod Translator Setup (PowerShell)
# 将 XUnity.AutoTranslator + CustomTranslate 翻译引擎部署到 Unity 游戏
# 用法: .\setup.ps1 -GameDir "D:\Steam\steamapps\common\MyGame"
param(
    [Parameter(Mandatory=$true)]
    [string]$GameDir
)

$ErrorActionPreference = "Stop"
$ToolkitDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=== Game Mod Translator Setup ===" -ForegroundColor Cyan
Write-Host "目标: $GameDir"

# 检测 Unity 游戏
$isUnity = $false
$gameName = ""
$dataDirs = Get-ChildItem -Path $GameDir -Filter "*_Data" -Directory -ErrorAction SilentlyContinue
if ($dataDirs.Count -gt 0) {
    $gameName = $dataDirs[0].Name -replace "_Data$", ""
    $isUnity = $true
} elseif ((Test-Path "$GameDir\UnityPlayer.dll") -or (Test-Path "$GameDir\GameAssembly.dll")) {
    $isUnity = $true
    $gameName = (Split-Path -Leaf $GameDir)
}

if (-not $isUnity) {
    Write-Host "错误: 未检测到 Unity 游戏特征 (UnityPlayer.dll / *_Data / GameAssembly.dll)" -ForegroundColor Red
    Write-Host "请确认路径正确"
    exit 1
}
Write-Host "检测到 Unity 游戏: $gameName" -ForegroundColor Green

# 检查 BepInEx
if (-not (Test-Path "$GameDir\BepInEx") -or -not (Test-Path "$GameDir\winhttp.dll")) {
    Write-Host ""
    Write-Host "=============================================" -ForegroundColor Yellow
    Write-Host " BepInEx 未安装! 请先安装 BepInEx 5.x:" -ForegroundColor Yellow
    Write-Host " 1. 下载: https://github.com/BepInEx/BepInEx/releases" -ForegroundColor Yellow
    Write-Host " 2. 解压到游戏根目录: $GameDir" -ForegroundColor Yellow
    Write-Host " 3. 运行一次游戏生成配置文件" -ForegroundColor Yellow
    Write-Host " 4. 重新执行此脚本" -ForegroundColor Yellow
    Write-Host "=============================================" -ForegroundColor Yellow
    exit 1
}
Write-Host "BepInEx: OK" -ForegroundColor Green

# 创建目录
$dirs = @(
    "$GameDir\BepInEx\plugins\XUnity.AutoTranslator\Translators",
    "$GameDir\BepInEx\core",
    "$GameDir\BepInEx\config\Translation\zh_cn"
)
foreach ($d in $dirs) {
    if (-not (Test-Path $d)) {
        New-Item -ItemType Directory -Path $d -Force | Out-Null
    }
}

# 复制引擎文件
Write-Host "安装引擎核心..."
Copy-Item -Path "$ToolkitDir\engine\plugins\XUnity.AutoTranslator\*" -Destination "$GameDir\BepInEx\plugins\XUnity.AutoTranslator\" -Recurse -Force
Copy-Item -Path "$ToolkitDir\engine\core\XUnity.Common.dll" -Destination "$GameDir\BepInEx\core\" -Force

# 复制配置
if (-not (Test-Path "$GameDir\BepInEx\config\AutoTranslatorConfig.ini")) {
    Copy-Item -Path "$ToolkitDir\config\AutoTranslatorConfig.ini" -Destination "$GameDir\BepInEx\config\" -Force
    Write-Host "配置: AutoTranslatorConfig.ini (新建)" -ForegroundColor Green
} else {
    Write-Host "配置: AutoTranslatorConfig.ini (已存在，跳过)" -ForegroundColor Yellow
}

# 复制翻译模板
if (-not (Test-Path "$GameDir\BepInEx\config\Translation\zh_cn\_README.txt")) {
    Copy-Item -Path "$ToolkitDir\translations\zh_cn\_README.txt" -Destination "$GameDir\BepInEx\config\Translation\zh_cn\" -Force
}

Write-Host ""
Write-Host "=== 安装完成 ===" -ForegroundColor Cyan
Write-Host "引擎: BepInEx\plugins\XUnity.AutoTranslator\" -ForegroundColor Gray
Write-Host "配置: BepInEx\config\AutoTranslatorConfig.ini" -ForegroundColor Gray
Write-Host "翻译目录: BepInEx\config\Translation\zh_cn\" -ForegroundColor Gray
Write-Host ""
Write-Host "下一步: 在翻译目录创建 .txt 文件，格式: 英文原文=中文翻译" -ForegroundColor White
Write-Host "重启游戏生效。"
