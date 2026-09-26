{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme # Icons for nautilus
    alacritty
    aria2
    bun
    catppuccin-cursors.mochaDark
    gcc
    gnumake
    go
    google-chrome
    hydralauncher
    hyperfine
    mangohud
    mpv
    nautilus
    nautilus-python # Nautilus "Open in Alacritty/Zed"
    nil # Zed Nix LSP
    nixd # Zed Nix LSP
    nixfmt # Zed Nix LSP
    nodejs
    odin
    poppler-utils # pdfpp
    protonup-rs
    python3 # Hydra Launcher
    qimgv # Image viewer
    rustup
    stremio-linux-shell
    telegram-desktop
    uv
    vim
    vlang
    wl-clipboard # Pi Agent
    xwayland-satellite # Steam
    zed-editor
  ];
}
