{ pkgs, ... }:
{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      efi.canTouchEfiVariables = true;
      timeout = 0;
      systemd-boot.enable = true;
    };

    # Lofree Flow Fix
    extraModprobeConfig = ''
      options hid_apple fnmode=2
    '';
  };

  hardware = {
    bluetooth.enable = true;
    nvidia = {
      open = true; # Use latest drivers
      powerManagement.enable = true; # Allows S3 to work # opencode -s ses_02a98ea60ffeMBvmVSRFhw9k46
    };
  };

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  nix = {
    channel.enable = false;
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 14d";
    };
    optimise.automatic = true;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  services = {
    gvfs.enable = true; # Network access in nautilus
    xserver.videoDrivers = [ "nvidia" ];
  };

  time.timeZone = "Asia/Manila";

  users.users.rcsaquino = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
  };

  zramSwap.enable = true;

  system.stateVersion = "26.05"; # DO NOT TOUCH
}
