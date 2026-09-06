{
  pkgs,
  nix-vscode-extensions,
  user,
  ...
}:
{
  environment.etc."codex/config.toml".source = (pkgs.formats.toml { }).generate "codex-config.toml" {
    approval_policy = "never";
    check_for_update_on_startup = false;
    cli_auth_credentials_store = "keyring";
    feedback.enabled = false;
    features = {
      memories = true;
      prevent_idle_sleep = true;
    };
    file_opener = "none";
    model = "gpt-5.6-sol";
    model_reasoning_effort = "high";
    model_reasoning_summary = "concise";
    model_verbosity = "low";
    personality = "none";
    plan_mode_reasoning_effort = "ultra";
    sandbox_mode = "danger-full-access";
    service_tier = "fast";
    tui = {
      notification_method = "osc9";
      notifications = [ "agent-turn-complete" ];
    };
    web_search = "live";
  };
  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
    optimise.automatic = true;
    settings = {
      download-buffer-size = 268435456; # 256 MiB
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ user ];
      warn-dirty = false;
      show-trace = true;
      keep-outputs = true;
    };
  };
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [ nix-vscode-extensions.overlays.default ];
  };
  fonts.packages = [
    pkgs.ibm-plex
    pkgs.newcomputermodern
  ];
}
