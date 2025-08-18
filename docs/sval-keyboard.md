# Sval Keyboard

The Svalboard is a unique keyboard with 5-key directional clusters per finger.

## Key Layout

Each of the 8 fingers (4 per hand) controls a **5-key cluster** arranged in a cross pattern:

```
    North
West Center East
    South
```

### Physical Layout
- **40 main keys** (8 fingers × 5 positions)
- **8 thumb keys** (4 per hand)
- **Total: 48 keys**

### Position Mapping
```yaml
# Left Hand
Pinky:  [N, W, C, E, S]    # North, West, Center, East, South
Ring:   [N, W, C, E, S]
Middle: [N, W, C, E, S]
Index:  [N, W, C, E, S]

# Right Hand (mirrored)
Index:  [N, W, C, E, S]
Middle: [N, W, C, E, S]
Ring:   [N, W, C, E, S]
Pinky:  [N, W, C, E, S]

# Thumbs
Left:   [4 keys]
Right:  [4 keys]
```

## Configuration

### Key Costs (Lower = Better)
```yaml
key_costs:
  # N  W  C  E  S
  - [5, 6, 3, 5, 3,    # Left pinky
     4, 8, 2, 5, 2,    # Left ring
     4, 7, 2, 5, 2,    # Left middle
     4, 5, 2, 4, 2,    # Left index
     4, 4, 2, 5, 2,    # Right index
     4, 5, 2, 7, 2,    # Right middle
     4, 5, 2, 8, 2,    # Right ring
     5, 5, 3, 6, 3]    # Right pinky
  - [2, 3, 2, 2,       # Left thumb cluster
     2, 3, 2, 2]       # Right thumb cluster
```

**Key insights:**
- **Center** positions are cheapest (cost 2-3)
- **South** positions are also cheap (cost 2-3)
- **North** positions are more expensive (cost 4-5)
- **West/East** vary by finger strength

## Sval-Specific Metrics

### Finger Repeats
Evaluates same-finger movements with directional awareness:
- **Center→South rolls**: Nice (low cost)
- **Center→Inward rolls**: Nice-ish
- **Most other rolls**: Bad
- **Inward↔Outward**: Very bad

### Scissoring
Detects problematic **North-South combinations** on different fingers of the same hand.

### Movement Pattern
Measures difficulty of **finger-to-finger transitions** considering:
- Finger length differences
- Row changes
- Lateral stretches
- Unbalancing movements

## Layout String Format

Uses placeholder characters for non-alpha positions:
```bash
"q0a1z w2sbx e3dtc r4fgv uhj5m iyk67 onl89 p={}(["
```

**Placeholders**: `0123456789=(){}[]` represent non-alphabetic positions.

### Multi-Layer Support

Currently configured for **single layer**, but supports full multi-layer:

```yaml
# Current (single layer)
grouped_layers: 1
modifiers:
  - Left: {type: hold, value: []}
    Right: {type: hold, value: []}

# Multi-layer example
modifiers:
  - Left: {type: hold, value: [[2,4]]}     # Left thumb as Shift
    Right: {type: hold, value: [[20,4]]}   # Right thumb as Shift
  - Left: {type: one_shot, value: [[3,4]]} # Sticky symbol layer
    Right: {type: one_shot, value: [[21,4]]}
```

## Usage Examples

**Evaluate Sval layout:**
```bash
cargo run --bin evaluate -- \
  --layout-config config/keyboard/sval.yml \
  --exclude-chars " 0123456789=(){}[]" \
  "real-layout-string-here"
```

**Optimize for Sval:**
```bash
cargo run --bin optimize_genetic -- \
  --layout-config config/keyboard/sval.yml \
  --exclude-chars " 0123456789=(){}[]" \
  "starting-layout-string"
```

## Customization

### Key Costs
Edit `config/keyboard/sval.yml` to adjust:
- Directional preferences (North vs South)
- Finger strength differences
- Personal comfort zones

### Evaluation Metrics
Edit evaluation config to tune:
- Finger repeat penalties
- Scissoring sensitivity
- Movement pattern costs
