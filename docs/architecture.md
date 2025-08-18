# Architecture

## Project Structure

```
svalboar/
├── keyboard_layout/           # Core layout and keyboard representations
├── layout_evaluation/         # Metrics and scoring system
├── layout_optimization/       # Genetic algorithm and simulated annealing
├── svalboar/                  # CLI binaries and common utilities
├── webui/                     # Web interface (WASM + React service)
├── config/                    # Keyboard and evaluation configurations
├── ngrams/                    # Text frequency data
└── scripts/                   # Utility scripts
```

## Core Components

### Keyboard Layout (`keyboard_layout/`)
- **`Layout`** - Maps characters to keys and layers
- **`Keyboard`** - Physical key positions and properties
- **`LayoutGenerator`** - Creates layouts from strings
- **`Key`** - Individual key with position, cost, finger assignment

### Layout Evaluation (`layout_evaluation/`)
- **`Evaluator`** - Combines all metrics into total score
- **`Metrics`** - Unigram, bigram, trigram analysis
- **`NgramMapper`** - Maps text sequences to key sequences
- **`Cache`** - Performance optimization for repeated evaluations

### Layout Optimization (`layout_optimization/`)
- **Genetic Algorithm** - Population-based evolution
- **Simulated Annealing** - Temperature-based hill climbing
- **Common** - Shared optimization utilities

## CLI Binaries

| Binary | Purpose |
|--------|---------|
| `evaluate` | Score single/multiple layouts |
| `optimize_genetic` | Find optimal layouts via GA |
| `optimize_sa` | Find optimal layouts via SA |
| `ngrams` | Generate n-gram data from text |
| `ngram_merge` | Combine multiple corpora |
| `analyze_layout` | Detailed layout analysis |

## Data Flow

1. **Text Corpus** → N-gram frequencies (`ngrams/`)
2. **Keyboard Config** → Physical layout (`config/keyboard/`)
3. **Layout String** → `LayoutGenerator` → `Layout` object
4. **Layout** + **N-grams** → `Evaluator` → Score
5. **Optimizer** → Iteratively improve layout → Best result

## Web Interface

### WASM App (`webui/layout_evaluation_wasm/`)
- Rust → WebAssembly compilation
- Vue.js frontend with Bootstrap UI
- Real-time evaluation and optimization
- Web Workers for non-blocking computation

### Layout Service (`webui/layouts_webservice/`)
- Rocket-based REST API
- PostgreSQL database
- Community layout sharing
- Admin curation features

## Configuration System

- **YAML-based** configuration files
- **Keyboard configs** define physical layout
- **Evaluation configs** set metric weights
- **Optimization configs** tune algorithm parameters
- **Modular** - mix and match configurations