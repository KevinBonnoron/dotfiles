{
  config,
  pkgs,
  inputs,
  ...
}:

let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
  # Live symlink into the repository: edits apply without a rebuild and apps
  # that rewrite their settings (Tern) keep working.
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  imports = [
    inputs.omp.homeManagerModules.default
    ./packages.nix
    ./gnome.nix
  ];

  home.username = "kevin";
  home.homeDirectory = "/home/kevin";
  home.stateVersion = "26.11";

  programs.home-manager.enable = true;

  # Shell
  programs.bash.enable = true;
  home.sessionPath = [
    "$HOME/.opencode/bin"
    "$HOME/.bun/bin"
    "$HOME/.local/bin"
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.omp.enable = true;

  # Git: shared aliases/colors live in ../.gitconfig (also used on Windows/macOS).
  programs.git = {
    enable = true;
    settings.user = {
      name = "Kevin Bonnoron";
      email = "2421321+KevinBonnoron@users.noreply.github.com";
    };
    includes = [ { path = "${dotfiles}/.gitconfig"; } ];
  };

  programs.gh = {
    enable = true;
    settings.aliases.co = "pr checkout";
  };

  # App configs
  xdg.configFile."tern/settings.json".source = link "tern/settings.json";
  # Whole directory, so files Zed rewrites or creates stay in the repository.
  xdg.configFile."zed".source = link "zed";

  # OneDrive sync (Home Manager has no module for it).
  home.packages = [ pkgs.onedrive ];
  systemd.user.services.onedrive = {
    Unit.Description = "OneDrive sync";
    Service = {
      ExecStart = "${pkgs.onedrive}/bin/onedrive --monitor --confdir=%h/.config/onedrive";
      Restart = "on-failure";
      RestartSec = 3;
      RestartPreventExitStatus = 3;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
