{ inputs, ... }:
{
  imports = [
    inputs.noctalia.nixosModules.default
    inputs.noctalia-greeter.nixosModules.default
  ];

  programs.niri.enable = true;

  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
  };

  programs.noctalia-greeter.enable = true;
  # {
  #   enable = true;
  # settings = {
  #   session.default = "niri";
  #   cursor = {
  #     theme = "catppuccin-mocha-dark-cursors";
  #     size = 24;
  #     path = "${pkgs.catppuccin-cursors.mochaDark}/share/icons";
  #   };
  # };
  # };

  # services.xserver.displayManager.lightdm.enable = false;
}
