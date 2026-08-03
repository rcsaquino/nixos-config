{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme # Icons for nautilus
    alacritty
    catppuccin-cursors.mochaDark
    google-chrome
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
