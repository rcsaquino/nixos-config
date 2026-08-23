{ pkgs, ... }:
let
  notionIcon = pkgs.fetchurl {
    url = "https://upload.wikimedia.org/wikipedia/commons/e/e9/Notion-logo.svg?utm_source=commons.wikimedia.org&utm_campaign=index&utm_content=original";
    hash = "sha256-G1KhhdgWbZM59cFt1ReJ7jD0mmW01Ac4KQtgQj4zEWA=";
  };
  suspendMode = pkgs.writeShellScriptBin "suspend-mode" (
    builtins.readFile ../scripts/suspend-mode/suspend-mode.sh
  );
in
{
  environment = {
    sessionVariables.PROTONPATH = "${pkgs.proton-cachyos_x86_64_v3}/bin"; # Hydra Launcher
    systemPackages = with pkgs; [
      suspendMode # Noctalia sleep

      # Viber
      (viber.overrideAttrs (oldAttrs: {
        postInstall = (oldAttrs.postInstall or "") + ''
          sed -i -E \
            's|^Exec=(.*)$|Exec=env FONTCONFIG_FILE=${../assets/viber-font.conf} \1|' \
            $out/share/applications/viber.desktop
        '';
      }))

      # Notion
      (makeDesktopItem {
        name = "notion";
        desktopName = "Notion";
        genericName = "Notes and workspace";
        exec = "${google-chrome}/bin/google-chrome-stable --app=https://app.notion.com/";
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

  # Remove Window Decorations
  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        settings = {
          "org/gnome/desktop/wm/preferences" = {
            button-layout = ":";
          };
        };
      }
    ];
  };

  # Noctalia sleep
  security.sudo.extraRules = [
    {
      users = [ "rcsaquino" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/suspend-mode";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
