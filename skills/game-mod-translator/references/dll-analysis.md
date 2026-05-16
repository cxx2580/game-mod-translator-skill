# DLL 二进制字符串提取

> 何时读：Step 1 需要从编译后的 DLL/二进制文件中提取字符串时。

---

## 核心原理

编译后的 .NET DLL 包含多个堆（Heap）：
- **#Strings** — 元数据字符串（类名、方法名）
- **#US (User Strings)** — **我们需要的**：代码中的字符串字面量，以 UTF-16LE 编码

文件开头：`MZ` 签名 → PE 头 → .NET 元数据 → #US 堆 → 字符串内容

---

## 提取方法

### 方案 A：Python 正则提取 UTF-16LE（推荐，跨平台）

```python
import re
import sys

def extract_utf16le_strings(filepath, min_len=4):
    with open(filepath, 'rb') as f:
        data = f.read()

    # UTF-16LE 模式：可打印 ASCII char + \x00 交替
    results = set()
    i = 0
    while i < len(data) - 1:
        if 32 <= data[i] < 127 and data[i+1] == 0:
            chars = []
            j = i
            while (j < len(data) - 1 and
                   32 <= data[j] < 127 and
                   data[j+1] == 0):
                chars.append(chr(data[j]))
                j += 2
            if len(chars) >= min_len:
                results.add(''.join(chars))
            i = j
        else:
            i += 1

    return sorted(results)

if __name__ == '__main__':
    strings = extract_utf16le_strings(sys.argv[1])
    for s in strings:
        print(s)
```

### 方案 A2：增强版（也检查 ASCII 字符串）

```python
import re

def extract_all_strings(filepath, min_len=4):
    with open(filepath, 'rb') as f:
        data = f.read()

    results = set()

    # 1. ASCII 连续字符串
    for m in re.finditer(rb'[\x20-\x7e]{%d,}' % min_len, data):
        s = m.group().decode('ascii', errors='ignore')
        if ' ' in s or any(c.isalpha() for c in s):
            results.add(s)

    # 2. UTF-16LE 字符串
    i = 0
    while i < len(data) - 1:
        if 32 <= data[i] < 127 and data[i+1] == 0:
            chars = []
            j = i
            while j < len(data) - 1 and 32 <= data[j] < 127 and data[j+1] == 0:
                chars.append(chr(data[j]))
                j += 2
            if len(chars) >= min_len:
                results.add(''.join(chars))
            i = j
        else:
            i += 1

    return sorted(results)
```

### 方案 B：strings 命令（Linux/macOS）

```bash
strings -n 4 -e l SpawnManager.dll | sort -u
```

- `-e l` = UTF-16LE 编码
- `-n 4` = 最小长度 4

Windows 无此命令，优先用方案 A。

### 方案 C：dnSpy / ILSpy（GUI，仅查看）

- 拖 DLL 进 dnSpy → 查看源码 → 手动复制字符串
- 不推荐用于批量提取

---

## 字符串分类

提取后按以下类别分组：

| 类别 | 特征 | 示例 |
|------|------|------|
| **UI 标签** | 简短、首字母大写 | `Enemies`, `Valuables`, `Levels` |
| **按钮文本** | 动词开头 | `Enable All`, `Disable All`, `Back` |
| **弹窗文案** | 问句或完整句 | `Disable all enemies?` |
| **配置描述** | 逗号分隔、e.g. 示例 | `Comma-separated list of enemy names...` |
| **日志消息** | 含 `[ModuleName]` 前缀或 format 占位符 | `[RemoveItems] Removed item` |
| **尺寸/层级** | 数字 + 形容词 | `01 Tiny`, `02 Small`, `03 Medium` |
| **技术标识符** | 驼峰/下划线、无空格 | `DisabledList`, `PluginGuid` ← 不翻译 |

### 自动分类规则
```python
def classify_string(s):
    s = s.strip()
    if not s: return 'skip'
    if s.startswith('<') or s.startswith('.'): return 'skip'  # 元数据
    if '{0}' in s or '{1}' in s: return 'log'
    if '?' in s and len(s) > 10: return 'dialog'
    if ',' in s and len(s) > 30: return 'config_desc'
    if s.startswith(('Enable', 'Disable', 'Show', 'Hide')): return 'button'
    if len(s) < 20: return 'label'
    return 'other'
```

---

## 安全红线

| 操作 | 风险 |
|------|------|
| 直接 hex-edit DLL 修改字符串 | PE 元数据偏移破坏 → 不可逆损坏 |
| 用 ILSpy 反编译后重新编译 | 依赖项版本不一致 → 运行时崩溃 |
| 修改字符串长度 > 原长度 | String Heap 溢出 → 破坏后续数据 |
| 删除 DLL 中的字符串 | 代码引用空指针 → NullReferenceException |
