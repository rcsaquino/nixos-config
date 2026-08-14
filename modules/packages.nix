{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme # Icons for nautilus
    alacritty
    catppuccin-cursors.mochaDark
    google-chrome
    hydralauncher
    mangohud
    nautilus
    nautilus-python # Nautilus "Open in Alacritty/Zed"
    nil # Zed Nix LSP
    nixd # Zed Nix LSP
    nixfmt # Zed Nix LSP
    nodejs
    odin
    opencode
    pi-coding-agent
    python3 # Hydra Launcher
    qimgv
    telegram-desktop
    uv
    vim
    xwayland-satellite # Steam
    zed-editor
  ];
}
