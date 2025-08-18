# N-gram Data

N-grams are sequences of characters that drive layout evaluation by providing realistic typing frequency data.

> **Note:** The ngram directory structure has been reorganized by language. If upgrading from an older version, update your paths from `ngrams/eng_wiki_1m` to `ngrams/eng/eng_wiki_1m`, etc.

## Data Sources

### Included Corpora
```
ngrams/
├── eng/                     # English language datasets
│   ├── eng_news_typical_1m/ # English news (2016)
│   ├── eng_web_1m/          # English web content (2018)
│   ├── eng_wiki_1m/         # English Wikipedia (2016)
│   ├── eng_shai/            # Shai's English dataset
│   ├── oxey_english/        # Oxey's English dataset
│   └── oxey_english2/       # Oxey's English dataset v2
├── deu/                     # German language datasets
│   ├── deu_mixed_1m/        # German mixed corpus (2011)
│   ├── deu_web_1m/          # German web content (2019)
│   ├── arne/                # Arne's German dataset
│   ├── arne_basis/          # Arne's basis German dataset
│   ├── arne_no_special/     # Arne's German without special chars
│   ├── irc_neo/             # IRC Neo German dataset
│   └── oxey_german/         # Oxey's German dataset
└── src/                     # Source scripts and utilities
```

### Blended Collections
- `deu_mixed_wiki_web_0.6_eng_news_typical_wiki_web_0.4` - 60% German, 40% English
- `deu_wiki_0.6_eng_wiki_0.4` - Wikipedia blend
- `deu_web_0.6_eng_web_0.4` - Web content blend

## File Format

Each corpus contains three files:

### 1-grams.txt (Character Frequencies)
```
5646613  
3376547 e
2202983 t
2120620 a
```
Format: `FREQUENCY CHAR`

### 2-grams.txt (Character Pairs)
```
1007680 e 
724090 . 
653551 s 
582519 he
```
Format: `FREQUENCY CHAR1CHAR2`

### 3-grams.txt (Character Triplets)
```
363391  th
362854 he 
298977 the
201838 ed 
```
Format: `FREQUENCY CHAR1CHAR2CHAR3`

## Data Types

### Absolute Frequencies
Traditional format with raw occurrence counts:
```
1007680 e 
724090 . 
```

### Normalized Probabilities
Oxey format with decimal probabilities:
```
0.031546577270869125 th
0.02593952528282628 he
```

## Usage in Evaluation

### Loading Methods
**Pre-computed files (default):**
```bash
--ngrams ngrams/eng/eng_wiki_1m
```

**Raw text corpus:**
```bash
--corpus my-text-file.txt
```

**Direct text input:**
```bash
--text "sample text to analyze"
```

### Character Filtering
```bash
--exclude-chars " \n\t"     # Exclude whitespace
--exclude-chars ""          # Include everything
```

## Generating N-grams

### From Text File
```bash
cargo run --bin ngrams input.txt output_directory/
```

### Merging Corpora
```bash
cargo run --bin ngram_merge output_dir/ \
  corpus1/:0.6 \
  corpus2/:0.4
```

## Processing Scripts

### Clean Leipzig Corpora
```bash
python scripts/ngrams/clean_uni_leipzig_corpora.py input.txt output.txt
```
- Removes line numbers
- Converts 4/5 line breaks to spaces

### Normalize Frequencies
```bash
python scripts/ngrams/normalize.py ngrams_directory/
```
- Converts absolute counts to percentages

### Parse Oxey JSON
```bash
python ngrams/parse_oxey_json.py data.json output_directory/
```

## Advanced Processing

### Common N-gram Boosting
```yaml
increase_common_ngrams:
  enabled: true
  critical_fraction: 0.001    # Boost if relative weight > 0.1%
  factor: 2.0                 # 2× weight multiplier
  total_weight_threshold: 20.0
```

### Modifier Splitting
```yaml
split_modifiers:
  enabled: true
  same_key_mod_factor: 0.03125  # Weight for mod+mod combinations
```

When enabled, uppercase 'A' becomes: `[shift_key] -> [a_key]`

## Performance Notes

- **Caching**: Evaluation results cached for speed
- **Memory**: Large corpora (100MB+) load quickly
- **Filtering**: Character exclusion happens at load time
- **Preprocessing**: N-grams processed once per evaluation session

## Custom Corpora

### Create Domain-Specific Data
1. Collect representative text (programming, prose, chat, etc.)
2. Generate n-grams: `cargo run --bin ngrams text.txt output/`
3. Use: `--ngrams output/`

### Quality Guidelines
- **Size**: 1M+ characters for stability
- **Representativeness**: Match your actual typing
- **Language**: Mix languages proportionally to usage
- **Cleaning**: Remove artifacts, consistent encoding