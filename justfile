# Svalboar - Keyboard Layout Optimizer
# Common development tasks using Just command runner
# Install with: cargo install just

# Default recipe - show available commands
default:
    @just --list

# Build all packages
build:
    cargo build

# Build with optimizations
build-release:
    cargo build --release

# Build for size optimization
build-small:
    cargo build --profile release-small

# Run all tests
test:
    cargo test

# Run tests with nextest (faster)
test-nextest:
    cargo nextest run

# Run tests with coverage
test-coverage:
    cargo tarpaulin --out html --output-dir coverage

# Run benchmarks
bench:
    cargo bench

# Check code without building
check:
    cargo check

# Check all packages and features
check-all:
    cargo check --workspace --all-features

# Run clippy lints
clippy:
    cargo clippy --workspace --all-features -- -D warnings

# Format code
fmt:
    cargo fmt --all

# Check formatting without changing files
fmt-check:
    cargo fmt --all -- --check

# Security audit
audit:
    cargo audit

# Check for unused dependencies
machete:
    cargo machete

# Check for outdated dependencies
outdated:
    cargo outdated

# Dependency license check
deny:
    cargo deny check

# Clean build artifacts
clean:
    cargo clean

# Full CI check (what runs in CI)
ci: fmt-check clippy test audit deny

# Development workflow - quick checks
dev: check clippy test

# Watch for changes and run checks
watch:
    cargo watch -x check -x test

# Watch and run a specific binary
watch-evaluate:
    cargo watch -x 'run --bin evaluate'

# Profile with perf (Linux only)
profile-perf binary="evaluate":
    cargo build --release
    perf record --call-graph=dwarf target/release/{{binary}}
    perf report

# Profile with instruments (macOS only)
profile-instruments binary="evaluate":
    cargo build --release
    xcrun xctrace record --template 'Time Profiler' --launch target/release/{{binary}}

# Generate documentation
docs:
    cargo doc --workspace --all-features --no-deps --open

# Generate documentation for private items too
docs-private:
    cargo doc --workspace --all-features --no-deps --document-private-items --open

# Update dependencies (interactive)
update:
    cargo edit upgrade

# Install development tools
install-tools:
    cargo install cargo-nextest cargo-tarpaulin cargo-audit cargo-deny cargo-machete cargo-edit cargo-outdated cargo-expand

# Build WebAssembly package
wasm-build:
    cd webui/layout_evaluation_wasm && wasm-pack build --target web --out-dir pkg

# Build and test WebAssembly
wasm-test:
    cd webui/layout_evaluation_wasm && wasm-pack test --headless --firefox

# Start the web service (development)
serve:
    cargo run --bin layouts_webservice

# Database migrations (for web service)
db-migrate:
    cd webui/layouts_webservice && sqlx migrate run

# Create new database migration
db-create-migration name:
    cd webui/layouts_webservice && sqlx migrate add {{name}}

# Check SQL queries compile
db-check:
    cd webui/layouts_webservice && cargo sqlx check

# Prepare SQL for offline builds
db-prepare:
    cd webui/layouts_webservice && cargo sqlx prepare

# Run example layout evaluation
example:
    cargo run --bin evaluate -- \
        --layout-config config/keyboard/standard.yml \
        --ngrams ngrams/eng/eng_wiki_1m \
        --exclude-chars " 0123456789=(){}[]" \
        "q0a1z w2sbx e3dtc r4fgv uhj5m iyk67 onl89 p={}(["

# Count lines of code
loc:
    tokei

# Generate flamegraph (requires cargo-flamegraph)
flamegraph binary="evaluate":
    cargo flamegraph --bin {{binary}}

# Docker build
docker-build:
    docker build -t svalboar .

# Nix build
nix-build:
    nix build

# Nix develop (enter development shell)
nix-shell:
    nix develop

# Update flake inputs
nix-update:
    nix flake update
