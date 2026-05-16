# 故障排查

> 何时读：翻译不生效、游戏崩溃、文字显示异常时。

---

## 翻译不生效

| 现象 | 可能原因 | 修复 |
|------|---------|------|
| 游戏内仍显示英文 | AutoTranslator 未启用 | 检查 `BepInEx/config/AutoTranslatorConfig.ini` 存在且 `[General]` 段配置正确 |
| 翻译文件写了但没用 | 文件编码错误 | 确认文件编码为 UTF-8（无 BOM），换行符为 CRLF |
| 部分字符串翻译，部分不翻译 | 原文不完全匹配 | DLL 提取的字符串可能与运行时文本有细微差异（多余空格、换行） |
| 模组更新后翻译失效 | DLL 中字符串已变更 | 重新运行 Step 1 提取，对比新旧字符串差异 |

---

## 游戏崩溃

| 现象 | 可能原因 | 修复 |
|------|---------|------|
| 启动时崩溃 | 字体文件损坏或格式不兼容 | 重新下载字体文件，确认 Unity TMP 格式 |
| 打开特定菜单崩溃 | 翻译文本中包含非法字符 | 检查翻译中是否有未转义的特殊字符（`=` 在行首/行尾） |
| `NullReferenceException` | AutoTranslator 版本不兼容 | 更新到与游戏/BepInEx 兼容的版本 |

---

## 文字显示异常

| 现象 | 可能原因 | 修复 |
|------|---------|------|
| 显示方块 □□□ | 字体无 CJK 字形 | 参考 `font-solutions.md` 配置回退字体 |
| 文字重叠/超出 | 翻译文本比原文长很多 | 精简译文，或调整 UI 缩放 |
| 文字模糊 | 字体资产分辨率低 | 重新生成高分辨率 TMP 字体资产 |
| 文字闪烁 | AutoTranslator 与另一插件冲突 | 检查 BepInEx 日志，禁用冲突插件 |

---

## 翻译文件格式错误

| 错误 | 影响 | 修复 |
|------|------|------|
| 缺少 `=` 分隔符 | 该行被跳过 | 确保每行格式为 `原文=译文` |
| `=` 周围有空格 | 匹配失败 | 去掉 `=` 前后的空格 |
| 注释行 `#` 后无内容 | 无害 | 忽略或删除空的注释行 |
| 重复的原文 key | 后者覆盖前者 | 删除重复项 |
| 原文中包含 `=` | 匹配失败（只匹配第一个 `=`） | 用 `\=` 转义或修改原文 |

---

## 验证命令

```bash
# 1. 确认 AutoTranslator 加载
grep -i "autotranslator" <GameRoot>/BepInEx/LogOutput.log

# 2. 确认翻译文件被读取
grep -i "translation.*loaded" <GameRoot>/BepInEx/LogOutput.log

# 3. 检查翻译文件编码
file -bi <GameRoot>/BepInEx/config/Translation/zh_cn/*.txt

# 4. 统计翻译条数
grep -c "=" <GameRoot>/BepInEx/config/Translation/zh_cn/UI_Mod.txt
```
