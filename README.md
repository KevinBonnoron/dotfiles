# Dotfiles

Personal Git configuration files.

## Contents

- **Git** — aliases, colors, and sensible defaults
- **Ghostty** — terminal emulator configuration
- **Claude Code skills** — reusable slash commands for Claude Code

## Requirements

- [Git](https://git-scm.com/)
- [Claude Code](https://claude.ai/code) *(for skills)*

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

The install script:
- injects `.gitconfig` via `[include]` in `~/.gitconfig`
- symlinks the Ghostty config to `~/.config/ghostty/config` *(Linux/macOS only)*
- links each skill from `dotfiles/skills/*/` into `~/.claude/skills/`

## Skills

Skills are slash commands available in Claude Code (e.g. `/challenge-plan`). Each skill lives in its own directory under `skills/` and is automatically linked during installation.

| Skill | Description |
|---|---|
| `challenge-plan` | Adversarial review of a plan or design — surfaces assumptions, edge cases, and failure modes one question at a time |

To add a skill, create a new directory under `skills/` with a `SKILL.md` file and re-run the install script.

## Git aliases

| Alias | Command |
|---|---|
| `git ll` | `log --oneline` |
| `git amend` | `commit --amend --no-edit` |
| `git undo` | Soft reset last commit |
| `git unstage <file>` | Unstage a file |
| `git cleangone` | Delete local branches removed from remote |
| `git autosquash` | Interactive rebase with autosquash |
