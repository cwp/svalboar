# Evaluation Metrics

The optimizer evaluates layouts using multiple metric types with configurable weights.

## Metric Types

### Unigram Metrics (Single Keys)

**Key Costs**
- Cost per keystroke based on finger/position difficulty
- Weighted by character frequency
- Lower costs for home row, higher for pinkies

**Finger Balance**
- Distributes load across fingers according to strength
- Default ratios: Index(2.0), Middle(2.0), Ring(1.4), Pinky(1.2)
- Penalizes over/underuse of any finger

**Hand Balance** 
- Targets 50/50 left/right hand distribution
- Prevents dominant hand overuse

**Row Loads**
- Informational metric showing usage per row
- Home row preferred, top/bottom rows penalized

**Modifier Usage**
- Costs for layer access modifiers
- Hold: 1.0, OneShot: 0.0, LongPress: 1.0

### Bigram Metrics (Key Pairs)

**Finger Repeats**
- Penalizes same finger consecutive use
- Sval-specific: Center→South rolls are "nice"
- Factors: stretch(1.2×), curl(1.1×), lateral(1.5×)

**Movement Pattern**
- Costs for finger-to-finger transitions
- Considers finger lengths, rows crossed, direction
- Lateral stretches heavily penalized

**Scissoring** (Sval)
- Detects North-South combinations
- Prevents awkward opposing movements

**Symmetric Handswitches**
- Prefers mirrored left/right patterns
- Encourages consistent hand alternation

**Manual Bigram Penalty**
- Custom costs for specific key combinations
- Addresses hard-to-model awkward pairs

**No Handswitch After Unbalancing**
- Penalizes staying on same hand after stretch
- Encourages hand alternation for recovery

### Trigram Metrics (3-Key Sequences)

**Irregularity**
- Combines bigram costs within trigrams
- Geometric mean of first+second bigram costs

**No Handswitch in Trigram**
- Costs for same-hand trigrams
- Factors: direction change(2.0×), finger repeats(2.0×)

**Secondary Bigrams**
- Evaluates 1st→3rd key relationship
- Weighted by handswitch presence

**Trigram Finger Repeats**
- Three consecutive keys on same finger
- Lateral movement multiplier: 1.2×

**Trigram Rolls**
- Inward rolls: good (factor 1.0)
- Outward rolls: bad (factor 0.2)

### Layout Metrics (Global)

**Shortcut Keys**
- Keeps common shortcuts (cvxz) on left hand
- Within leftmost N columns for easy access

**Similar Letters**
- Groups related characters together
- Diacritics: ä near a, ö near o
- Sound pairs: p-b, d-t, m-n

**Similar Letter Groups**
- Consistent relative positioning
- Example: auo → äüö mapping

## Oxey Metrics

Alternative metric set with different focus:

**SFBs (Same Finger Bigrams)**
- Direct same-finger penalty
- Simpler than finger_repeats

**LSBs (Lateral Same Finger Bigrams)** 
- Same finger with column change
- Excludes thumbs by default

**DSFBs (Disjointed Same Finger Bigrams)**
- Same finger bigrams in trigrams (1st+3rd)

**Rolls (Inward/Outward)**
- Direction-aware same-hand sequences
- Inward preferred over outward

**Redirects/Bad Redirects**
- Direction changes within trigrams
- Bad redirects involve index fingers

## KLA Metrics

Replicates KLAnext evaluator metrics:

**Distance**
- Physical distance traveled
- Weighted by finger difficulty scores

**Same Hand/Finger**
- Direct counts of same-hand/finger usage
- Finger-specific scoring factors

**Home Key Words**
- Percentage of words typeable on home row
- Uses 30,000 word frequency list

## Configuration

### Metric Weights
```yaml
finger_repeats:
  enabled: true
  weight: 1500.0        # High penalty
  normalization: weight_found

key_costs:
  enabled: true  
  weight: 60.0          # Moderate influence
  normalization: weight_found
```

### Normalization Types
- **weight_found**: Scale by total n-gram weight found
- **weight_all**: Scale by all possible n-gram weight  
- **fixed**: Use fixed normalization value

### Parameters
Each metric has tunable parameters:
```yaml
finger_repeats:
  params:
    finger_factors:
      Index: 0.8          # Easier finger
      Pinky: 1.4          # Harder finger
    stretch_factor: 0.75  # Outward movement
    curl_factor: 0.1     # Inward movement
```

## Total Score

Final layout cost = Σ(metric_weight × normalized_cost)

Lower scores indicate better layouts. Best community layouts achieve ~250-300 total cost.