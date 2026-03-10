# KasmVNC + KDE Plasma 6 on CachyOS -- Workaround Notes

## Problem

Running `ska-vnc` (KasmVNC) hit three issues preventing a working KDE Plasma desktop:

1. **Interactive "create user" prompt** -- `kasmvncpasswd` silently failed because the dummy password was only 1 char (minimum is 6). Without `~/.kasmpasswd`, vncserver prompts interactively.
2. **Interactive "select DE" prompt** -- KasmVNC checks for `~/.vnc/.de-was-selected` marker file. Without it, `select-de.sh` runs interactively even though `~/.vnc/xstartup` is already configured.
3. **Polkit "authentication required" dialog** -- VNC sessions have no local seat, so polkit cannot silently authorize `wheel` group actions (NetworkManager, sleep inhibit, etc.). A polkit rule is needed.
4. **Black screen** -- KDE Plasma 6 uses Qt Quick (QML) for all UI rendering (desktop, panel, decorations). KasmVNC's Xvnc does not expose the GLX extension, so Qt Quick's OpenGL backend renders nothing.

## Root Cause

KasmVNC's Xvnc has **no GLX extension**. KDE Plasma 6 / kwin 6 removed the QPainter (software) compositing backend and requires OpenGL. Without GLX, both kwin compositing and plasmashell QML rendering fail silently (black output).

## Fix

Two environment variables in `~/.vnc/xstartup` (symlinked from `config/vnc-xstartup`):

```sh
export QT_QUICK_BACKEND=software    # Qt Quick uses software rasterizer instead of OpenGL
export LIBGL_ALWAYS_SOFTWARE=1      # Mesa fallback to software rendering
```

These are propagated to the systemd user session so all KDE services inherit them:

```sh
systemctl --user import-environment DISPLAY XAUTHORITY XDG_SESSION_TYPE QT_QUICK_BACKEND LIBGL_ALWAYS_SOFTWARE
```

kwin 6 compositing still reports "no OpenGL support" but kwin works as a window manager (decorations, focus, move, resize). plasmashell renders its full QML UI (panel, desktop, system tray) via the Qt software backend.

## What was changed

| File | Change |
|------|--------|
| `config/vnc-xstartup` | Added `QT_QUICK_BACKEND=software` + `LIBGL_ALWAYS_SOFTWARE=1`, propagate to systemd user env |
| `Makefile` (cloud target) | Fixed `kasmvncpasswd` password (6+ chars), added `.de-was-selected` marker, added polkit rule for wheel group |
| `config/aliases` | No change needed (ska-vnc alias was already correct) |
