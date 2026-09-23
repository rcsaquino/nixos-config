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
    steam.enable = true;
    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };

  services.displayManager.noctalia-greeter.enable = true;
}
