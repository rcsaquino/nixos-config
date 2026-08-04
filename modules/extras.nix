{ inputs, pkgs, ... }:
let
  notionIcon = pkgs.fetchurl {
    url = "https://upload.wikimedia.org/wikipedia/commons/e/e9/Notion-logo.svg?utm_source=commons.wikimedia.org&utm_campaign=index&utm_content=original";
    sha256 = "sha256-G1KhhdgWbZM59cFt1ReJ7jD0mmW01Ac4KQtgQj4zEWA=";
  };
in
{
  imports = [
    inputs.chaotic.nixosModules.default
  ];

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

  environment.systemPackages = with pkgs; [
    # Notion
    (makeDesktopItem {
      name = "notion";
      desktopName = "Notion";
      genericName = "Notes and workspace";
      exec = "${google-chrome}/bin/google-chrome-stable --app=https://app.notion.com/";
      # icon = "/home/rcsaquino/nixos-config/assets/icons/notion.svg";
      icon = "${notionIcon}";
      terminal = false;
      categories = [ "Office" ];
      keywords = [
        "notes"
        "workspace"
      ];
    })
  ];
}
