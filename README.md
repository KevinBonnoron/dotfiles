# Dotfiles

Personal configuration files, plus a Nix flake for NixOS machines.

## Contents

- **Git** — aliases, colors, and sensible defaults
- **Zen** — browser preferences (`user.js`) and keyboard shortcuts
- **Tern** — terminal settings
- **Zed** — editor settings
- **Nix** — Home Manager environment (`home/`) and shared NixOS module (`nixos/common.nix`)

## Requirements

- [Git](https://git-scm.com/)

## Installation

The repo must be cloned at `~/dotfiles`:

```bash
git clone https://github.com/KevinBonnoron/dotfiles.git ~/dotfiles
```

### Linux / macOS / NixOS

```bash
cd ~/dotfiles
bash install.sh
```

### NixOS (Home Manager)

On NixOS, `install.sh` applies the Home Manager configuration (pinned by
`flake.lock`) instead of linking files itself: it installs the user packages and
links the Git, Tern and Zed configs (live symlinks into `~/dotfiles`).
Conflicting files are backed up with the `.hm-bak` extension. Afterwards,
`home-manager switch --flake ~/dotfiles` applies changes.

Git identity and the `gh` credential helper are set by Home Manager in
`~/.config/git/config`; remove any existing `~/.gitconfig` so it does not
override them.

System-wide settings shared by every machine (flakes, Docker, nix-ld, admin
tools) live in `nixos/common.nix`. Each machine imports it from its own
`/etc/nixos/flake.nix`:

```nix
inputs.dotfiles = {
  url = "github:KevinBonnoron/dotfiles";
  inputs.nixpkgs.follows = "nixpkgs";
};
# modules = [ dotfiles.nixosModules.default ./configuration.nix ];
```

This repository is public: machine- and network-specific settings (hardware
quirks, NAS mounts, printers, firewall, apps only wanted on one machine) stay in
`/etc/nixos`. After changing `nixos/common.nix`, push, then run
`nix flake update dotfiles` in `/etc/nixos` before rebuilding.

### Windows (PowerShell as Administrator)

```powershell
cd $HOME\dotfiles
.\install.ps1
```

The scripts inject `.gitconfig` via `[include]` in `~/.gitconfig` and link Tern's
`settings.json` into its configuration directory: `~/.config/tern` on Linux,
`~/Library/Application Support/Tern` on macOS, or `%APPDATA%\Tern` on Windows.
`TERN_CONFIG_DIR`, if set, overrides this location; Linux also respects
`XDG_CONFIG_HOME`. Existing Tern settings are backed up as `settings.json.bak`;
installation stops rather than overwriting an existing backup. Tern credentials
and host keys remain local and are not included in this repository.

The whole `zed/` directory is linked to Zed's configuration directory
(`~/.config/zed` on Linux/macOS, `%APPDATA%\Zed` on Windows), so files Zed
rewrites or creates stay in the repository; its own backups and temporary files
are ignored by `zed/.gitignore`. An existing directory is backed up as `zed.bak`.

The scripts also link `zen/user.js` and `zen/zen-keyboard-shortcuts.json` into
the default Zen profile, found through `profiles.ini` (`~/.config/zen` or
`~/.zen` on Linux, `~/Library/Application Support/zen` on macOS,
`%APPDATA%\zen` on Windows); start Zen once beforehand so the profile exists.
This also runs on NixOS, since the profile directory is only known at runtime.
`user.js` is applied at every Zen startup and overrides changes made in the UI;
shortcut changes made in Zen are written back into the repository. Other
profile data (history, sessions, containers, passwords) stays local.

## Git aliases

| Alias | Command |
|---|---|
| `git ll` | Commits not yet on `origin/HEAD` (`log --oneline origin/HEAD..`) |
| `git amend` | `commit --amend --no-edit` |
| `git fixup <commit>` | Fixup commit, then autosquash rebase onto `origin/HEAD` |
| `git undo` | Soft reset last commit |
| `git prune-gone [-n] [-f]` | Delete local branches whose upstream is gone (`-f`: also branches without upstream, `-n`: dry run); never the default branch or a branch checked out in a worktree |
