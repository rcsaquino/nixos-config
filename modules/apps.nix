{ inputs, pkgs, ... }:
{
  imports = [
    inputs.chaotic.nixosModules.default
    inputs.noctalia.nixosModules.default
    inputs.noctalia-greeter.nixosModules.default
    inputs.trcc-linux.nixosModules.default
  ];

  nixpkgs.config = {
    allowUnfree = true;
    allowUnsupportedSystem = true;
  };

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
    noctalia = {
      enable = true;
      recommendedServices.enable = true;
    };
    noctalia-greeter.enable = true;
    steam.enable = true;
    trcc-linux.enable = true;
    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };

  # Enable Proton Cachyos
  system.activationScripts.protonCachyos = {
    deps = [ "users" ];
    text = ''
      target=/home/rcsaquino/.local/share/Steam/compatibilitytools.d/Proton-CachyOS
      ${pkgs.coreutils}/bin/install -d -o rcsaquino -g users "$target"
      ${pkgs.findutils}/bin/find "$target" -type l -delete
      ${pkgs.lndir}/bin/lndir -silent \
        "${pkgs.proton-cachyos_x86_64_v3}/bin" \
        "$target"
      ${pkgs.coreutils}/bin/chown -R --no-dereference rcsaquino:users "$target"
    '';
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
    uv
    vim
    xwayland-satellite # Steam
    zed-editor
  ];
}
