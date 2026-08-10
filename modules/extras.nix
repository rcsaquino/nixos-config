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
    sessionVariables.PROTONPATH = "${pkgs.proton-cachyos_x86_64_v3}/bin"; # For Hydra Launcher
    systemPackages = with pkgs; [
      suspendMode # Noctalia sleep

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

      # Viber
      (pkgs.buildFHSEnv {
        name = "viber";
        targetPkgs =
          pkgs: with pkgs; [
            (viber.overrideAttrs (old: {
              src = fetchurl {
                url = "https://download.cdn.viber.com/cdn/desktop/Linux/viber.deb";
                hash = "sha256-lhU03Ay5IABux66BCLDhugmkdu7x4TtLNwp5zVLdIPM=";
              };
              postFixup = (old.postFixup or "") + ''
                rm -f $out/opt/viber/lib/libxml2.so.2
                ln -s ${libxml2_13.out}/lib/libxml2.so.2 $out/opt/viber/lib/libxml2.so.2
              '';
            }))
            libxshmfence
            libxcb-cursor
            xcbutil
            pipewire
            fontconfig
            freetype
            noto-fonts
            noto-fonts-cjk-sans
            dejavu_fonts
          ];
        runScript = "viber";
        profile = ''
          export QT_QPA_PLATFORM=xcb
          export QT_QPA_FONTDIR=${pkgs.noto-fonts}/share/fonts
          export FONTCONFIG_FILE=${pkgs.fontconfig.out}/etc/fonts/fonts.conf
        '';
        extraInstallCommands = ''
          mkdir -p $out/share/applications $out/share/icons
          cp ${pkgs.viber}/share/applications/viber.desktop $out/share/applications/
          sed -i 's|^Exec=.*|Exec=viber %u|' $out/share/applications/viber.desktop
          sed -i '/^Path=/d' $out/share/applications/viber.desktop || true
          if [ -d ${pkgs.viber}/share/icons ]; then
            cp -r ${pkgs.viber}/share/icons/* $out/share/icons/
          fi
          if [ -d ${pkgs.viber}/share/pixmaps ]; then
            mkdir -p $out/share/pixmaps
            cp -r ${pkgs.viber}/share/pixmaps/* $out/share/pixmaps/ || true
          fi
        '';
      })
    ];
  };

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
