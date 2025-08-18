# Configuration

The optimizer uses YAML configuration files to define keyboards, evaluation parameters, and optimization settings.

## Configuration Types

### Keyboard Configuration (`config/keyboard/`)
Defines physical keyboard layout, key positions, costs, and modifiers.

### Evaluation Configuration (`config/evaluation/`)
Sets metric weights, parameters, and normalization methods.

### Optimization Configuration (`config/optimization/`)
Tunes algorithm parameters for genetic and simulated annealing optimizers.

## Keyboard Configuration

### Basic Structure
```yaml
keyboard:
  matrix_positions: []    # Physical key coordinates
  positions: []           # Visual plotting coordinates  
  hands: []              # Left/Right hand assignment
  fingers: []            # Finger assignment per key
  key_costs: []          # Difficulty cost per key
  unbalancing_positions: [] # Stretch penalties
  symmetries: []         # Mirror mapping for optimization
  
base_layout:
  keys: []              # Multi-layer symbol definitions
  fixed_keys: []        # Optimization exclusions
  modifiers: []         # Layer access configuration
```

### Key Properties

**Matrix Positions**
```yaml
matrix_positions:
  - [[2,1], [3,1], [4,1]]  # [column, row] coordinates
```

**Key Costs**
```yaml
key_costs:
  - [5, 3, 2, 3, 5]       # Higher = more difficult
```

**Hand/Finger Assignment**
```yaml
hands: [Left, Left, Right, Right]
fingers: [Pinky, Ring, Ring, Pinky]
```

### Sval Example
```yaml
keyboard:
  matrix_positions:
    # 5-key clusters per finger: [N, W, C, E, S]
    - [[2,1], [1,2], [2,2], [3,2], [2,3]]  # Left pinky
  
  key_costs:
    # N  W  C  E  S
    - [5, 6, 3, 5, 3]  # Center/South cheapest
```

### Multi-Layer Support
```yaml
base_layout:
  keys:
    - [["a", "A", "{", "⇣", "α", "∀"]]  # 6 layers per key
  
  modifiers:
    - Left: {type: hold, value: [[0,3]]}   # Shift
      Right: {type: hold, value: [[18,3]]}
    - Left: {type: one_shot, value: [[1,3]]}  # Symbol layer
```

## Evaluation Configuration

### Metric Structure
```yaml
metrics:
  metric_name:
    enabled: true/false
    weight: 100.0           # Relative importance
    normalization:
      type: weight_found    # weight_found/weight_all/fixed
      value: 1.0           # Fixed normalization value
    params:
      # Metric-specific parameters
```

### Common Metrics
```yaml
finger_repeats:
  enabled: true
  weight: 1500.0
  params:
    finger_factors:
      Index: 0.8            # Easier fingers
      Pinky: 1.4           # Harder fingers
    stretch_factor: 0.75
    curl_factor: 0.1

key_costs:
  enabled: true
  weight: 60.0
  normalization:
    type: weight_found

hand_disbalance:
  enabled: true
  weight: 100.0
  normalization:
    type: fixed
    value: 1.0
```

### Normalization Types
- **weight_found**: Scale by n-gram weight actually found in corpus
- **weight_all**: Scale by total possible n-gram weight
- **fixed**: Use fixed normalization value

### N-gram Processing
```yaml
ngrams:
  increase_common_ngrams:
    enabled: false
    critical_fraction: 0.001  # Boost threshold
    factor: 2.0              # Weight multiplier

ngram_mapper:
  exclude_line_breaks: true
  split_modifiers:
    enabled: false
    same_key_mod_factor: 0.03125
```

## Optimization Configuration

### Genetic Algorithm
```yaml
# config/optimization/genetic.yml
population_size: 2000
generation_limit: 5000
num_individuals_per_parents: 2
selection_ratio: 0.3
mutation_rate: 0.01
reinsertion_ratio: 0.5
```

### Simulated Annealing
```yaml
# config/optimization/sa.yml
max_iter: 1000000
init_temp: 1.0
cooling_rate: 0.999
final_temp: 0.001
reheat_threshold: 100
```

## Command Line Options

### General Parameters
```bash
--layout-config config/keyboard/sval.yml
--eval-parameters config/evaluation/default.yml
--ngrams ngrams/eng/eng_wiki_1m
--exclude-chars " 0123456789"
```

### Optimization-Specific
```bash
--optimization-parameters config/optimization/genetic.yml
--generation-limit 1000
--start-layout "initial-layout-string"
--fix "characters-to-keep-fixed"
```

### Publishing Options
```bash
--publish-as "username"
--publish-if-cost-below 300.0
--publish-layout-config "standard"
--publish-to "https://api-url.com"
```

## Configuration Templates

### Minimal Sval Config
```yaml
keyboard:
  matrix_positions: [[...]]  # Define 48 positions
  key_costs: [[...]]         # Set difficulty costs
  hands: [...]              # Left/Right assignment
  fingers: [...]            # Finger assignment

base_layout:
  keys: [[["a"], ["b"], ...]]  # Single layer
  fixed_keys: [false, ...]     # All optimizable
  grouped_layers: 1
  modifiers: [{Left: {type: hold, value: []}}]
```

### Multi-Layer Config
```yaml
base_layout:
  keys:
    # Multiple symbols per key
    - [["a", "A", "{", "α"]]
  
  modifiers:
    - Left: {type: hold, value: [[2,4]]}     # Layer 1
    - Left: {type: one_shot, value: [[3,4]]} # Layer 2  
    - Left: {type: long_press, value: [[4,4]]} # Layer 3
  
  fixed_layers: [2]        # Don't optimize layer 2
  grouped_layers: 2        # Optimize layers 0+1 together
```

### Custom Evaluation
```yaml
metrics:
  # Disable unwanted metrics
  symmetric_handswitches:
    enabled: false
    
  # Tune important metrics  
  finger_repeats:
    enabled: true
    weight: 2000.0         # Increase penalty
    
  # Add custom costs
  manual_bigram_penalty:
    enabled: true
    params:
      matrix_positions:
        [[2,1], [3,3]]: 1.0  # Penalize specific combinations
```

## Best Practices

### Keyboard Configuration
1. **Measure accurately** - Use precise key coordinates
2. **Test thoroughly** - Verify finger assignments match reality  
3. **Tune costs** - Adjust based on personal comfort
4. **Document changes** - Comment non-obvious decisions

### Evaluation Tuning
1. **Start simple** - Enable core metrics first
2. **Gradual adjustment** - Change one parameter at a time
3. **Validate results** - Test layouts on actual hardware
4. **Backup configs** - Save working configurations

### Optimization Settings
1. **Balance time/quality** - More generations = better results
2. **Population size** - Larger for complex layouts
3. **Multiple runs** - Genetic algorithms are stochastic
4. **Incremental improvement** - Start from good existing layouts