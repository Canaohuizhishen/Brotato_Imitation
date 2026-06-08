#!/usr/bin/env python3
"""
tools/sync_data.py  — 将 data/json/*.json 同步到 logic/DataLoader.js

工作原理：找到 DataLoader.js 中每个 `var _XXX_DATA = [` 的位置，
替换从该行到数组结束（匹配的 `];`）之间的全部内容。
数组结束判定：对多行数组找独占一行的 `]`，对单行数组找 `}];` 或 `];`。
"""

import json, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATALOADER = os.path.join(ROOT, "logic", "DataLoader.js")
JSON_DIR   = os.path.join(ROOT, "data", "json")

# 映射：JSON 文件名 → DataLoader 中的变量名
DATA_SETS = [
    ("weapons.json",        "_WEAPONS_DATA"),
    ("props.json",          "_PROPS_DATA"),
    ("roles.json",          "_ROLES_DATA"),
    ("upgradeOptions.json", "_UPGRADE_OPTIONS_DATA"),
    ("monsters.json",       "_MONSTERS_DATA"),
    ("waves.json",          "_WAVES_DATA"),
]


def strip_json_comments(text):
    """去掉 JSON 中的 // 和 /* */ 注释"""
    out, i, instr = [], 0, False
    while i < len(text):
        c = text[i]
        if c == '"' and (i == 0 or text[i-1] != '\\'):
            instr = not instr
            out.append(c); i += 1; continue
        if not instr and c == '/' and i+1 < len(text):
            if text[i+1] == '/':
                while i < len(text) and text[i] != '\n': i += 1
                continue
            if text[i+1] == '*':
                i += 2
                while i < len(text) and not (text[i] == '*' and text[i+1] == '/'): i += 1
                i += 2; continue
        out.append(c); i += 1
    return ''.join(out)


def find_array_end(lines, start_line):
    """
    从 start_line 开始找数组结束位置。
    返回第一个独占一行且括号深度归零的 ] 的行号。
    """
    depth = 0
    started = False
    for i in range(start_line, len(lines)):
        # 逐字符扫描本行以正确处理嵌套 []
        line = lines[i]
        for ch in line:
            if ch == '[':
                depth += 1
                started = True
            elif ch == ']':
                depth -= 1
                if started and depth == 0:
                    # 检查这一行是否只有 ] (可能有尾随 ;)
                    stripped = line.strip()
                    if stripped == ']' or stripped == '];':
                        return i
                    # 单行数组：}]; 或 }]
                    if stripped.endswith('}]') or stripped.endswith('}];'):
                        return i
                    # 如果这一行有 ] 但还有其它内容，继续（应在下一行结束）
    return None


def main():
    with open(DATALOADER, 'r', encoding='utf-8') as f:
        content = f.read()
    lines = content.split('\n')

    success = True
    for json_file, var_name in DATA_SETS:
        json_path = os.path.join(JSON_DIR, json_file)
        if not os.path.exists(json_path):
            print(f"⚠  找不到 {json_file}")
            continue

        # 读取 JSON（含注释）
        with open(json_path, 'r', encoding='utf-8') as f:
            raw = f.read()
        data = json.loads(strip_json_comments(raw))

        # 格式化为 JS 数组（2 空格缩进，与源码风格一致）
        js_lines = json.dumps(data, indent=2, ensure_ascii=False).split('\n')
        # 首行是 [，末行是 ]，中间是要保留的数据行
        new_lines = [f"var {var_name} = ["]
        new_lines.extend(js_lines[1:-1])  # 保留 json.dumps 自带的 2 空格缩进
        new_lines.append("]")

        # 在 DataLoader 中找到 var _XXX_DATA = [
        var_decl = f"var {var_name} = ["
        start_idx = None
        for i, line in enumerate(lines):
            if line.strip().startswith(var_decl):
                start_idx = i
                break

        if start_idx is None:
            print(f"❌ 在 DataLoader.js 中找不到 {var_decl}")
            success = False
            continue

        end_idx = find_array_end(lines, start_idx)
        if end_idx is None:
            print(f"❌ 无法确定 {var_name} 的数组结束位置")
            success = False
            continue

        # 替换
        old_slice = lines[start_idx:end_idx+1]
        lines[start_idx:end_idx+1] = new_lines
        print(f"✅ {json_file} → {var_name} (替换 {len(old_slice)} 行 → {len(new_lines)} 行)")

    if not success:
        sys.exit(1)

    new_content = '\n'.join(lines)
    # 内容没变就不写文件，避免触发 CMake 重新编译
    try:
        with open(DATALOADER, 'r', encoding='utf-8') as f:
            old_content = f.read()
    except FileNotFoundError:
        old_content = ''
    if new_content == old_content:
        print("\n📝 DataLoader.js 无变化，跳过写入")
    else:
        open(DATALOADER, 'w', encoding='utf-8').write(new_content)
        print("\n📝 DataLoader.js 已同步")


if __name__ == "__main__":
    main()
