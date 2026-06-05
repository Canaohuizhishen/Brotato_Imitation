#!/usr/bin/env python3
"""Fix Text -> ScaledText for blocks containing basePixelSize."""
import os, re

for dirpath, dirnames, fnames in os.walk('.'):
    dirnames[:] = [d for d in dirnames if d not in ('build', '.reasonix', '.git', 'node_modules')]
    for f in fnames:
        if not f.endswith('.qml') or f in ('ScaledText.qml', 'TranslatableText.qml', 'DynamicText.qml', 'DamageText.qml'):
            continue
        fp = os.path.join(dirpath, f)
        with open(fp) as fh:
            content = fh.read()
        
        if 'basePixelSize' not in content:
            continue
        
        lines = content.split('\n')
        changed = False
        new_lines = []
        
        i = 0
        while i < len(lines):
            line = lines[i]
            
            # Check if this line starts a Text or TextEdit block
            m = re.match(r'^(\s*)((?:\w+\s*:\s*)?)(Text|TextEdit)\s*(\{)$', line)
            if m:
                indent = m.group(1)
                prefix = m.group(2)
                brace_count = 1
                has_base = False
                j = i + 1
                while j < len(lines) and brace_count > 0:
                    bc = lines[j].count('{') - lines[j].count('}')
                    brace_count += bc
                    if 'basePixelSize' in lines[j]:
                        has_base = True
                    j += 1
                
                if has_base:
                    new_line = f'{indent}{prefix}ScaledText {{'
                    new_lines.append(new_line)
                    changed = True
                    i += 1
                    continue
            
            new_lines.append(line)
            i += 1
        
        if changed:
            with open(fp, 'w') as fh:
                fh.write('\n'.join(new_lines))
            print(f"Fixed: {fp}")

if not changed:
    print("No files needed fixing")
else:
    print("Done")
