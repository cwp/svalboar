# Character Support

The optimizer supports **any Unicode character** including letters, punctuation, numerals, and symbols.

## Character Types

### Alphabetic Characters
```yaml
base_layout:
  keys:
    - [["a"], ["b"], ["c"], ["d"], ["e"]]  # Standard letters
    - [["ä"], ["ö"], ["ü"], ["ß"]]        # Diacritics
    - [["α"], ["β"], ["γ"], ["δ"]]        # Greek letters
```

### Punctuation & Symbols
```yaml
base_layout:
  keys:
    - [[".", ",", ";", ":", "!", "?"]]     # Punctuation
    - [["@", "#", "$", "%", "^", "&"]]     # Symbols
    - [["(", ")", "[", "]", "{", "}"]]     # Brackets
    - [["+", "-", "*", "/", "=", "\\"]]    # Math/operators
```

### Numerals
```yaml
base_layout:
  keys:
    - [["0"], ["1"], ["2"], ["3"], ["4"]]  # Digits
    - [["5"], ["6"], ["7"], ["8"], ["9"]]
```

### Special Characters
```yaml
base_layout:
  keys:
    - [[" "], ["\n"], ["\t"]]              # Whitespace
    - [["€"], ["£"], ["¥"], ["¢"]]         # Currency
    - [["©"], ["®"], ["™"], ["°"]]         # Special symbols
```

## Current Sval Configuration

### Defined Characters
```yaml
base_layout:
  keys:
    # Alphabetic positions
    - [["a"], ["b"], ["c"], ["d"], ["e"]]
    # Symbol positions  
    - [["0"], ["1"], ["2"], ["3"], ["4"]]
    - [["="], ["{"], ["}"], ["("], ["["]]
    # Space and placeholders
    - [[" "], [""], [""], [""]]
```

### Placeholder System
The Sval uses placeholders for non-alpha positions:
```bash
"q0a1z w2sbx e3dtc r4fgv uhj5m iyk67 onl89 p={}(["
```

**Placeholders**: `0123456789=(){}[]`
**Usage**: Fill extra positions that don't use alphabetic characters

## Character Filtering

### Include/Exclude Characters
```bash
# Exclude whitespace and numbers
--exclude-chars " 0123456789"

# Exclude only line breaks
--exclude-chars "\n"

# Include everything
--exclude-chars ""
```

### Metric-Level Filtering
```yaml
oxey_sfbs:
  params:
    exclude_chars: ["\n"]      # Exclude line breaks from this metric

finger_repeats:
  params:
    exclude_chars: []          # Include all characters
```

## N-gram Data Coverage

### Included in Standard Corpora
- **Letters**: All Latin alphabet + diacritics
- **Punctuation**: `.`, `,`, `;`, `:`, `!`, `?`, `"`, `'`
- **Whitespace**: Space, line breaks, tabs
- **Basic symbols**: `-`, `(`, `)`, `&`, `@`

### Example N-gram Entries
```
# 1-grams.txt
5646613  
3376547 e
946594 .
200000 \n

# 2-grams.txt  
724090 . 
177457 .\n
582519 he
426424 er
```

## Adding New Characters

### Modify Base Layout
```yaml
base_layout:
  keys:
    # Replace placeholder with real symbol
    - [["q"], ["!"], ["a"], ["@"], ["z"]]  # Instead of q0a1z
```

### Update Corpus Data
For custom symbols, generate n-grams from representative text:
```bash
cargo run --bin ngrams custom-text.txt output-ngrams/
```

### Character Frequency Priority
Most important characters to include (by frequency):
1. **Space** (most frequent)
2. **Common letters**: e, t, a, o, i, n, s, h, r
3. **Sentence endings**: `.`, `!`, `?`
4. **Common punctuation**: `,`, `;`, `:`
5. **Programming symbols**: `()`, `{}`, `[]`, `=`, `+`, `-`

## Unicode Support

### Full Unicode Range
The system handles any valid Unicode character:
```yaml
base_layout:
  keys:
    - [["😀"], ["🚀"], ["⚡"], ["🔥"]]      # Emoji
    - [["中"], ["文"], ["字"], ["符"]]       # Chinese
    - [["Ω"], ["∞"], ["∑"], ["∫"]]         # Mathematical
```

### Encoding Considerations
- **File encoding**: Use UTF-8 for all config files
- **Terminal support**: Ensure terminal displays Unicode correctly
- **Font support**: Verify fonts contain required glyphs

## Common Configurations

### Programming-Focused
```yaml
base_layout:
  keys:
    # High-frequency programming symbols
    - [["("], [")"], ["{"], ["}"], ["["], ["]"]]
    - [["="], ["+"], ["-"], ["*"], ["/"], ["\\"]]
    - [[";"], [":"], [".", ","], ["<"], [">"]]
    - [["&"], ["|"], ["^"], ["~"], ["`"], ["'"]]
```

### Writing-Focused  
```yaml
base_layout:
  keys:
    # Natural language punctuation
    - [[".", ","], ["!", "?"], [";", ":"]]
    - [["'"], ['"'], ["-"], ["—"]]
    - [["("], [")"], ["["], ["]"]]
```

### Multilingual
```yaml
base_layout:
  keys:
    # German diacritics
    - [["ä"], ["ö"], ["ü"], ["ß"]]
    # French diacritics  
    - [["é"], ["è"], ["ê"], ["ë"], ["ç"]]
    # Spanish diacritics
    - [["ñ"], ["á"], ["í"], ["ó"], ["ú"]]
```

## Best Practices

### Character Selection
1. **Frequency-based**: Include characters you actually type
2. **Corpus alignment**: Match n-gram data to layout characters
3. **Layer distribution**: Put rare symbols on higher layers
4. **Accessibility**: Keep common punctuation easily reachable

### Performance Tips
- **Exclude unused**: Use `--exclude-chars` for irrelevant symbols
- **Layer optimization**: Don't optimize layers you won't change
- **Corpus matching**: Generate custom n-grams for specialized needs

### Layout String Format
- **Placeholders**: Use consistent placeholder characters
- **Order**: Match physical keyboard position order
- **Whitespace**: Remove spaces unless using `--do-not-remove-whitespace`
