{
  config,
  pkgs,
  lib,
  user,
  ...
}:
let
  shared-system-packages = import ../shared/system-packages.nix { inherit pkgs; };
in
{
  imports = [
    ../shared
    ./home-manager.nix
    ../../hardware.nix
  ];
  boot = {
    consoleLogLevel = 0;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 1;
      };
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = lib.mkForce [
      "quiet"
      "fbcon=vc:2-6"
      "console=tty0"
    ];
  };
  environment.systemPackages = shared-system-packages ++ [
  ];
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };
  nix = {
    nixPath = [ "nixos-config=/etc/nixos/.nix-config:/etc/nixos" ];
    settings = {
      allowed-users = [ "${user}" ];
      trusted-users = [
        "@admin"
        "${user}"
      ];
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  programs = {
    zsh.enable = true;
  };
  services = {
    automatic-timezoned.enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
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
  system.stateVersion = "21.05";
  users.users = {
    ${user} = {
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      isNormalUser = true;
      shell = pkgs.zsh;
    };
  };
}
