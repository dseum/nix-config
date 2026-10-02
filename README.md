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

To preview and apply updates, run:

```sh
nix run <nix-config>#update
```

This shows package version changes without building the updated system, then asks before updating `flake.lock`. Press Enter to update it. If the current system cannot evaluate, package changes cannot be shown, but the candidate is still evaluated before the prompt. Build-time dependencies may be included.

To update specific inputs, pass them after `--`:

```sh
nix run <nix-config>#update -- nixpkgs home-manager
```

## Local Module

This config automatically loads a local module for changes specific to each machine. In the root directory of the checkout, create an ignored file named `local.nix`.

On macOS, it can contain local Homebrew or system settings:

```nix
{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.terraform ];
  homebrew.brews = [ "livekit" ];
}
```

On NixOS, keep machine identity and hardware-dependent settings there, including `system.stateVersion`, hardware-profile imports, firmware allowances, and machine-specific boot mount points:

```nix
{ ... }:
{
  system.stateVersion = "26.05";
}
```

Set `system.stateVersion` to the NixOS release used for that machine's first installation and do not update it during normal upgrades. `hardware-configuration.nix` remains generated hardware discovery; do not put hand-written machine policy in it.

## Acknowledgements

Thanks to [dustinlyons/nixos-config](https://github.com/dustinlyons/nixos-config) for the starter that began this project!
