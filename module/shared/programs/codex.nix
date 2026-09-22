{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.codex;

  atLeast = version: cfg.package == null || lib.versionAtLeast (lib.getVersion cfg.package) version;
  isTomlConfig = atLeast "0.2.0";
  migrateLegacyProfiles = atLeast "0.134.0";
  useXdgDirectories = config.home.preferXdgDirectories && isTomlConfig;
  configDir =
    if useXdgDirectories then
      "${lib.removePrefix config.home.homeDirectory config.xdg.configHome}/codex"
    else
      ".codex";
  configFileName = if isTomlConfig then "config.toml" else "config.yaml";
  configPath = "${configDir}/${configFileName}";
  configFile =
    if useXdgDirectories then
      "${config.xdg.configHome}/codex/${configFileName}"
    else
      "${config.home.homeDirectory}/${configPath}";

  rawSettings = if cfg.settings == null then { } else cfg.settings;
  hasLegacyProfileSettings =
    migrateLegacyProfiles && ((rawSettings ? profile) || (rawSettings ? profiles));
  legacyProfiles = lib.optionalAttrs (
    hasLegacyProfileSettings && builtins.isAttrs (rawSettings.profiles or null)
  ) rawSettings.profiles;
  profiles = legacyProfiles // cfg.profiles;
  baseSettings =
    if hasLegacyProfileSettings then
      lib.removeAttrs rawSettings [
        "profile"
        "profiles"
      ]
    else
      rawSettings;
  hasGeneratedBaseConfig =
    baseSettings != { }
    || cfg.plugins != [ ]
    || cfg.marketplaces != { }
    || (cfg.enableMcpIntegration && config.programs.mcp.enable && config.programs.mcp.servers != { });
  mutableConfigFiles =
    lib.optionalAttrs hasGeneratedBaseConfig { ${configPath} = configFile; }
    // lib.mapAttrs' (
      name: _:
      lib.nameValuePair "${configDir}/${name}.config.toml" (
        if useXdgDirectories then
          "${config.xdg.configHome}/codex/${name}.config.toml"
        else
          "${config.home.homeDirectory}/${configDir}/${name}.config.toml"
      )
    ) profiles;
in
{
  options.programs.codex.mutableUserSettings = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Whether Home Manager should merge generated settings into a writable
      Codex user configuration and profile files so Codex can persist state
      such as project trust. Declarative values take precedence on activation;
      values removed from the declarative configuration remain until removed
      from the writable file.
    '';
  };

  config = lib.mkIf (cfg.enable && cfg.mutableUserSettings && mutableConfigFiles != { }) {
    assertions = [
      {
        assertion = isTomlConfig;
        message = "`programs.codex.mutableUserSettings` requires Codex 0.2.0 or later";
      }
    ];

    home = {
      file = lib.mapAttrs (_: _: { enable = false; }) mutableConfigFiles;

      activation.codexMutableUserSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        mergeCodexConfig() {
          local configFile=$1
          local staticConfig=$2

          mkdir -p "$(dirname "$configFile")"

          local existingConfig=/dev/null
          if [ -L "$configFile" ]; then
            case "$(readlink "$configFile")" in
              /nix/store/*) ;;
              *)
                echo "refusing to replace unmanaged Codex config symlink: $configFile" >&2
                exit 1
                ;;
            esac
          elif [ -f "$configFile" ]; then
            existingConfig="$configFile"
          fi

          local mergedConfig
          mergedConfig="$(mktemp "$(dirname "$configFile")/.config.toml.XXXXXX")"
          trap 'rm -f "$mergedConfig"' EXIT
          ${lib.getExe pkgs.yq-go} -p toml -o toml eval-all \
            '. as $item ireduce ({}; . * $item)' \
            "$existingConfig" "$staticConfig" > "$mergedConfig"
          chmod 600 "$mergedConfig"
          mv -f "$mergedConfig" "$configFile"
          trap - EXIT
        }

        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (
            path: file:
            "mergeCodexConfig ${lib.escapeShellArg file} ${lib.escapeShellArg config.home.file.${path}.source}"
          ) mutableConfigFiles
        )}
      '';
    };
  };
}
