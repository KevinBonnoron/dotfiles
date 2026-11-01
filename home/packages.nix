{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    # LLM
    claude-code
    cursor-cli
    codex

    # Utils
    wl-clipboard
    jq
    unzip
    wget
    killall
    sshfs

    # Dev
    zed-editor
    coder

    # Browsers
    google-chrome
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Others
    spotify
  ];
}
