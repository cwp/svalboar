# Keyboard Layout Optimizer Documentation

A Rust-based keyboard layout evaluator and optimizer, forked to support the [Svalboard](https://svalboard.com).

## Quick Start

**Evaluate a layout:**
```bash
cargo run --bin evaluate -- --layout-config config/keyboard/sval.yml --exclude-chars " 0123456789=(){}[]" "q0a1z w2sbx e3dtc r4fgv uhj5m iyk67 onl89 p={}(["
```

**Optimize a layout:**
```bash
cargo run --bin optimize_genetic -- --layout-config config/keyboard/sval.yml --exclude-chars " 0123456789=(){}[]" "q0a1z w2sbx e3dtc r4fgv uhj5m iyk67 onl89 p={}(["
```

## Documentation

- **[Architecture](architecture.md)** - Project structure and major components
- **[Svalboard](sval-keyboard.md)** - Svalboard-specific configuration and features
- **[Evaluation Metrics](evaluation-metrics.md)** - How layouts are scored
- **[N-gram Data](ngram-data.md)** - Corpus management and text analysis
- **[Multi-layer Support](multi-layer.md)** - Layer navigation and modifier keys
- **[Character Support](character-support.md)** - Non-alphabetic characters and symbols
- **[Web Interface](web-interface.md)** - Browser-based evaluation and optimization
- **[Community Layouts](community-layouts.md)** - Shared layout database
- **[Configuration](configuration.md)** - Keyboard and evaluation settings
- **[CLI Usage](cli-usage.md)** - Command-line tools and options

## Key Features

- **Svalboard support** - 5-key directional clusters per finger
- **Multi-layer layouts** - Hold/OneShot/LongPress modifiers
- **Comprehensive metrics** - Finger repeats, movement patterns, balance
- **Multiple algorithms** - Genetic algorithm and simulated annealing
- **Web interface** - WASM-based browser evaluation
- **Community database** - Shared layout repository
- **Full Unicode support** - Any character including punctuation/symbols
- **Multiple keyboards** - Standard, ortho, split, ergonomic boards

## Live Resources

- **Web App**: https://dariogoetz.github.io/keyboard_layout_optimizer
- **Layout Database**: https://keyboard-layout-optimizer.fly.dev
- **Original Project**: https://github.com/dariogoetz/keyboard_layout_optimizer
