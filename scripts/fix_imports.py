#!/usr/bin/env python3
"""Fix missing imports for ScaledText and I18n in all QML files."""
import os

for dirpath, dirnames, fnames in os.walk('.'):
    dirnames[:] = [d for d in dirnames if d not in ('build', '.reasonix', '.git', 'node_modules')]
    for f in fnames:
        if not f.endswith('.qml'):
            continue
        fp = os.path.join(dirpath, f)
        with open(fp, encoding='utf-8') as fh:
            c = fh.read()
        
        if f == 'ScaledText.qml':
            continue
        
        changed = False
        lines = c.split('\n')
        
        # Find last import line
        last_import = -1
        for i, l in enumerate(lines):
            if l.startswith('import '):
                last_import = i
        
        if last_import < 0:
            continue
        
        # Need components import for ScaledText?
        has_sc = 'ScaledText' in c
        has_comp_imp = 'import "../components"' in c or 'import"../components"' in c
        in_components = '/components/' in fp.replace('\\', '/')
        
        if has_sc and not has_comp_imp and not in_components:
            lines.insert(last_import + 1, 'import "../components"')
            last_import += 1
            changed = True
            print(f"  +components: {fp}")
        
        # Need i18n import?
        has_i18n = 'I18n.tr' in c
        has_i18n_imp = 'i18n.js' in c
        
        if has_i18n and not has_i18n_imp:
            lines.insert(last_import + 1, 'import "../data/i18n.js" as I18n')
            last_import += 1
            changed = True
            print(f"  +i18n: {fp}")
        
        if changed:
            with open(fp, 'w', encoding='utf-8') as fh:
                fh.write('\n'.join(lines))

print("Done")
