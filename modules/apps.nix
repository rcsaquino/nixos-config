{ pkgs, ... }:
{
  # Allow unfree software
  nixpkgs.config.allowUnfree = true;

  # NixOS Programs
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
    trcc-linux.enable = true;
    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };

  # System Packages
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme # Icons for nautilus
    alacritty
    catppuccin-cursors.mochaDark
    google-chrome
    hydralauncher
    nautilus
    nautilus-python # Nautilus "Open in Alacritty/Zed"
    nil # Zed Nix LSP
    nixd # Zed Nix LSP
    nixfmt # Zed Nix LSP
    odin
    opencode
    python3 # Hydra Launcher
    telegram-desktop
    uv
    vim
    xwayland-satellite # Steam
    zed-editor
  ];
}
