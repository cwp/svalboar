# Web Interface

The optimizer provides two web interfaces: a WASM-based evaluation app and a layout database service.

## WASM Evaluation App

**Live URL**: https://dariogoetz.github.io/keyboard_layout_optimizer

### Features
- **Real-time evaluation** as you type
- **Interactive optimization** with genetic algorithms and simulated annealing
- **Multiple keyboard support** (standard, ortho, moonlander, crkbd, lily58, ansi)
- **Multiple corpus options** for different languages
- **Live visualization** of layout quality metrics
- **Web Workers** for non-blocking optimization

### Technology Stack
- **Rust → WebAssembly** for performance
- **Vue.js** frontend with Bootstrap styling
- **Chart.js** for metric visualizations
- **CodeMirror** for syntax-highlighted config editing
- **Comlink** for web worker communication

### Building Locally

**Build WASM module:**
```bash
cd webui/layout_evaluation_wasm
wasm-pack build --release
```

**Start development server:**
```bash
cd www
npm install
npm run start
```

**Visit**: http://localhost:8080

### Supported Keyboards
```javascript
const LAYOUT_CONFIGS = {
  standard: config_standard_keyboard,
  ortho: config_ortho,
  moonlander: config_moonlander,
  crkbd: config_crkbd,
  lily58: config_lily58,
  ansi: config_ansi,
}
```

### Available Corpora
- **Blend (deu/eng 60/40)** - Mixed German/English
- **Wikipedia (deu/eng 60/40)** - Wikipedia blend
- **Wikipedia (deu)** - German Wikipedia 2021
- **Wikipedia (eng)** - English Wikipedia 2016
- **Web-public (deu)** - German web content 2019
- **Web-public (eng)** - English web content 2018
- **News Typical (eng)** - English news 2016
- **Mixed Typical (deu)** - German mixed 2011
- **#neo - IRC** - German IRC channel
- **ArneBab** - Historical optimizer data

### WASM API Functions
```javascript
// Create evaluator
let evaluator = new LayoutEvaluator(
  layoutConfigString,
  evalParamsString,
  ngramProvider
);

// Evaluate layout
let result = evaluator.evaluate(layoutString);

// Plot layout
let visualization = evaluator.plot(layoutString, layerIndex);

// Get permutable keys
let keys = evaluator.permutable_keys();
```

### Adding Sval Support
To add Sval keyboard to web interface:

1. **Import config:**
```javascript
import config_sval from '../../../config/keyboard/sval.yml'
```

2. **Add to configs:**
```javascript
const LAYOUT_CONFIGS = {
  // ... existing configs
  sval: config_sval,
}
```

3. **Rebuild WASM:**
```bash
wasm-pack build --release
```

## Layout Database Service

**Live URL**: https://keyboard-layout-optimizer.fly.dev

### Features
- **Community layout repository** with 75+ layouts
- **Layout comparison tools** between different configurations
- **RESTful API** for publishing/retrieving results
- **Admin curation** with highlighting system
- **Multi-keyboard support** (standard, ortho, moonlander, etc.)

### Technology Stack
- **Rocket** web framework
- **PostgreSQL** database
- **SQLx** for database operations
- **CORS** support for web app integration

### Database Schema
```sql
CREATE TABLE layouts (
    id SERIAL PRIMARY KEY,
    layout VARCHAR NOT NULL,
    total_cost DOUBLE PRECISION NOT NULL,
    details_json VARCHAR NOT NULL,
    printed VARCHAR NOT NULL,
    published_by VARCHAR,
    created TIMESTAMP,
    highlight BOOL,
    layout_config VARCHAR NOT NULL DEFAULT 'standard'
);
```

### API Endpoints

**GET `/api`** - List all layouts
```bash
curl https://keyboard-layout-optimizer.fly.dev/api
```

**GET `/api/{layout}?layout_config={config}`** - Get specific layout
```bash
curl https://keyboard-layout-optimizer.fly.dev/api/qwertz?layout_config=standard
```

**POST `/api`** - Submit new layout
```bash
curl -X POST -d '{
  "layout": "qwertz...",
  "published_by": "username",
  "layout_config": "standard"
}' https://keyboard-layout-optimizer.fly.dev/api
```

**POST `/api/reeval`** - Admin re-evaluation
```bash
curl -X POST -d "admin_secret" https://keyboard-layout-optimizer.fly.dev/api/reeval
```

### Publishing from CLI
```bash
cargo run --bin optimize_genetic -- \
  --publish-as "username" \
  --publish-if-cost-below 300.0 \
  --publish-layout-config "standard" \
  "initial-layout"
```

### Running Database Service

**Docker setup:**
```bash
cd webui/layouts_webservice
docker-compose up -d
```

**Configuration:**
```toml
# Rocket.toml
[default]
allowed_cors_origins = "http://localhost:8080"
default_layout_config = "standard"
secret = "admin_secret"

[default.databases.sqlx]
url = "postgres://user:pass@localhost:5432/layouts"
```

## Deployment

### GitHub Actions
Automatic deployment configured in `.github/workflows/rust.yml`:

```yaml
- name: Build WASM
  run: wasm-pack build --release
  working-directory: ./webui/layout_evaluation_wasm

- name: Build Webpage
  run: npm run build
  working-directory: ./webui/layout_evaluation_wasm/www

- name: Deploy to github pages
  uses: JamesIves/github-pages-deploy-action@4.1.7
  with:
    branch: gh-pages
    folder: ./webui/layout_evaluation_wasm/www/dist
```

### Production Hosting
- **WASM App**: GitHub Pages (automatic from `gh-pages` branch)
- **Database Service**: Fly.io with PostgreSQL addon
- **CORS**: Configured for cross-origin requests

## Development Workflow

### Local Development
1. **Start database**: `docker-compose up -d` (in layouts_webservice/)
2. **Build WASM**: `wasm-pack build --release` (in layout_evaluation_wasm/)
3. **Start frontend**: `npm run start` (in www/)
4. **Start API**: `cargo run` (in layouts_webservice/)

### Adding Features
1. **Rust changes**: Modify WASM crate, rebuild with wasm-pack
2. **Frontend changes**: Edit Vue.js components in www/
3. **API changes**: Modify Rocket service, update database schema if needed
4. **Deploy**: Push to main branch for automatic deployment

## Performance Notes

- **WASM compilation**: ~30s build time for release mode
- **Evaluation speed**: ~100ms per layout in browser
- **Database queries**: Indexed on layout+config for fast lookups
- **Caching**: Browser caches WASM module and static assets
- **Workers**: Optimization runs in background threads

## Browser Support

- **Modern browsers**: Chrome 69+, Firefox 62+, Safari 12+
- **WebAssembly**: Required for evaluation functionality
- **JavaScript**: ES6+ features used throughout
- **Mobile**: Responsive design works on tablets/phones