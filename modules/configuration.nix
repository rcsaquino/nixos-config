{ pkgs, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  nixpkgs.config = {
    allowUnfree = true;
    allowUnsupportedSystem = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;

  networking.hostName = "nixos";

  time.timeZone = "Asia/Manila";

  services.xserver.enable = true;

  programs.fish.enable = true;

  users.users.rcsaquino = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
  };

  programs.zoxide.enable = true;
  programs.zoxide.enableFishIntegration = true;

  programs.git = {
    enable = true;
    config = {
      user.name = "rcsaquino";
      user.email = "rcsaquino.md@gmail.com";
    };
  };

  programs.nix-ld.enable = true; # Make uv work
  services.gvfs.enable = true; # Network access in nautilus

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
