{ pkgs, ... }:
let
  notionIcon = pkgs.fetchurl {
    url = "https://upload.wikimedia.org/wikipedia/commons/e/e9/Notion-logo.svg?utm_source=commons.wikimedia.org&utm_campaign=index&utm_content=original";
    hash = "sha256-G1KhhdgWbZM59cFt1ReJ7jD0mmW01Ac4KQtgQj4zEWA=";
  };
in
{
  environment = {
    sessionVariables.PROTONPATH = "${pkgs.proton-cachyos_x86_64_v3}/bin"; # Use Proton CachyOS by default
    systemPackages = with pkgs; [
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
  };
}
