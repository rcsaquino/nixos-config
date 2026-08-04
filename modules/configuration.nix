{ pkgs, ... }:
{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Lofree Flow Fix
    extraModprobeConfig = ''
      options hid_apple fnmode=2
    '';
  };

  hardware.nvidia.open = true;
  zramSwap.enable = true;
  networking.hostName = "nixos";
  time.timeZone = "Asia/Manila";

  users.users.rcsaquino = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
  };

  services = {
    gvfs.enable = true; # Network access in nautilus
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
    };
  };

  nix = {
    optimise.automatic = true;
    channel.enable = false;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  system.stateVersion = "26.05";
}
