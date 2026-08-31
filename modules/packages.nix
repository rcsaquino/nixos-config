{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme # Icons for nautilus
    alacritty
    bun
    catppuccin-cursors.mochaDark
    codex
    gcc
    gnumake
    go
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
    poppler-utils # pdfpp
    python3 # Hydra Launcher
    qimgv # Image viewer
    rustup
    stremio-linux-shell
    telegram-desktop
    uv
    vim
    vlang
    xwayland-satellite # Steam
    zed-editor
    zig
  ];
}
