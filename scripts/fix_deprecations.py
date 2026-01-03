import re
from pathlib import Path

root = Path(__file__).resolve().parents[1]
exclude = root / 'lib' / 'merge_conflicts'

dart_files = [p for p in root.rglob('*.dart') if not str(p).startswith(str(exclude))]

withOpacity_re = re.compile(r"\.withOpacity\(([^)]+)\)")
colorScheme_bg_re = re.compile(r"(?<=colorScheme\.)background\b")
ColorScheme_bg_re = re.compile(r"(?<=ColorScheme\.)background\b")
background_named_re = re.compile(r"\bbackground\s*:")
print_re = re.compile(r"\bprint\(")

changed_files = []
for f in dart_files:
    text = f.read_text(encoding='utf-8')
    new = text
    new = withOpacity_re.sub(r'.withAlpha((\1 * 255).round())', new)
    new = colorScheme_bg_re.sub('surface', new)
    new = ColorScheme_bg_re.sub('surface', new)
    # Replace named parameter background: -> surface:
    new = background_named_re.sub('surface:', new)
    new = print_re.sub('debugPrint(', new)
    if new != text:
        f.write_text(new, encoding='utf-8')
        changed_files.append(str(f.relative_to(root)))

print(f"Modified {len(changed_files)} files:")
for p in changed_files:
    print(p)
