# nix-config

## Getting Started

After installing Nix, run the following.

```sh
nix run --refresh github:dseum/nix-config#init
```

> If you ever do use this method, you should replace the `git clone` in the init with a pinned hash `fetchGit` to never risk MITM attacks. After the init, you can checkout to the HEAD and compare diffs before building and switching.

This avoids you having to manually deal with the repository and allows you to inject into `/etc/nixos` (NixOS) or `/etc/nix-darwin` (macOS; symlink of `/private/etc/nix-darwin`) with the current user assumed to be the owner. That path will be referred to as `<nix-config`. Any previous file or directory at that path are `cp -a` into the `<nix-config>.backup`.

To build and switch, run the following.

```sh
nix run <nix-config>#build-switch
```

That's it! Use the above flake output anywhere to build and switch.

## Acknowledgements

Thanks to [dustinlyons/nixos-config](https://github.com/dustinlyons/nixos-config) for the starter that began this project!
