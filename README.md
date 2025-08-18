# Svalboar

A keyboard layout optimizer forked from [marcusbuffett/keyboard_layout_optimizer](https://github.com/marcusbuffett/keyboard_layout_optimizer) which was in turn forked from [dariogoetz/keyboard_layout_optimizer](https://github.com/dariogoetz/keyboard_layout_optimizer), renamed and further focussed on Svalboard support.

## Features

- **Layout Evaluation**: Analyze typing efficiency using various metrics (finger balance, bigrams, trigrams, etc.)
- **Layout Optimization**: Generate optimal layouts using genetic algorithms or simulated annealing
- **Multi-language Support**: Includes English and German n-gram datasets organized by language
- **Modern Keyboards**: Built-in support for Svalboard
- **Web Interface**: Browser-based evaluation and optimization tools
- **Flexible Configuration**: Customizable keyboards, metrics, and optimization parameters

## Quick Start

### Installation

```bash
# Clone the repository
git clone <your-repo-url>
cd svalboar

# Enter development environment (requires Nix)
nix develop

# Or install Rust manually and build
cargo build --release
```

### Evaluating a Layout

```bash
# Evaluate a QWERTY layout on Svalboard
cargo run --bin evaluate -- \
  --layout-config config/keyboard/sval.yml \
  --ngrams ngrams/eng/eng_wiki_1m \
  --exclude-chars " 0123456789=(){}[]" \
  "q0a1z w2sbx e3dtc r4fgv uhj5m iyk67 onl89 p={}(["
```

### Optimizing a Layout

```bash
# Generate an optimized layout
cargo run --bin optimize_genetic -- \
  --layout-config config/keyboard/sval.yml \
  --ngrams ngrams/eng/eng_wiki_1m \
  --exclude-chars " 0123456789=(){}[]" \
  "q0a1z w2sbx e3dtc r4fgv uhj5m iyk67 onl89 p={}(["
```

## Usage Notes

- **Layout strings**: Specify keys from left to right, top to bottom
- **Non-alpha keys**: Use placeholder characters `0123456789=(){}[]` for spaces that don't contain letters
- **Live reload**: Use `cargo watch -x 'run --bin evaluate -- ...'` for continuous evaluation during development

## Configuration

The optimizer is highly configurable through YAML files:

- **Keyboards**: `config/keyboard/` - Physical layout definitions (key positions, finger assignments, costs)
- **Evaluation**: `config/evaluation/default.yml` - Metric weights and parameters
- **Optimization**: `config/optimization/default.yml` - Algorithm parameters

### Customization for Personal Use

Key areas you may want to adjust:

1. **Key costs** in your keyboard config - reflects your personal finger strength and preferences
2. **Finger repeat penalties** in `layout_evaluation/src/metrics/bigram_metrics/finger_repeats.rs`
3. **Scissoring sensitivity** in `layout_evaluation/src/metrics/bigram_metrics/scissoring.rs`
4. **Movement patterns** in `layout_evaluation/src/metrics/bigram_metrics/movement_pattern.rs`

## Available Data

N-gram datasets are organized by language in `ngrams/`:

- **English**: `eng/eng_wiki_1m/`, `eng/eng_web_1m/`, `eng/oxey_english/`, etc.
- **German**: `deu/deu_wiki_1m/`, `deu/arne/`, `deu/oxey_german/`, etc.

## Binaries

- `evaluate` - Analyze existing layouts
- `optimize_genetic` - Generate layouts using genetic algorithms
- `optimize_sa` - Generate layouts using simulated annealing
- `plot` - Visualize keyboard layouts
- `ngrams` - Generate n-gram data from text corpora

## Web Interface

A web-based interface is available in `webui/` for interactive layout evaluation and optimization.

## Documentation

Detailed documentation is available in the `docs/` directory:

- Architecture overview
- CLI usage guide
- Configuration reference
- N-gram data sources
- Adding custom metrics

## License

GPL-3.0-or-later

## Contributing

This project builds on the excellent foundation of the original keyboard layout optimizer. Contributions are welcome, particularly for:

- New keyboard definitions
- Additional language datasets
- Metric improvements
- Web interface enhancements
