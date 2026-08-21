{ ... }:
{
  # Lofree Flow Fix
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';

  # NVIDIA Stuff
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = true; # Use latest drivers
    powerManagement.enable = true; # Allows S3 to work
  };

  # Thermalright App
  programs.trcc-linux.enable = true;
}
