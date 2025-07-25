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
  sharedSystemPackages = import ../shared/system-packages.nix { inherit pkgs; };
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
        consoleMode = "max";
      };
      timeout = null;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "quiet"
      "fbcon=vc:2-6"
      "console=tty0"
    ];
  };
  environment.systemPackages = sharedSystemPackages ++ [
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
    keyd = {
      enable = true;
      keyboards = {
        default = {
          ids = [ "*" ];
          settings = {
            main = {
              capslock = "esc";
              leftalt = "layer(meta)";
              meta = "leftalt";
            };
          };
        };
      };
    };
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
        "docker"
        "networkmanager"
        "wheel"
      ];
      isNormalUser = true;
      shell = pkgs.zsh;
    };
  };
  virtualisation.docker.enable = true;
}
