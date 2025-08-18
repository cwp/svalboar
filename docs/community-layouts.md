# Community Layouts

The optimizer maintains a shared database of community-submitted layouts for comparison and collaboration.

## Live Database

**URL**: https://keyboard-layout-optimizer.fly.dev

### Current Statistics
- **75+ unique layouts** across multiple keyboard configurations
- **Score range**: 250-3774 total cost (lower is better)
- **Contributors**: 40+ community members
- **Keyboard configs**: standard, ortho, moonlander, crkbd, lily58, ansi

### Top Performing Layouts
| Layout | Author | Score | Config |
|--------|--------|-------|---------|
| CMOS | CMOS | 250.7 | standard |
| Meow | Meow | 251.4 | standard |
| dime | dime | 253.0 | standard |
| all variable | all variable | 253.2 | standard |
| noted-merge-kafka | noted-merge-kafka | 252.0 | standard |

### Established Layouts
| Layout | Author | Score | Config |
|--------|--------|-------|---------|
| QWERTZ | qwertz | 525.2 | standard |
| Neo2 | neo2 | 374.7 | standard |
| Bone | bone | 304.2 | standard |
| Mine | mine | 319.9 | standard |
| AdNW | AdNW | 291.3 | standard |
| KOY | KOY | 289.9 | standard |

## Submission Methods

### Automatic from CLI
```bash
cargo run --bin optimize_genetic -- \
  --publish-as "username" \
  --publish-if-cost-below 300.0 \
  --publish-layout-config "standard" \
  "initial-layout-string"
```

### Manual Script Submission
```bash
./scripts/publish_layout.sh "layout-string" "username" "keyboard-config" "api-url"
```

### Direct API Call
```bash
curl -X POST -d '{
  "layout": "layout-string-here",
  "published_by": "username",
  "layout_config": "standard"
}' https://keyboard-layout-optimizer.fly.dev/api
```

## Database Schema

### Layout Record
```sql
CREATE TABLE layouts (
    id SERIAL PRIMARY KEY,
    layout VARCHAR NOT NULL,              -- Layout string
    total_cost DOUBLE PRECISION NOT NULL, -- Optimization score
    details_json VARCHAR NOT NULL,        -- Full metric breakdown
    printed VARCHAR NOT NULL,             -- Human-readable evaluation
    published_by VARCHAR,                 -- Submitter username
    created TIMESTAMP,                    -- Submission time
    highlight BOOL,                       -- Featured/official flag
    layout_config VARCHAR NOT NULL        -- Keyboard configuration
);
```

### Data Structure
```json
{
  "layout": "qwertzuiopüß...",
  "total_cost": 525.23,
  "published_by": "username",
  "details": { /* full metric breakdown */ },
  "printed": "human readable evaluation",
  "plot": "ASCII art visualization",
  "highlight": false,
  "layout_config": "standard"
}
```

## Quality Control

### Automatic Evaluation
- **Consistent scoring** using same metrics for all layouts
- **Duplicate prevention** - same layout+config combination rejected
- **Validation** - layout must parse correctly for keyboard config

### Admin Features
- **Highlighting** - mark high-quality or notable layouts
- **Re-evaluation** - update scores when metrics change
- **Secret-protected** admin actions

### Curation Process
```yaml
# Highlighting requires admin secret
POST /api
{
  "layout": "...",
  "highlight": true,
  "secret": "admin_secret"
}
```

## API Reference

### List Layouts
```bash
GET /api?layout_config=standard
```
Returns array of all layouts for specified keyboard config.

### Get Specific Layout
```bash
GET /api/{layout}?layout_config=standard
```
Returns detailed layout information including visualization.

### Submit Layout
```bash
POST /api
{
  "layout": "layout-string",
  "published_by": "username",
  "layout_config": "standard",
  "highlight": false  # optional, admin only
}
```

### Re-evaluate All (Admin)
```bash
POST /api/reeval
"admin_secret"
```
Recalculates scores for all layouts using current metrics.

## Supported Keyboards

### Standard Keyboards
- **standard** - Traditional QWERTZ/QWERTY layout
- **ansi** - US ANSI layout variant

### Ortholinear
- **ortho** - Uniform grid layout
- **lily58** - Split ortholinear with thumb clusters
- **crkbd** - Compact split ortholinear

### Ergonomic
- **moonlander** - ZSA Moonlander split ergonomic

### Custom (Not Yet Included)
- **sval** - Svalboard (could be added)

## Layout Categories

### Optimized Layouts
Community-generated through genetic algorithms:
- **noted series** - Multiple variants by noted
- **mine series** - Variants by mine
- **frontier series** - Experimental layouts

### Established Layouts
Well-known keyboard layouts:
- **QWERTZ/QWERTY** - Traditional layouts
- **Neo family** - German ergonomic layouts (Neo2, Bone, AdNW, KOY)
- **Dvorak variants** - Alternative arrangements

### Experimental
Research and specialized layouts:
- **Programming-focused** - Optimized for code
- **Language-specific** - Tuned for particular languages
- **Constraint-based** - Limited optimization scope

## Contributing Guidelines

### Layout Naming
- **Descriptive names** - indicate variant or focus
- **Version control** - use suffixes for iterations
- **Attribution** - credit original authors for derivatives

### Quality Standards
- **Score threshold** - typically <350 for standard keyboard
- **Testing** - verify layout works on actual hardware
- **Documentation** - explain design decisions for novel layouts

### Collaboration
- **Derivative work** - build on existing good layouts
- **Metric tuning** - experiment with evaluation parameters
- **Hardware variants** - adapt layouts to different keyboards

## Analysis Tools

### Comparison Features
- **Side-by-side** metric breakdown
- **Score evolution** over time
- **Performance distribution** across layouts
- **Author contributions** tracking

### Search and Filter
- **By score range** - find layouts within performance band
- **By author** - see all layouts from contributor
- **By keyboard** - filter by hardware configuration
- **By date** - chronological layout development

## Future Enhancements

### Planned Features
- **Layout families** - group related variants
- **Tagging system** - categorize by purpose/style
- **Rating system** - community feedback on layouts
- **Usage statistics** - real-world adoption data

### Technical Improvements
- **Performance monitoring** - track evaluation speed
- **Batch operations** - bulk layout management
- **Export formats** - multiple layout file formats
- **Integration** - direct import to keyboard firmware
