{
  self,
  config,
  pkgs,
  lib,
  user,
  targetDir,
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
    kernelParams = [
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
    channel.enable = false;
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
  powerManagement.cpuFreqGovernor = "schedutil";
  programs = {
    dconf = {
      enable = true;
      profiles.user.databases = [
        {
          settings = {
            "org/gnome/desktop/datetime".automatic-timezone = true;
            "org/gnome/system/location".enabled = true;
          };
        }
      ];
    };
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
  time.timeZone = lib.mkForce null;
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
