{
  description = "Svalboar - Keyboard layout optimization toolkit";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    rust-overlay,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        overlays = [(import rust-overlay)];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = ["rust-src" "rust-analyzer"];
          targets = ["wasm32-unknown-unknown"];
        };

        # Common build inputs for the project
        buildInputs = with pkgs; [
          openssl
          pkg-config
        ];

        # Development tools
        devTools = with pkgs; [
          # Rust toolchain
          rustToolchain

          # Essential cargo tools
          cargo-watch
          cargo-edit
          cargo-outdated
          cargo-audit
          cargo-deny
          cargo-machete
          cargo-nextest
          cargo-expand

          # Web development tools (for WebUI)
          nodejs_24
          wasm-pack

          # Build dependencies
          pkg-config
          openssl

          # Development and debugging tools
          git
          just
          hyperfine
          tokei
          fd
          ripgrep

          # Optional: enhanced terminal experience
          starship
          zellij
        ];

        svalboarPackage = pkgs.rustPlatform.buildRustPackage {
          pname = "svalboar";
          version = "0.2.0";

          src = pkgs.lib.cleanSource ./.;

          # This will need to be updated after running nix build once
          cargoHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

          inherit buildInputs;
          nativeBuildInputs = with pkgs; [
            pkg-config
          ];

          # Skip tests during build (they can be run separately)
          doCheck = false;

          meta = with pkgs.lib; {
            description = "Keyboard layout optimization toolkit";
            homepage = "https://github.com/dariogoetz/keyboard_layout_optimizer";
            license = licenses.gpl3Plus;
            maintainers = [];
            platforms = platforms.unix;
          };
        };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = devTools;

          # Auto-warpify the shell if running in Warp
          shellHook = ''
            [[ "$-" == *i* ]] && printf '\u001BP$f{"hook": "SourcedRcFileForWarp", "value": { "shell": "bash", "uname": "Darwin" }}ú'
          '';

          # Environment variables
          RUST_BACKTRACE = "1";
          RUST_LOG = "debug";
          PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";

          # For better build performance
          CARGO_INCREMENTAL = "1";
          CARGO_NET_GIT_FETCH_WITH_CLI = "true";
        };

        packages = {
          default = svalboarPackage;

          # Docker image (optional)
          docker = pkgs.dockerTools.buildImage {
            name = "svalboar";
            tag = "latest";
            contents = [svalboarPackage];
            config = {
              Cmd = ["${svalboarPackage}/bin/evaluate"];
              WorkingDir = "/workspace";
            };
          };
        };

        # Additional outputs for CI/CD
        checks = {
          clippy =
            pkgs.runCommand "svalboar-clippy" {
              nativeBuildInputs = devTools;
            } ''
              cp -r ${./.} source
              cd source
              cargo clippy --workspace --all-features -- -D warnings
              mkdir -p $out
            '';

          fmt =
            pkgs.runCommand "svalboar-fmt" {
              nativeBuildInputs = devTools;
            } ''
              cp -r ${./.} source
              cd source
              cargo fmt --check
              mkdir -p $out
            '';
        };

        # Development apps
        apps = {
          default = flake-utils.lib.mkApp {
            drv = svalboarPackage;
            exePath = "/bin/evaluate";
          };
        };
      }
    );
}
