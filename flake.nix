{
  inputs = {
    agenix = {
      inputs = {
        darwin.follows = "nix-darwin";
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
      url = "github:ryantm/agenix";
    };
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
    nixos-hardware = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:dseum/nixos-hardware/dell-xps-14-da14260";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };
  outputs =
    inputs@{
      self,
      agenix,
      home-manager,
      nix-darwin,
      nix-homebrew,
      nixpkgs,
      ...
    }:
    let
      user = "denniseum";
      localModule = ./local.nix;
      linuxSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      darwinSystems = [
        "aarch64-darwin"
      ];
      mkApp =
        pkgs: name: system:
        let
          app = pkgs.writeShellApplication {
            inherit name;
            text = ''
              exec ${self}/target/${system}/${name} "$@"
            '';
          };
        in
        {
          type = "app";
          program = "${app}/bin/${name}";
          meta.description = "Run ${name} for ${system}";
        };
      mkInitApp =
        pkgs: targetDir:
        let
          app = pkgs.writeShellApplication {
            name = "init";
            runtimeInputs = [
              pkgs.coreutils
              pkgs.git
            ];
            text = ''
              green="$(printf '\033[1;32m')"
              yellow="$(printf '\033[1;33m')"

              println() {
                printf '\033[1mnix-config: %s%s\n\033[0m' "$1" "$2"
              }

              target_dir="${targetDir}"
              tmp_dir="$(mktemp -d)"
              user_name="$(id -un)"
              trap 'rm -rf "$tmp_dir"' EXIT

              println "$yellow" "injecting..."

              git clone "https://github.com/dseum/nix-config.git" "$tmp_dir/nix-config" &>/dev/null

              if [ -e "$target_dir" ]; then
                sudo cp -a "$target_dir" "''${target_dir}.backup"
                sudo rm -rf "$target_dir"
              fi

              sudo mv "$tmp_dir/nix-config" "$target_dir"
              sudo chown -R "$user_name" "$target_dir"

              println "$green" "injected into $target_dir"
            '';
          };
        in
        {
          type = "app";
          program = "${app}/bin/init";
          meta.description = "Install nix-config into ${targetDir}";
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
            agenix.darwinModules.default
            ./module/darwin
            (if builtins.pathExists localModule then localModule else { })
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
            agenix.nixosModules.default
            ./module/nixos
            (if builtins.pathExists localModule then localModule else { })
          ];
        }
      );
    };
}
