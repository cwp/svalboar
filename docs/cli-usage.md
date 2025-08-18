# CLI Usage

Command-line tools for evaluating and optimizing keyboard layouts.

## Core Binaries

### evaluate
Score single or multiple layouts against evaluation metrics.

```bash
cargo run --bin evaluate -- [OPTIONS] <LAYOUT_STRINGS>...
```

**Basic usage:**
```bash
cargo run --bin evaluate -- \
  --layout-config config/keyboard/sval.yml \
  "q0a1z w2sbx e3dtc r4fgv uhj5m iyk67 onl89 p={}(["
```

**Multiple layouts:**
```bash
cargo run --bin evaluate -- \
  --layout-config config/keyboard/standard.yml \
  "qwertzuiopü..." "xvlcwkhgfqy..." "jduaxphlmwq..."
```

**Options:**
- `--layout-config FILE` - Keyboard configuration
- `--eval-parameters FILE` - Evaluation metrics config
- `--ngrams DIR` - N-gram frequency data directory
- `--exclude-chars CHARS` - Characters to ignore in evaluation
- `--json` - Output results as JSON
- `--only-total-costs` - Show scores only
- `--sort` - Sort results by score
- `--from-file FILE` - Read layouts from file

### optimize_genetic
Find optimal layouts using genetic algorithm.

```bash
cargo run --bin optimize_genetic -- [OPTIONS] <START_LAYOUT>
```

**Basic optimization:**
```bash
cargo run --bin optimize_genetic -- \
  --layout-config config/keyboard/sval.yml \
  --optimization-parameters config/optimization/genetic.yml \
  "q0a1z w2sbx e3dtc r4fgv uhj5m iyk67 onl89 p={}(["
```

**With publishing:**
```bash
cargo run --bin optimize_genetic -- \
  --layout-config config/keyboard/standard.yml \
  --publish-as "myusername" \
  --publish-if-cost-below 300.0 \
  --generation-limit 1000 \
  "starting-layout-string"
```

**Options:**
- `--optimization-parameters FILE` - Algorithm settings
- `--generation-limit NUM` - Maximum generations
- `--start-layout STRING` - Starting layout (overrides positional arg)
- `--fix CHARS` - Characters to keep in place
- `--fix-from STRING` - Layout to take fixed chars from
- `--run-forever` - Continuous optimization
- `--append-solutions-to FILE` - Log results to file
- `--publish-as NAME` - Submit to community database
- `--publish-if-cost-below SCORE` - Only publish if better than threshold

### optimize_sa
Find optimal layouts using simulated annealing.

```bash
cargo run --bin optimize_sa -- [OPTIONS] <START_LAYOUT>
```

**Usage similar to genetic optimizer:**
```bash
cargo run --bin optimize_sa -- \
  --layout-config config/keyboard/sval.yml \
  --optimization-parameters config/optimization/sa.yml \
  "initial-layout"
```

## Utility Binaries

### ngrams
Generate n-gram frequency data from text files.

```bash
cargo run --bin ngrams -- <INPUT_FILE> <OUTPUT_DIR>
```

**Example:**
```bash
cargo run --bin ngrams -- corpus.txt ngrams/my_corpus/
```

Creates:
- `ngrams/my_corpus/1-grams.txt` - Character frequencies
- `ngrams/my_corpus/2-grams.txt` - Bigram frequencies  
- `ngrams/my_corpus/3-grams.txt` - Trigram frequencies

### ngram_merge
Combine multiple corpora with weights.

```bash
cargo run --bin ngram_merge -- <OUTPUT_DIR> <CORPUS1:WEIGHT> <CORPUS2:WEIGHT>...
```

**Example:**
```bash
cargo run --bin ngram_merge -- ngrams/custom_blend/ \
  ngrams/eng/eng_wiki_1m/:0.6 \
  ngrams/deu/deu_wiki_1m/:0.4
```

### analyze_layout
Detailed analysis of layout properties.

```bash
cargo run --bin analyze_layout -- [OPTIONS] <LAYOUT_STRING>
```

### plot
Generate ASCII visualization of layouts.

```bash
cargo run --bin plot -- [OPTIONS] <LAYOUT_STRING>
```

### random_evaluate
Test evaluator performance with random layouts.

```bash
cargo run --bin random_evaluate -- [OPTIONS]
```

## Global Options

Available for all binaries:

### File Paths
- `--layout-config FILE` - Keyboard configuration (default: `config/keyboard/standard.yml`)
- `--eval-parameters FILE` - Evaluation config (default: `config/evaluation/default.yml`)
- `--ngrams DIR` - N-gram data directory (default: `ngrams/eng/eng_wiki_1m`)

### Input Sources
- `--corpus FILE` - Use raw text file instead of n-grams
- `--text STRING` - Use direct text input
- `--exclude-chars CHARS` - Ignore specific characters
- `--tops FRACTION` - Only use top fraction of n-grams

### Processing Options
- `--no-split-modifiers` - Disable modifier splitting
- `--no-increase-common-ngrams` - Disable common n-gram boosting
- `--do-not-remove-whitespace` - Keep spaces in layout strings

## Layout String Format

### Standard Format
Layout strings represent keys from left to right, top to bottom:
```
"qwertzuiopü asdfghjklöä yxcvbnm,.ß"
```

### Sval Format  
Uses placeholders for non-alphabetic positions:
```
"q0a1z w2sbx e3dtc r4fgv uhj5m iyk67 onl89 p={}(["
```

**Placeholders:** `0123456789=(){}[]`

### Multi-Layer Format
For layouts with multiple layers, provide symbols for each optimizable layer:
```
"abcdef... ABCDEF... {}[]();..."  # 3 layers
```

## Examples

### Basic Evaluation
```bash
# Evaluate single Sval layout
cargo run --bin evaluate -- \
  --layout-config config/keyboard/sval.yml \
  --exclude-chars " 0123456789=(){}[]" \
  "v.oui jgyfp klctw nm,ae bdhsr xqzö"

# Compare multiple layouts
cargo run --bin evaluate -- \
  --layout-config config/keyboard/standard.yml \
  --sort --only-total-costs \
  "qwertzuiopü..." "xvlcwkhgfqy..." "jduaxphlmwq..."
```

### Optimization Workflows
```bash
# Quick genetic optimization
cargo run --bin optimize_genetic -- \
  --layout-config config/keyboard/sval.yml \
  --generation-limit 100 \
  "v.oui jgyfp klctw nm,ae bdhsr xqzö"

# Production optimization with publishing
cargo run --bin optimize_genetic -- \
  --layout-config config/keyboard/standard.yml \
  --generation-limit 5000 \
  --publish-as "myusername" \
  --publish-if-cost-below 280.0 \
  --run-forever \
  "xvlcwkhgfqy uiaeosnrtd üöäpzbm,.j"

# Simulated annealing alternative
cargo run --bin optimize_sa -- \
  --layout-config config/keyboard/sval.yml \
  --optimization-parameters config/optimization/sa.yml \
  "starting-layout-here"
```

### Custom Corpus Analysis
```bash
# Generate n-grams from programming text
cargo run --bin ngrams -- code_corpus.txt ngrams/programming/

# Blend programming and prose corpora
cargo run --bin ngram_merge -- ngrams/code_prose_blend/ \
  ngrams/programming/:0.3 \
  ngrams/eng/eng_wiki_1m/:0.7

# Optimize for programming
cargo run --bin optimize_genetic -- \
  --ngrams ngrams/code_prose_blend/ \
  --layout-config config/keyboard/standard.yml \
  "qwertzuiopü..."
```

### Evaluation Tuning
```bash
# Test without modifier splitting
cargo run --bin evaluate -- \
  --no-split-modifiers \
  --layout-config config/keyboard/standard.yml \
  "layout-string"

# Exclude punctuation from analysis
cargo run --bin evaluate -- \
  --exclude-chars ".,;:!?\"'" \
  --layout-config config/keyboard/standard.yml \
  "layout-string"

# Use custom evaluation config
cargo run --bin evaluate -- \
  --eval-parameters config/evaluation/custom.yml \
  --layout-config config/keyboard/sval.yml \
  "layout-string"
```

## Performance Tips

### Speed Optimization
- Use `--no-cache-results` to disable caching if memory constrained
- Reduce `--generation-limit` for faster iterations
- Use `--exclude-chars` to reduce n-gram complexity
- Start with smaller corpus for initial testing

### Quality Optimization  
- Increase `population_size` and `generation_limit` for genetic algorithm
- Use `--run-forever` to continue optimizing indefinitely
- Start from good existing layouts rather than random
- Tune evaluation weights in config files

### Development Workflow
- Use `cargo watch -x 'run --bin evaluate -- ...'` for auto-rebuild
- Save promising results with `--append-solutions-to results.txt`
- Test layouts on actual hardware before publishing
- Use `--json` output for programmatic analysis