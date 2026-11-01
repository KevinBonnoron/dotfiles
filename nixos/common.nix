# System settings shared by all my NixOS machines.
# This repository is public: anything specific to a machine or to the local
# network (hardware, NAS, printer, firewall…) stays in /etc/nixos.
{ pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  virtualisation.docker.enable = true;
  users.users.kevin.extraGroups = [ "docker" ];

  # Run non-Nix binaries (downloaded tools, editor extensions…).
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      libxcb
      libx11
      libxkbcommon
      libGL
      vulkan-loader
      webkitgtk_4_1
    ];
  };

  # LocalSend needs its port (53317) open in the firewall to receive files.
  programs.localsend.enable = true;

  # Only what must work without Home Manager: root shell, rescue console,
  # editing and rebuilding /etc/nixos. Everything else lives in home/.
  environment.systemPackages = with pkgs; [
    git
    vim
    iw
  ];
}
