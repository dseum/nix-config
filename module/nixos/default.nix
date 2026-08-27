{
  pkgs,
  lib,
  user,
  ...
}:
let
  sharedSystemPackages = import ../shared/system-packages.nix { inherit pkgs; };
in
{
  imports = [
    ../shared
    ./home-manager.nix
    ../../hardware.nix
  ];
  console.useXkbConfig = true;
  boot = {
    consoleLogLevel = 0;
    loader = {
      efi.canTouchEfiVariables = true;
      timeout = null;
      systemd-boot = {
        enable = true;
        configurationLimit = 1;
        consoleMode = "max";
        editor = false;
      };
    };
    kernelParams = [
      "quiet"
      "fbcon=vc:2-6"
      "console=tty0"
    ];
  };
  environment.systemPackages = sharedSystemPackages ++ [
    pkgs.google-chrome
  ];
  networking = {
    hostName = "nixos";
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];
    networkmanager.enable = true;
  };
  nixpkgs.overlays = [
    (_final: prev: {
      gnome-shell = prev.gnome-shell.overrideAttrs (oldAttrs: {
        patches = (oldAttrs.patches or [ ]) ++ [ ./gnome-shell-ignore-unavailable-headphones-osd.patch ];
      });
    })
  ];
  nix = {
    channel.enable = false;
    settings.allowed-users = [ user ];
  };
  programs = {
    dconf.enable = true;
    zsh.enable = true;
  };
  services = {
    automatic-timezoned.enable = true;
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
    printing.enable = true;
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        options = "caps:escape";
      };
    };
  };
  time.timeZone = lib.mkForce null;
  users.users.${user} = {
    extraGroups = [
      "docker"
      "networkmanager"
      "wheel"
    ];
    isNormalUser = true;
    shell = pkgs.zsh;
  };
  virtualisation.docker.enable = true;
}
