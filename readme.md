# Skill-Arch

## How To

```bash
git clone https://github.com/laluka/skillarch
sudo mv skillarch /opt/skillarch
cd /opt/skillarch
make install
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

## TODO

- fix vbox copy paste
- link ~/config/* to /opt/skillarch/config/*, mv .bak if exists
- omz plugin check before enable (slowww)
- visual select kitty ?

## TODO Later

- Autoinstall curl -sS https://raw.githubusercontent.com/laluka/skillarch/refs/heads/main/autoinstall.sh|bash
- Document aliases & tools
- Add CICD daily builds
- alias update: make pull (error out on dirty state, take care of home & main branches only) && make install && make rebase
