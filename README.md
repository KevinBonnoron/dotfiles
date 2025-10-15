# Dotfiles

Personal Git configuration files.

## Contents

- **Git** — aliases, colors, and sensible defaults

## Requirements

- [Git](https://git-scm.com/)

## Installation

The repo must be cloned at `~/dotfiles`:

```bash
git clone https://github.com/your-username/dotfiles.git ~/dotfiles
```

### Linux / macOS

```bash
cd ~/dotfiles
bash install.sh
```

### Windows (PowerShell as Administrator)

```powershell
cd $HOME\dotfiles
.\install.ps1
```

The script injects the `.gitconfig` via `[include]` in `~/.gitconfig`.

## Git aliases

| Alias | Command |
|---|---|
| `git ll` | `log --oneline` |
| `git amend` | `commit --amend --no-edit` |
| `git undo` | Soft reset last commit |
| `git unstage <file>` | Unstage a file |
| `git cleangone` | Delete local branches removed from remote |
| `git autosquash` | Interactive rebase with autosquash |
