{ pkgs, ... }:
{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      efi.canTouchEfiVariables = true;
      timeout = 0;
      systemd-boot.enable = true;
    };
  };

  hardware.bluetooth.enable = true;

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  nix = {
    channel.enable = false;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    optimise.automatic = true;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      extra-substituters = [ "https://noctalia.cachix.org" ];
      extra-trusted-public-keys = [
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
    };
  };
  
  services.gvfs.enable = true; # Network access in nautilus

  time.timeZone = "Asia/Manila";

  users.users.rcsaquino = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
  };

  zramSwap.enable = true;

  system.stateVersion = "26.05"; # DO NOT TOUCH
}
