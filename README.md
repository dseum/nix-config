# nix-config

## Getting Started

Either with Nix on NixOS or Determinate Nix on macOS, run:

```sh
nix run --refresh github:dseum/nix-config#init
```

This avoids you having to manually deal with the repository and allows you to inject into `/etc/nixos` (NixOS) or `/etc/nix-darwin` (macOS; symlink of `/private/etc/nix-darwin`) with the current user assumed to be the owner. That path will be referred to as `<nix-config`. Any previous file or directory at that path are `cp -a` into the `<nix-config>.backup`.

If on macOS, you need to [disable SIP](https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection) for yabai and `xcode-select --install` for Homebrew.

Then, to build and switch, run:

```sh
nix run <nix-config>#build-switch
```

That's it!

## Local Module

This config automatically loads a local module for changes specific to your machine. E.g., in the root directory of this repository, create a file named `local.nix` that contains:

```nix
{ lib, pkgs, ... }:
{
  environment.systemPackages = [ ];
  homebrew.brews = lib.mkAfter [ ];
}
```

## Acknowledgements

Thanks to [dustinlyons/nixos-config](https://github.com/dustinlyons/nixos-config) for the starter that began this project!
