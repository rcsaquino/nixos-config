{ inputs, pkgs, ... }: {
  imports = [
    inputs.noctalia.nixosModules.default
    inputs.noctalia-greeter.nixosModules.default
    inputs.trcc-linux.nixosModules.default
  ];

  nixpkgs.config = {
    allowUnfree = true;
    allowUnsupportedSystem = true;
  };

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
    # nix-ld.enable = true; # Make uv work
    noctalia = {
      enable = true;
      recommendedServices.enable = true;
    };
    noctalia-greeter.enable = true;
    trcc-linux.enable = true;
    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };

  environment.systemPackages = with pkgs; [
    adwaita-icon-theme # Icons for nautilus
    alacritty
    catppuccin-cursors.mochaDark
    google-chrome
    hydralauncher
    nautilus
    nautilus-python # Allows "Open in Alacritty/Zed" to work
    nil # Zed Nix LSP
    nixd # Zed Nix LSP
    nixfmt # Zed Nix LSP
    notion-app
    odin
    opencode
    rustup
    uv
    vim
    zed-editor
  ];
}
