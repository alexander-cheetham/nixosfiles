{ config, pkgs, ... }:

let
  base-sddm-astronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = "astronaut";
    themeConfig = {
      Background = config.stylix.image;
      PartialBlur = "true";
      Blur = "4.0";
      BlurMax = "16";
      FullBlur = "false";
      HaveFormBackground = "true";
      FormBackgroundColor = "#21222C";
    };
  };

  custom-sddm-astronaut = base-sddm-astronaut.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.perl ];
    installPhase = ''
      runHook preInstall
      dest="$out/share/sddm/themes/sddm-astronaut-theme"
      mkdir -p "$dest"
      cp -rT . "$dest"
      chmod u+w "$dest/Themes" || true
      themeConf="$dest/Themes/astronaut.conf"
      perl -0pi -e 's|Pane {\n    id: root|Pane {\n    id: root\n    property bool isPrimaryScreen: Screen.name == "DP-1"\n    Component.onCompleted: console.log("[astronaut]", "Screen", Screen.name, "primary", Screen.primary, "DP-1?", root.isPrimaryScreen)|' "$dest/Main.qml"
      perl -0pi -e 's|(Rectangle {\n            id: tintLayer\n)|$1            visible: root.isPrimaryScreen\n\n|' "$dest/Main.qml"
      perl -0pi -e 's|(LoginForm {\n            id: form\n)|$1\n            visible: root.isPrimaryScreen\n|' "$dest/Main.qml"
      perl -0pi -e 's|(Loader {\n            id: virtualKeyboard\n            source: "Components/VirtualKeyboard.qml"\n)|$1\n            visible: root.isPrimaryScreen\n|' "$dest/Main.qml"
      perl -0pi -e 's|visible: config.HaveFormBackground == "true" \? true : false|visible: root.isPrimaryScreen && (config.HaveFormBackground == "true" ? true : false)|' "$dest/Main.qml"
      perl -0pi -e 's#visible: config.FullBlur == "true" \|\| config.PartialBlur == "true" \? true : false#visible: root.isPrimaryScreen && (config.FullBlur == "true" || config.PartialBlur == "true")#g' "$dest/Main.qml"
      perl -0pi -e 's|(Pane {\n    id: root)|$1\n\n    Column {\n        anchors.top: parent.top\n        anchors.left: parent.left\n        spacing: 4\n        visible: true\n\n        Text {\n            color: \"#ffffff\"\n            font.pixelSize: 14\n            text: \"[astronaut] Screen: \" + Screen.name\n        }\n\n        Text {\n            color: \"#ffffff\"\n            font.pixelSize: 14\n            text: \"primary flag: \" + Screen.primary\n        }\n    }\n|' "$dest/Main.qml"
      perl -0pi -e 's|(anchors\.horizontalCenter: parent\.horizontalCenter)|$1\n        font.family: "SF Pro Display Medium"|g' "$dest/Components/Clock.qml"
      perl -0pi -e "s|^Background=.*$|Background=\"${config.stylix.image}\"|m" "$themeConf"
      perl -0pi -e 's|^PartialBlur=.*$|PartialBlur="true"|m' "$themeConf"
      perl -0pi -e 's|^BlurMax=.*$|BlurMax="16"|m' "$themeConf"
      perl -0pi -e 's|^Blur=.*$|Blur="1.0"|m' "$themeConf"
      perl -0pi -e 's|^FullBlur=.*$|FullBlur="false"|m' "$themeConf"
      perl -0pi -e 's|^HaveFormBackground=.*$|HaveFormBackground="true"|m' "$themeConf"
      perl -0pi -e 's|^FormBackgroundColor=.*$|FormBackgroundColor="#21222C"|m' "$themeConf"
      perl -0pi -e 's|^Font=.*$|Font="SF Pro Display Medium"|m' "$themeConf"
      runHook postInstall
    '';
  });

  # 👇 NEW: small helper to preview the greeter/theme in a window
  preview-sddm-astronaut = pkgs.writeShellScriptBin "preview-sddm-astronaut" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # Make fonts/UI sane on HiDPI; tweak or drop if you don't like it
    export QT_SCALE_FACTOR="''${QT_SCALE_FACTOR:-1.0}"

    theme_dir=${custom-sddm-astronaut}/share/sddm/themes/sddm-astronaut-theme
    main_qml=$theme_dir/Main.qml

    echo "[preview] Using theme from: $theme_dir"
    echo "[preview] Checking for primary-screen patches..."
    for marker in \
      'property bool isPrimaryScreen' \
      'visible: root.isPrimaryScreen'
    do
      if grep -nF "$marker" "$main_qml"; then
        echo "[preview] ✓ $marker"
      else
        echo "[preview] ✗ missing: $marker"
      fi
      echo "-----"
    done

    exec ${pkgs.kdePackages.sddm}/bin/sddm-greeter-qt6 \
      --test-mode \
      --theme "$theme_dir"
  '';
in {
  services.greetd.enable = false;

  services.displayManager = {
    defaultSession = "hyprland-uwsm";

    sddm = {
      enable = true;
      wayland.enable = true;
      enableHidpi = true;
      extraPackages = [ custom-sddm-astronaut ];
      setupScript = ''
        ${pkgs.xorg.xrandr}/bin/xrandr \
          --output DP-2 --mode 2560x1440 --rate 143.87 --pos 0x0 \
          --output DP-1 --primary --mode 2560x1440 --rate 143.91 --pos 2560x0 \
          --output HDMI-A-1 --mode 1920x1080 --rate 59.96 --pos 5120x0
      '';

      theme = "${custom-sddm-astronaut}/share/sddm/themes/sddm-astronaut-theme";
      settings.Theme.Current = "sddm-astronaut-theme";
    };
  };

  environment.systemPackages = [
    custom-sddm-astronaut
    pkgs.kdePackages.qtmultimedia
    preview-sddm-astronaut  # 👈 make the helper available
  ];
}
