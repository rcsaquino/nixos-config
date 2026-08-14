{ pkgs, ... }:
{
  programs = {
    fish.enable = true;
    git = {
      enable = true;
      config = {
        user.name = "rcsaquino";
        user.email = "rcsaquino.md@gmail.com";
      };
    };
    niri.enable = true;
    nix-ld.enable = true; # Make uv work
    noctalia.enable = true;
    noctalia-greeter.enable = true;
    steam = {
      enable = true;
      extraCompatPackages = [
        pkgs.proton-cachyos_x86_64_v3
      ];
    };
    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
