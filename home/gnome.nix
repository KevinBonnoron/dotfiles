{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gnome-tweaks
    yaru-theme
    gnomeExtensions.dash-to-dock
  ];

  # Reapplied on every switch: changes made in the GNOME UI are overwritten.
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [ pkgs.gnomeExtensions.dash-to-dock.extensionUuid ];
      favorite-apps = [
        "firefox.desktop"
        "google-chrome.desktop"
        "zen-beta.desktop"
        "org.gnome.Nautilus.desktop"
        "dev.zed.Zed.desktop"
        "spotify.desktop"
        "org.wails.polaris.desktop"
        "discord-ptb.desktop"
        "org.gnome.TextEditor.desktop"
      ];
    };
    "org/gnome/desktop/interface" = {
      icon-theme = "Yaru";
      color-scheme = "prefer-dark";
    };
  };
}
