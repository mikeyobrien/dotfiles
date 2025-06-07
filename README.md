# Dotfiles

Personal dotfiles managed with [yadm](https://yadm.io).

## Installation

```bash
# Install yadm
pkg install yadm  # On Termux
# brew install yadm  # On macOS
# apt install yadm   # On Ubuntu/Debian

# Clone dotfiles
yadm clone git@github.com:mikeyobrien/dotfiles.git
```

## Contents

- `.tmux.conf` - Tmux configuration
- `.gitconfig` - Git configuration
- `.config/fish/` - Fish shell configuration
- `.claude/` - Claude AI assistant configurations and commands

## Usage

```bash
# Check status
yadm status

# Add new dotfiles
yadm add ~/.bashrc
yadm commit -m "Add bashrc"
yadm push

# List tracked files
yadm list -a
```

## Sensitive Files

Sensitive files are managed using yadm's encryption feature. Files listed in `~/.config/yadm/encrypt` are encrypted before committing.