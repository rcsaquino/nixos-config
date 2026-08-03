{ pkgs, ... }: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  hardware.nvidia.open = true;

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
