# Dotfiles

Dotfiles are managed via yadm.

Run following to setup system with latest
```
~/.local/bin/yadm clone https://github.com/DoomHammer/dotfiles.git
~/.local/bin/yadm restore --staged $HOME
~/.local/bin/yadm checkout -- $HOME
~/.local/bin/yadm bootstrap
rm -rf ~/.local/bin/yadm
```
