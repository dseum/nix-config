{
  inputs = {
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager";
    };
    nix-darwin = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-darwin/nix-darwin";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-vscode-extensions = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/nix-vscode-extensions";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };
  outputs =
    inputs@{
      self,
      home-manager,
      nix-darwin,
      nix-homebrew,
      nix-vscode-extensions,
      nixpkgs,
    }:
    let
      user = "denniseum";
      linuxSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      darwinSystems = [
        "aarch64-darwin"
      ];
      mkApp = pkgs: name: system: {
        type = "app";
        program = "${pkgs.writeScriptBin name ''
          #!/bin/sh -e
          PATH=${pkgs.git}/bin:$PATH
          exec ${self}/target/${system}/${name}
        ''}/bin/${name}";
      };
      mkInitApp = pkgs: targetDir: {
        type = "app";
        program = "${pkgs.writeScriptBin "init" ''
          #!/bin/sh -e

          GREEN='\033[1;32m'
          RED='\033[1;31m'
          YELLOW='\033[1;33m'

          println() {
            printf "\033[1mnix-config: "
            printf "$@"
            printf "\n\033[0m"
          }

          TARGET_DIR="${targetDir}"
          TMP_DIR=$(mktemp -d)
          USER_NAME=$(whoami)

          println "''${YELLOW}injecting..."

          ${pkgs.git}/bin/git clone "https://github.com/dseum/nix-config.git" "$TMP_DIR/nix-config" &>/dev/null
          if [ $? -ne 0 ]; then
              println "''${RED}failed to clone repository"
              exit 1
          fi

          if [ -e "$TARGET_DIR" ]; then
            sudo cp -a "$TARGET_DIR" "''${TARGET_DIR}.backup"
            if [ $? -ne 0 ]; then
                println "''${RED}failed to create backup"
                exit 1
            fi
            sudo rm -rf "$TARGET_DIR"
          fi

          sudo mv "$TMP_DIR/nix-config" "$TARGET_DIR"
          sudo chown -R "$USER_NAME" "$TARGET_DIR"

          rm -rf "$TMP_DIR"

          println "''${GREEN}injected into ''${TARGET_DIR}"
        ''}/bin/init";
      };
      mkLinuxApps =
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        {
          "build-switch" = mkApp pkgs "build-switch" system;
          "init" = mkInitApp pkgs "/etc/nixos";
        };
      mkDarwinApps =
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        {
          "build-switch" = mkApp pkgs "build-switch" system;
          "init" = mkInitApp pkgs "/etc/nix-darwin";
        };
    in
    {
      apps =
        nixpkgs.lib.genAttrs linuxSystems mkLinuxApps // nixpkgs.lib.genAttrs darwinSystems mkDarwinApps;
      darwinConfigurations = nixpkgs.lib.genAttrs darwinSystems (
        system:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = inputs // {
            inherit user;
            targetDir = "/private/etc/nix-darwin";
          };
          modules = [
            home-manager.darwinModules.home-manager
            nix-homebrew.darwinModules.nix-homebrew
            ./module/darwin
          ];
        }
      );
      nixosConfigurations = nixpkgs.lib.genAttrs linuxSystems (
        system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = inputs // {
            inherit user;
            targetDir = "/etc/nixos";
          };
          modules = [
            home-manager.nixosModules.home-manager
            ./module/nixos
          ];
        }
      );
    };
}
