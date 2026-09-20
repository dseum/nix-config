{ pkgs }:
[
  pkgs.git
  (pkgs.callPackage ../../packages/helium { })
  pkgs.slack
  pkgs.spotify
  pkgs.vim
]
