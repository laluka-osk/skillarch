# Skill-Arch

## How To

```bash
git clone https://github.com/laluka/skillarch
sudo mv skillarch /opt/skillarch && cd /opt/skillarch
make install
```

## Get Help

```text
Welcome to LalukArk! 🌹

Usage: make [target]
Targets:

  help                Show this help message
  install             Install SkillArch
  install-base        Install base packages
  install-system      Install system packages
  install-shell       Install shell packages
  install-docker      Install docker
  install-gui         Install gui, i3, polybar, kitty, rofi, picom
  install-mise        Install mise
  install-goodies     Install goodies
  install-offensive   Install offensive tools
  install-wordlists   Install wordlists
  install-hardening   Install hardening tools
```

## Kudos

> Let's be honest, I put stuff together, but the heavy lifting is done by these true gods 😉

- https://github.com/bernsteining/beep-beep
- https://github.com/CachyOS/cachyos-desktop
- https://github.com/davatorium/rofi
- https://github.com/Hyde-project/hyde
- https://github.com/jluttine/rofi-power-menu
- https://github.com/newmanls/rofi-themes-collection
- https://github.com/orhun/dotfiles
- https://github.com/regolith-linux/regolith-desktop

## TODO BugFix

- mv dotfiles config + refacto name
- Fix vbox copy paste
- Add CICD daily builds
- Alias update: make pull (error out on dirty state, take care of home & main branches only) && make install && make rebase

## TODO Documentation

- Dotfiles management & backups
- Update process
- What's inside (tools, alias, bindings)
- kitty visual select (ctrl+alt+select)
- Document LITE mode (no php, no wordlists)
