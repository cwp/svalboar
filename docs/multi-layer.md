# Multi-Layer Support

The optimizer supports complex multi-layer layouts with various modifier types for accessing different symbol layers.

## Layer Architecture

### Layer Structure
Each key can have multiple symbols across layers:
```yaml
keys:
  - [["a", "A", "{", "⇣", "α", "∀"]]  # 6 layers for 'a' key
```

**Standard Layers:**
- **Layer 0**: Base lowercase letters
- **Layer 1**: Uppercase (Shift)
- **Layer 2**: Symbols/punctuation
- **Layer 3**: Navigation/numbers
- **Layer 4**: Greek letters
- **Layer 5**: Mathematical symbols

### Layer Definition
```yaml
base_layout:
  keys:
    - [["u", "U", "\\", "⇱", "", "⊂"],     # Layer progression
      ["i", "I", "/", "⇠", "ι", "∫"],
      ["a", "A", "{",  "⇣", "α", "∀"]]
```

## Modifier Types

### Three Modifier Behaviors
```yaml
pub enum LayerModifierType {
    Hold,        # Must hold key down
    OneShot,     # Tap once, affects next key
    LongPress,   # Hold for extended duration
}
```

### Modifier Configuration
```yaml
modifiers:
  - Left:                    # Layer 1 (Shift)
      type: hold
      value: [[0,3]]         # Matrix position [row, col]
    Right:
      type: hold
      value: [[18,3]]
  - Left:                    # Layer 2 (Symbols)
      type: one_shot         # Sticky modifier
      value: [[1,3]]
    Right:
      type: one_shot
      value: [[17,3]]
```

## Modifier Locations

### Position-Based (Fixed)
```yaml
modifiers:
  - Left:
      type: hold
      value: [[2,4]]         # Always at row 2, column 4
```

### Symbol-Based (Mobile)
```yaml
modifiers:
  - Left:
      type: hold
      value: ['a']           # Follows 'a' during optimization
```

## Complex Modifiers

### Multi-Key Combinations
```yaml
modifiers:
  - Left:                    # Layer 4 (Greek)
      type: hold
      value: [[0,3], [1,3]]  # Shift + Mod4
    Right:
      type: hold
      value: [[18,3], [16,4]]
```

### Home Row Modifiers
```yaml
modifiers:
  - Left:
      type: hold
      value: ['a', 's']      # 'a' and 's' as modifiers when held
    Right:
      type: hold
      value: [';', 'l']
```

## Layer Control

### Fixed Layers
```yaml
fixed_layers: [2, 3]       # Don't optimize layers 2 and 3
```

### Grouped Optimization
```yaml
grouped_layers: 2          # Optimize 2 layers together as unit
```

## Evaluation Integration

### Modifier Usage Costs
```yaml
modifier_usage:
  enabled: true
  weight: 100.0
  params:
    hold_cost: 1.0          # Cost for hold modifiers
    one_shot_cost: 0.0      # Cost for one-shot modifiers
    long_press_cost: 1.0    # Cost for long-press modifiers
```

### N-gram Splitting
```yaml
split_modifiers:
  enabled: true
  same_key_mod_factor: 0.03125  # Weight when same key needs 2 modifiers
```

When enabled, typing 'A' becomes sequence: `[shift] -> [a]`

### Modifier-Aware Metrics
```yaml
oxey_sfbs:
  params:
    exclude_modifiers: false  # Include modifiers in same-finger analysis
```

## Sval Multi-Layer Example

### Current Configuration
```yaml
# Single layer only
grouped_layers: 1
modifiers:
  - Left: {type: hold, value: []}
    Right: {type: hold, value: []}
```

### Multi-Layer Enhancement
```yaml
modifiers:
  - Left:                    # Layer 1 (Shift)
      type: hold
      value: [[2,4]]         # Left thumb
    Right:
      type: hold
      value: [[20,4]]        # Right thumb
  - Left:                    # Layer 2 (Symbols)
      type: one_shot
      value: [[3,4]]         # Sticky layer
    Right:
      type: one_shot
      value: [[21,4]]
  - Left:                    # Layer 3 (Navigation)
      type: long_press
      value: [[4,4]]
    Right:
      type: long_press
      value: [[22,4]]
```

## Common Patterns

### Neo-Style Layers
- **Layer 1**: Shift (uppercase)
- **Layer 2**: Dead keys and symbols
- **Layer 3**: Navigation and numbers
- **Layer 4**: Greek letters (Shift + Layer 3)
- **Layer 5**: Mathematical symbols (Layer 2 + Layer 3)

### Programmer Layers
- **Layer 1**: Shift (uppercase)
- **Layer 2**: Programming symbols (){};
- **Layer 3**: Numbers and F-keys
- **Layer 4**: Extended symbols and Unicode

### Minimalist Layers
- **Layer 1**: Shift only
- **Layer 2**: All symbols via single modifier

## Performance Considerations

- **Layer complexity** increases evaluation time
- **Modifier splitting** creates more n-gram combinations
- **Fixed layers** speed up optimization
- **Home row mods** require careful tuning to avoid conflicts

## Migration Guide

### Adding Layers to Existing Layout
1. Extend `keys` arrays with additional layer symbols
2. Define appropriate modifiers in `modifiers` section
3. Adjust `grouped_layers` if optimizing multiple layers
4. Enable `split_modifiers` for realistic evaluation
5. Tune modifier costs in evaluation config