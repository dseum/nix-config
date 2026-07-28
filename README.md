# nix-config

## Getting Started

With Nix installed, run:

```sh
nix run --refresh github:dseum/nix-config#init
```

This avoids you having to manually deal with the repository and allows you to inject into `/etc/nixos` (NixOS) or `/etc/nix-darwin` (macOS; symlink of `/private/etc/nix-darwin`) with the current user assumed to be the owner. That path will be referred to as `<nix-config>`. Any previous file or directory at that path are `cp -a` into the `<nix-config>.backup`.

If on macOS, you need to [disable SIP](https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection) for yabai and `xcode-select --install` for Homebrew.

Then, to build and switch, run:

```sh
nix run <nix-config>#build-switch
```

## Local Module

This config automatically loads a local module for changes specific to your machine. In the root directory of this repository, create a file named `local.nix` that contains:

```nix
{ lib, pkgs, ... }:
{
  environment.systemPackages = [ ];
  homebrew.brews = lib.mkAfter [ ];
}
```

## Secrets

Secrets are managed with [agenix](https://github.com/ryantm/agenix): encrypted `*.age` files in `secrets/` are decrypted to `/run/agenix/<name>` on `build-switch`. Declare each in `local.nix` under `age.secrets` and reference it as `config.age.secrets.<name>.path`.

Add or rotate one with `age-secret <name>` (hidden prompt, no trailing newline), then rebuild:

```sh
age-secret modal-token-id
```

Example `local.nix` wiring secrets into an opencode provider (one Modal endpoint per model, sharing the workspace token):

```nix
{ config, user, ... }:
{
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  age.secrets = {
    modal-token-id = { file = ./secrets/modal-token-id.age; owner = user; mode = "0400"; };
    modal-token-secret = { file = ./secrets/modal-token-secret.age; owner = user; mode = "0400"; };
    modal-url-kimi-k3 = { file = ./secrets/modal-url-kimi-k3.age; owner = user; mode = "0400"; };
  };
  home-manager.users.${user}.programs.opencode.settings = {
    model = "kimi-k3/moonshotai/Kimi-K3";
    provider.kimi-k3 = {
      npm = "@ai-sdk/openai-compatible";
      name = "Kimi K3";
      options = {
        baseURL = "{file:${config.age.secrets.modal-url-kimi-k3.path}}";
        apiKey = "dummy";
        headers = {
          "Modal-Key" = "{file:${config.age.secrets.modal-token-id.path}}";
          "Modal-Secret" = "{file:${config.age.secrets.modal-token-secret.path}}";
        };
      };
      models."moonshotai/Kimi-K3" = { name = "Kimi K3"; };
    };
  };
}
```

## Acknowledgements

Thanks to [dustinlyons/nixos-config](https://github.com/dustinlyons/nixos-config) for the starter that began this project!
