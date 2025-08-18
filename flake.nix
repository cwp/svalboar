{
  description = "Svalboar - Rust development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    rust-overlay,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        overlays = [(import rust-overlay)];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = ["rust-src" "rust-analyzer"];
        };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Rust toolchain
            rustToolchain

            # Cargo tools
            cargo-watch
            cargo-edit
            cargo-outdated
            cargo-audit

            # Build dependencies
            pkg-config
            openssl

            # Development tools
            git
            which

            # Optional: for better terminal experience
            starship
          ];

          shellHook = ''
            echo "🦀 Rust development environment for Svalboar"
            echo "Available tools:"
            echo "  - rustc $(rustc --version | cut -d' ' -f2)"
            echo "  - cargo $(cargo --version | cut -d' ' -f2)"
            echo "  - cargo-watch for live reloading"
            echo ""
            echo "Example usage from README:"
            echo "  cargo watch -x 'run --bin evaluate -- --layout-config config/keyboard/sval.yml --ngrams ngrams/eng/eng_wiki_1m --exclude-chars \" 0123456789=(){}[]\" \"q0a1z w2sbx e3dtc r4fgv uhj5m iyk67 onl89 p={}([\"'"
            echo ""
            echo "To build the project: cargo build"
            echo "To run tests: cargo test"
          '';

          # Environment variables
          RUST_BACKTRACE = "1";
          PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
        };

        # Optional: provide packages for CI/CD
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "svalboar";
          version = "0.1.0";

          src = ./.;

          # Generate Cargo.lock hash - run `nix build` to get the correct hash
          cargoHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

          buildInputs = with pkgs; [
            openssl
          ];

          nativeBuildInputs = with pkgs; [
            pkg-config
          ];
        };
      }
    );
}
