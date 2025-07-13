{ pkgs }:
let
  shared-packages = import ../shared/packages.nix { inherit pkgs; };
in
shared-packages
++ [
  pkgs.llvmPackages_20.clangWithLibcAndBasicRtAndLibcxx
  pkgs.unzip
]
