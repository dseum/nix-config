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
    nix-index-database = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/nix-index-database";
    };
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
      nix-index-database,
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
      systems = linuxSystems ++ darwinSystems;
      mkPackages =
        pkgs:
        nixpkgs.lib.mapAttrs (name: _: pkgs.callPackage (./packages + "/${name}") { }) (
          nixpkgs.lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./packages)
        );
      mkApp =
        pkgs:
        {
          name,
          script,
          arguments ? [ ],
          runtimeInputs ? [ ],
        }:
        let
          app = pkgs.writeShellApplication {
            inherit name runtimeInputs;
            text = ''
              exec ${nixpkgs.lib.escapeShellArgs ([ script ] ++ arguments)} "$@"
            '';
          };
        in
        {
          type = "app";
          program = "${app}/bin/${name}";
          meta.description = "Run ${name}";
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
      mkPackageUpdaterArguments =
        pkgs:
        let
          updatablePackages = builtins.filter (entry: entry != null) (
            nixpkgs.lib.mapAttrsToList (
              attrPath: package:
              let
                result = builtins.tryEval package;
              in
              if
                result.success
                && nixpkgs.lib.isDerivation result.value
                && result.value ? passthru
                && result.value.passthru ? updateScript
              then
                {
                  inherit attrPath;
                  package = result.value;
                }
              else
                null
            ) (mkPackages pkgs)
          );
          updaterArguments =
            entry:
            let
              inherit (entry) attrPath package;
              updateScript = package.passthru.updateScript;
              update =
                if nixpkgs.lib.isDerivation updateScript || !builtins.isAttrs updateScript then
                  { command = updateScript; }
                else
                  updateScript;
              command = map toString (nixpkgs.lib.toList update.command);
              updateAttrPath = update.attrPath or attrPath;
              pname = package.pname or (nixpkgs.lib.getName package);
              version = package.version or (nixpkgs.lib.getVersion package);
              updater = pkgs.writeShellApplication {
                name = "update-${nixpkgs.lib.replaceStrings [ "." ] [ "-" ] attrPath}";
                text = ''
                  export UPDATE_NIX_NAME=${nixpkgs.lib.escapeShellArg package.name}
                  export UPDATE_NIX_PNAME=${nixpkgs.lib.escapeShellArg pname}
                  export UPDATE_NIX_OLD_VERSION=${nixpkgs.lib.escapeShellArg version}
                  export UPDATE_NIX_ATTR_PATH=${nixpkgs.lib.escapeShellArg updateAttrPath}
                  exec ${nixpkgs.lib.escapeShellArgs command}
                '';
              };
            in
            assert command != [ ];
            [
              attrPath
              (nixpkgs.lib.getExe updater)
            ];
        in
        nixpkgs.lib.concatMap updaterArguments updatablePackages;
      mkLinuxApps =
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        {
          "build-switch" = mkApp pkgs {
            name = "build-switch";
            script = ./. + "/target/${system}/build-switch";
          };
          "init" = mkInitApp pkgs "/etc/nixos";
          "update" = mkApp pkgs {
            name = "update";
            script = ./target/update;
            arguments = [
              "/etc/nixos"
              "nixosConfigurations.${system}.config.system.build.toplevel"
            ]
            ++ mkPackageUpdaterArguments pkgs
            ++ [ "--" ];
            runtimeInputs = [
              pkgs.bash
              pkgs.coreutils
              pkgs.nix
            ];
          };
        };
      mkDarwinApps =
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        {
          "build-switch" = mkApp pkgs {
            name = "build-switch";
            script = ./. + "/target/${system}/build-switch";
          };
          "init" = mkInitApp pkgs "/etc/nix-darwin";
          "update" = mkApp pkgs {
            name = "update";
            script = ./target/update;
            arguments = [
              "/etc/nix-darwin"
              "darwinConfigurations.${system}.system"
            ]
            ++ mkPackageUpdaterArguments pkgs
            ++ [ "--" ];
            runtimeInputs = [
              pkgs.bash
              pkgs.coreutils
              pkgs.nix
            ];
          };
        };
    in
    {
      apps =
        nixpkgs.lib.genAttrs linuxSystems mkLinuxApps // nixpkgs.lib.genAttrs darwinSystems mkDarwinApps;
      packages = nixpkgs.lib.genAttrs systems (
        system:
        mkPackages (
          import nixpkgs {
            inherit system;
          }
        )
      );
      darwinConfigurations = nixpkgs.lib.genAttrs darwinSystems (
        system:
        nix-darwin.lib.darwinSystem {
          specialArgs = inputs // {
            inherit user;
            targetDir = "/private/etc/nix-darwin";
          };
          modules = [
            { nixpkgs.hostPlatform = system; }
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
          specialArgs = inputs // {
            inherit user;
            targetDir = "/etc/nixos";
          };
          modules = [
            { nixpkgs.hostPlatform = system; }
            home-manager.nixosModules.home-manager
            agenix.nixosModules.default
            ./module/nixos
            (if builtins.pathExists localModule then localModule else { })
          ];
        }
      );
    };
}
