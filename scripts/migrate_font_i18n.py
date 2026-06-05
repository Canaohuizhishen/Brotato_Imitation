#!/usr/bin/env python3
"""
批量迁移脚本 v2：
1. font.pixelSize / font.pointSize → ScaledText + basePixelSize + uiScale
2. text: "中文" → text: I18n.tr("中文")

修复：contentItem: Text { 和 Text { 都会正确替换为 ScaledText
"""

import re
import os

EXCLUDE_DIRS = {'build', '.reasonix', '.git', 'node_modules'}
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(SCRIPT_DIR)

def find_qml_files(root):
    files = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in EXCLUDE_DIRS]
        for f in filenames:
            if f.endswith('.qml'):
                files.append(os.path.join(dirpath, f))
    return files

SKIP_FILES = {'ScaledText.qml', 'TranslatableText.qml', 'DynamicText.qml',
              'DamageText.qml', 'BloodParticle.qml', 'DebrisParticle.qml',
              'ExplosionParticle.qml', 'i18n.js'}

# 匹配 contentItem: Text { 或 Text { 或 propertyName: Text {
TEXT_OPEN_RE = re.compile(r'^(\s*)((?:\w+\s*:\s*)?)(Text)\s*(\{)\s*$')

# 匹配 font.pixelSize: VALUE 或 font.pointSize: VALUE
FONT_SIZE_RE = re.compile(r'^\s*(.*?)(font\.(?:pixel|point)Size)\s*:\s*([^;\n]+?)\s*$')

# 匹配 contentItem 等属性前缀
CONTENT_ITEM_RE = re.compile(r'^(\s*)(\w+\s*:\s*)(Text)(\s*\{)\s*$')

def parse_font_value(val_str):
    """解析字号值，返回 (base_int, ui_scale_source_or_None)"""
    val = val_str.strip().rstrip(',')
    
    # 纯数字
    m = re.match(r'^(\d+\.?\d*)$', val)
    if m:
        return int(float(m.group(1))), None
    
    # 数字 * scaleFactor (各种前缀)
    m = re.match(r'^(\d+\.?\d*)\s*\*\s*([\w.]+)scaleFactor$', val)
    if m:
        num = int(float(m.group(1)))
        prefix = m.group(2)
        if prefix:
            return num, f'{prefix}scaleFactor'
        return num, 'scaleFactor'
    
    # 数字 * XXX.scaleFactor (带任意前缀)
    m = re.match(r'^(\d+\.?\d*)\s*\*\s*(\w+(?:\.\w+)*)$', val)
    if m and 'scaleFactor' in m.group(2):
        return int(float(m.group(1))), m.group(2)
    
    # Math.floor(XXX) 或类似复杂表达式 — 跳过
    return None, None

def needs_text_type_replacement(line):
    """检查是否在 Text 定义行"""
    return bool(TEXT_OPEN_RE.match(line))

def replace_font_size_line(line):
    """处理包含 font.pixelSize 的行，返回 (替换后的行, 是否修改)"""
    m = FONT_SIZE_RE.match(line)
    if not m:
        return line, False
    
    prefix = m.group(1)  # 行前空格后的内容
    indent = line[:len(line) - len(line.lstrip())]
    val_str = m.group(3)
    
    base_val, ui_source = parse_font_value(val_str)
    if base_val is None:
        return line, False
    
    new_lines = [f'{indent}basePixelSize: {base_val}']
    if ui_source:
        new_lines.append(f'{indent}uiScale: {ui_source}')
    
    return '\n'.join(new_lines), True

def replace_text_type_in_line(line):
    """将 Text { 替换为 ScaledText {（处理 Text { 和 contentItem: Text {）"""
    m = TEXT_OPEN_RE.match(line)
    if not m:
        return line, False
    return line.replace('Text {', 'ScaledText {', 1), True

def add_import(content, import_stmt, marker):
    """如果文件还没有该导入，则添加"""
    if marker in content:
        return content, False
    
    lines = content.split('\n')
    last_import = -1
    for i, l in enumerate(lines):
        if l.startswith('import '):
            last_import = i
    
    if last_import >= 0:
        lines.insert(last_import + 1, import_stmt)
        return '\n'.join(lines), True
    return content, False

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    fname = os.path.basename(filepath)
    if fname in SKIP_FILES:
        return content, 0, 0
    
    lines = content.split('\n')
    new_lines = []
    font_changes = 0
    i18n_changes = 0
    
    i = 0
    need_scaledtext_import = False
    need_i18n_import = False
    
    while i < len(lines):
        line = lines[i]
        
        # ---- fontSize 处理 ----
        # 检查当前行是否是 Text 定义
        text_open_m = TEXT_OPEN_RE.match(line)
        
        # 检查当前行是否有 font.pixelSize
        font_m = FONT_SIZE_RE.match(line)
        
        if font_m:
            # 更新需要 ScaledText 的标记
            # 但只有当父元素是 Text/ScaledText 时才替换
            # 检查之前的行的 Text 标记
            need_scaledtext_import = True
            
            base_val, ui_source = parse_font_value(font_m.group(3))
            
            if base_val is not None:
                indent = line[:len(line) - len(line.lstrip())]
                prefix_spaces = line[:len(line) - len(line.lstrip())]
                
                # 替换 font.pixelSize 行
                new_lines.append(f'{indent}basePixelSize: {base_val}')
                if ui_source:
                    new_lines.append(f'{indent}uiScale: {ui_source}')
                font_changes += 1
                i += 1
                continue
        
        if text_open_m and font_changes > 0 and need_scaledtext_import:
            # 将 Text { 替换为 ScaledText {
            # 但只替换那些与 font.pixelSize 匹配的块
            # 这里简单处理：文件中只要有 font 替换，就把 Text → ScaledText
            pass  # 第二轮处理
        
        new_lines.append(line)
        i += 1
    
    content2 = '\n'.join(new_lines)
    
    # 第二轮：将 Text { → ScaledText {（只在有 font_changes 的文件中）
    if font_changes > 0:
        # 替换所有 Text { 为 ScaledText {（包括 contentItem: Text {）
        # 但要跳过 qsTr 等特殊情况
        lines2 = content2.split('\n')
        new_lines2 = []
        text_replaced = False
        
        for line in lines2:
            # 跳过字面量 "Text" 在字符串中的情况
            if needs_text_type_replacement(line):
                new_line, changed = replace_text_type_in_line(line)
                if changed:
                    text_replaced = True
                    new_lines2.append(new_line)
                    continue
            new_lines2.append(line)
        
        if text_replaced:
            content2 = '\n'.join(new_lines2)
    
    # ---- i18n 处理 ----
    if fname not in ('i18n.js', 'ScaledText.qml', 'TranslatableText.qml'):
        lines3 = content2.split('\n')
        new_lines3 = []
        file_has_i18n_import = 'i18n.js' in content2 or 'I18n' in content2
        
        for line in lines3:
            new_line = line
            
            # 查找 text: "包含中文" 模式
            # 排除已有翻译的、变量的、显示的
            if re.search(r'text\s*:', line):
                # 跳过已处理的行
                if re.search(r'(qsTr|I18n\.tr|translationKey|displayText|currentText)', line):
                    new_lines3.append(new_line)
                    continue
                # 跳过 text: 变量引用
                if re.search(r'text\s*:\s*[\w.]+\s*$', line):
                    new_lines3.append(new_line)
                    continue
                
                # 在引号内容中找中文
                for q in ['"', "'"]:
                    # 查找 q + 含中文的文本 + q
                    pattern = re.compile(
                        re.escape(q) + r'([^' + re.escape(q) + r']*[\u4e00-\u9fff][^' + re.escape(q) + r']*)' + re.escape(q)
                    )
                    matches = list(pattern.finditer(line))
                    if matches:
                        for m in reversed(matches):
                            chinese_text = m.group(1)
                            # 跳过纯数字或短的符号
                            # 检查该中文是否在 text: 值中
                            old = q + chinese_text + q
                            new_val = 'I18n.tr(' + q + chinese_text + q + ')'
                            # 替换引号内容，确保 text: 附近
                            new_line = new_line[:m.start()] + new_val + new_line[m.end():]
                            i18n_changes += 1
                            need_i18n_import = True
            
            new_lines3.append(new_line)
        
        content2 = '\n'.join(new_lines3)
    
    # ---- 添加导入 ----
    if font_changes > 0:
        # 检查是否已经可以直接使用 ScaledText
        if 'ScaledText' in content2 and 'import "../components"' not in content2:
            content2, _ = add_import(content2, 
                'import "../components"', 'ScaledText')
    
    if i18n_changes > 0 and 'i18n.js' not in content2:
        has_settings = 'singleton.SettingsData' in content2
        content2, _ = add_import(content2,
            'import "../data/i18n.js" as I18n', 'I18n')
        # i18n 需要 SettingsData（用于语言切换监听）
        if not has_settings:
            content2, _ = add_import(content2,
                'import singleton.SettingsData', 'SettingsData')
    
    if content2 != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content2)
        return content2, font_changes, i18n_changes
    
    return content, 0, 0

def main():
    files = find_qml_files(PROJECT_DIR)
    total_font = 0
    total_i18n = 0
    changed = []
    
    # 先处理 components/ 目录，再处理其他
    components = [f for f in files if '/components/' in f]
    others = [f for f in files if '/components/' not in f]
    
    for filepath in components + others:
        rel = os.path.relpath(filepath, PROJECT_DIR)
        try:
            _, fc, ic = process_file(filepath)
            if fc > 0 or ic > 0:
                changed.append((rel, fc, ic))
                total_font += fc
                total_i18n += ic
        except Exception as e:
            print(f"  ❌ {rel}: {e}")
    
    print(f"\n{'='*50}")
    print(f"修改了 {len(changed)} 个文件")
    print(f"  font → ScaledText: {total_font} 处")
    print(f"  text → I18n.tr(): {total_i18n} 处")
    
    if changed:
        print(f"\n详细列表:")
        for rel, fc, ic in sorted(changed):
            parts = []
            if fc: parts.append(f"font={fc}")
            if ic: parts.append(f"i18n={ic}")
            print(f"  ✏️  {rel}: {', '.join(parts)}")

if __name__ == '__main__':
    main()
