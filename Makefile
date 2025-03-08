.PHONY: help
help: ## Show this help message
	@echo 'Welcome to LalukArk! 🌹'
	@echo ''
	@echo 'Usage: make [target]'
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*##"; printf "\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  %-18s %s\n", $$1, $$2 } /^##@/ { printf "\n%s\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo ''

install: install-base install-system install-shell install-docker install-i3 install-polybar install-terminal install-mise install-goodies install-offensive install-hardening ## Install SkillArch
	@echo "You are all set up! Enjoy ! 🌹"

sanity-check:
	@# Ensure we are in /opt/skillarch
	@if [ "$$(pwd)" != "/opt/skillarch" ]; then echo "You must be in /opt/skillarch to run this command"; exit 1; fi	

install-base: sanity-check  ## Install base packages
	echo "installing stuff"
	yes|sudo pacman -Scc
	yes|sudo pacman -Syu
	yes|sudo pacman -S --noconfirm --needed git vim tmux wget curl

install-system: sanity-check  ## Install system packages
	# Long Lived DATA & trash-cli Setup
	if [ ! -d /DATA ]; then sudo mkdir -pv /DATA && sudo chown "$$USER:$$USER" /DATA && sudo chmod 770 /DATA; fi
	if [ ! -d /.Trash ]; then sudo mkdir -pv /.Trash && sudo chown "$$USER:$$USER" /.Trash && sudo chmod 770 /.Trash && sudo chmod +t /.Trash; fi

	# Add chaotic-aur to pacman
	sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
	sudo pacman-key --lsign-key 3056513887B78AEB
	sudo pacman --noconfirm -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
	sudo pacman --noconfirm -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
	
	# Append chaotic-aur lines if not present in /etc/pacman.conf
	grep -vP '\[chaotic-aur\]|Include = /etc/pacman.d/chaotic-mirrorlist' /etc/pacman.conf | sudo tee /etc/pacman.conf > /dev/null
	echo -e '[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist' | sudo tee -a /etc/pacman.conf > /dev/null
	yes|sudo pacman -Syu
	yes|sudo pacman -S vlc-luajit # Must be done before obs-studio-browser to avoid conflicts
	yes|sudo pacman -S --noconfirm --needed arandr base-devel bison blueman bzip2 ca-certificates cheese cloc cmake code code-marketplace discord dos2unix dunst expect ffmpeg filezilla flameshot foremost gdb ghex gnupg google-chrome gparted htop bottom hwinfo icu inotify-tools iproute2 jq kdenlive kompare libreoffice-fresh llvm lsof ltrace make meld mlocate mplayer ncurses net-tools ngrep nmap okular openssh openssl parallel perl-image-exiftool picom pkgconf python-virtualenv qbittorrent re2c readline ripgrep rlwrap socat sqlite sshpass tmate tor torbrowser-launcher traceroute trash-cli tree unzip vbindiff wireshark-qt ghidra xclip xz yay zip dragon-drop-git nomachine obs-studio-browser signal-desktop veracrypt
	sudo systemctl disable --now nxserver.service
	sudo ln -sf /usr/bin/google-chrome-stable /usr/local/bin/gog
	xargs -n1 code --install-extension < dotfiles/extensions.txt
	yay --noconfirm --needed -S fswebcam fastgron cursor-bin
	sudo ln -sf /usr/bin/fastgron /usr/local/bin/fgr
	if [ ! -L ~/.config/picom.conf ]; then mv ~/.config/picom.conf ~/.config/picom.conf.skabak; fi
	ln -sf /opt/skillarch/dotfiles/picom.conf ~/.config/picom.conf

	yay --noconfirm --needed -S python-pipx
	pipx ensurepath
	for package in argcomplete bypass-url-parser dirsearch exegol pre-commit sqlmap wafw00f yt-dlp semgrep; do pipx install "$$package" && pipx inject "$$package" setuptools; done

install-shell: sanity-check  ## Install shell packages
	# Install and Configure zsh and oh-my-zsh
	yes|sudo pacman -S --noconfirm --needed zsh zsh-completions zsh-syntax-highlighting zsh-autosuggestions zsh-history-substring-search zsh-theme-powerlevel10k
	if [ ! -d ~/.oh-my-zsh ]; then sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; fi
	if [ ! -L ~/.zshrc ]; then mv ~/.zshrc ~/.zshrc.skabak; fi
	ln -sf /opt/skillarch/dotfiles/zshrc ~/.zshrc
	if [ ! -d ~/.oh-my-zsh/plugins/zsh-completions ]; then git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/plugins/zsh-completions; fi
	if [ ! -d ~/.oh-my-zsh/plugins/zsh-autosuggestions ]; then git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions; fi
	if [ ! -d ~/.oh-my-zsh/plugins/zsh-syntax-highlighting ]; then git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/plugins/zsh-syntax-highlighting; fi
	for plugin in aws colored-man-pages docker extract fzf mise npm terraform tmux zsh-autosuggestions zsh-completions zsh-syntax-highlighting ssh-agent; do zsh -c "source ~/.zshrc && omz plugin enable $$plugin || true"; done

	# Install and configure fzf, tmux, vim
	if [ ! -d ~/.fzf ]; then git clone --depth 1 https://github.com/junegunn/fzf ~/.fzf && ~/.fzf/install --all; fi
	if [ ! -L ~/.tmux.conf ]; then mv ~/.tmux.conf ~/.tmux.conf.skabak; fi
	ln -sf /opt/skillarch/dotfiles/tmux.conf ~/.tmux.conf
	if [ ! -L ~/.vimrc ]; then mv ~/.vimrc ~/.vimrc.skabak; fi
	ln -sf /opt/skillarch/dotfiles/vimrc ~/.vimrc

	# Set the default user shell to zsh
	sudo chsh -s /usr/bin/zsh "$$USER" # Logout required to be applied

install-docker: sanity-check  ## Install docker
	yes|sudo pacman -S --noconfirm --needed docker docker-compose
	# It's a desktop machine, don't expose stuff, but we don't care much about LPE
	# Think about it, set "alias sudo='backdoor ; sudo'" in userland and voila. OSEF!
	sudo usermod -aG docker "$$USER" # Logout required to be applied
	sudo systemctl enable docker
	sudo systemctl start docker

install-i3: sanity-check  ## Install i3
	yes|sudo pacman -S --noconfirm --needed i3-gaps i3blocks i3lock i3lock-fancy-git i3status dmenu feh rofi nm-connection-editor
	yay --noconfirm --needed -S rofi-power-menu
	gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
	if [ ! -d ~/.config/i3 ]; then mkdir -p ~/.config/i3; fi
	if [ ! -L ~/.config/i3/config ]; then mv ~/.config/i3/config ~/.config/i3/config.skabak; fi
	ln -sf /opt/skillarch/dotfiles/i3/config ~/.config/i3/config
	if [ ! -d ~/.config/rofi ]; then mkdir -p ~/.config/rofi; fi
	if [ ! -L ~/.config/rofi/config.rasi ]; then mv ~/.config/rofi/config.rasi ~/.config/rofi/config.rasi.skabak; fi
	ln -sf /opt/skillarch/dotfiles/rofi/config.rasi ~/.config/rofi/config.rasi

	# Touchpad Config, might be improved to avoid touchpad loss
	if [ ! -L /etc/X11/xorg.conf.d/30-touchpad.conf ]; then sudo mv /etc/X11/xorg.conf.d/30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf.skabak; fi
	sudo ln -sf /opt/skillarch/dotfiles/xorg.conf.d/30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf

install-polybar: sanity-check  ## Install polybar
	yes|sudo pacman -S --noconfirm --needed polybar
	if [ ! -d ~/.config/polybar ]; then mkdir -p ~/.config/polybar; fi
	if [ ! -L ~/.config/polybar/config.ini ]; then mv ~/.config/polybar/config.ini ~/.config/polybar/config.ini.skabak; fi
	ln -sf /opt/skillarch/dotfiles/polybar/config.ini ~/.config/polybar/config.ini

install-terminal: sanity-check  ## Install terminal
	yes|sudo pacman -S --noconfirm --needed kitty
	if [ ! -d ~/.config/kitty ]; then mkdir -p ~/.config/kitty; fi
	if [ ! -L ~/.config/kitty/kitty.conf ]; then mv ~/.config/kitty/kitty.conf ~/.config/kitty/kitty.conf.skabak; fi
	ln -sf /opt/skillarch/dotfiles/kitty/kitty.conf ~/.config/kitty/kitty.conf

install-mise: sanity-check  ## Install mise
	# Install mise and all php-build dependencies
	yes|sudo pacman -S --noconfirm --needed mise libedit libffi libjpeg-turbo libpcap libpng libxml2 libzip postgresql-libs
	mise use -g usage@latest
	for package in pdm rust terraform golang python nodejs; do mise use -g "$$package@latest"; done
	mise exec -- go env -w "GOPATH=/home/$$USER/.local/go"
	# Install libs to build current latest, aka php 8.4.4
	yes|sudo pacman -S --noconfirm --needed libedit libffi libjpeg-turbo libpcap libpng libxml2 libzip postgresql-libs
	# TODO uncomment me
	# mise use -g php@latest

install-goodies: sanity-check  ## Install goodies
	yes|sudo pacman -S --noconfirm --needed git-delta bottom  viu xsv jq asciinema htmlq neovim glow jless websocat superfile discord
	if [ ! -d ~/.config/nvim ]; then git clone https://github.com/LazyVim/starter ~/.config/nvim; fi
	if [ ! -d ~/.config/nvim/lua/user ]; then mkdir -p ~/.config/nvim/lua/user; fi
	if [ ! -L ~/.config/nvim/init.lua ]; then mv ~/.config/nvim/init.lua ~/.config/nvim/init.lua.skabak; fi
	ln -sf /opt/skillarch/dotfiles/nvim/init.lua ~/.config/nvim/init.lua

install-offensive: sanity-check  ## Install offensive tools
	yes|sudo pacman -S --noconfirm --needed metasploit burpsuite fx lazygit fq
	yay --noconfirm --needed -S ffuf gau pdtm-bin waybackurls
	
	mise exec -- go install github.com/sw33tLie/sns@latest
	mise exec -- go install github.com/glitchedgitz/cook/v2/cmd/cook@latest
	mise exec -- go install github.com/x90skysn3k/brutespray@latest
	zsh -c "source ~/.zshrc && pdtm -install-all -v"
	zsh -c "source ~/.zshrc && nuclei -update-templates -update-template-dir ~/.nuclei-templates"; \
	
	# Clone custom tools
	# TODO uncomment me
	if [ ! -d /opt/chisel ]; then git clone https://github.com/jpillora/chisel && sudo mv chisel /opt/chisel; fi
	# if [ ! -d /opt/phpggc ]; then git clone https://github.com/ambionics/phpggc && sudo mv phpggc /opt/phpggc; fi
	# if [ ! -d /opt/PyFuscation ]; then git clone https://github.com/CBHue/PyFuscation && sudo mv PyFuscation /opt/PyFuscation; fi
	# if [ ! -d /opt/CloudFlair ]; then git clone https://github.com/christophetd/CloudFlair && sudo mv CloudFlair /opt/CloudFlair; fi
	# if [ ! -d /opt/minos-static ]; then git clone https://github.com/minos-org/minos-static && sudo mv minos-static /opt/minos-static; fi
	# if [ ! -d /opt/exploit-database ]; then git clone https://github.com/offensive-security/exploit-database && sudo mv exploit-database /opt/exploit-database; fi
	# if [ ! -d /opt/exploitdb ]; then git clone https://gitlab.com/exploit-database/exploitdb && sudo mv exploitdb /opt/exploitdb; fi
	# if [ ! -d /opt/pty4all ]; then git clone https://github.com/laluka/pty4all && sudo mv pty4all /opt/pty4all; fi
	# if [ ! -d /opt/pypotomux ]; then git clone https://github.com/laluka/pypotomux && sudo mv pypotomux /opt/pypotomux; fi
	
	# Clone wordlists
	# TODO uncomment me
	if [ ! -d /opt/lists ]; then mkdir /tmp/lists && sudo mv /tmp/lists /opt/lists; fi
	if [ ! -f /opt/lists/rockyou.txt ]; then curl -L https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt -o /opt/lists/rockyou.txt; fi
	# if [ ! -d /opt/lists/PayloadsAllTheThings ]; then git clone https://github.com/swisskyrepo/PayloadsAllTheThings /opt/lists/PayloadsAllTheThings ; fi
	# if [ ! -d /opt/lists/fuzzing-templates ]; then git clone https://github.com/projectdiscovery/fuzzing-templates /opt/lists/fuzzing-templates ; fi
	# if [ ! -d /opt/lists/BruteX ]; then git clone https://github.com/1N3/BruteX /opt/lists/BruteX ; fi
	# if [ ! -d /opt/lists/IntruderPayloads ]; then git clone https://github.com/1N3/IntruderPayloads /opt/lists/IntruderPayloads ; fi
	# if [ ! -d /opt/lists/Probable-Wordlists ]; then git clone https://github.com/berzerk0/Probable-Wordlists /opt/lists/Probable-Wordlists ; fi
	# if [ ! -d /opt/lists/Open-Redirect-Payloads ]; then git clone https://github.com/cujanovic/Open-Redirect-Payloads /opt/lists/Open-Redirect-Payloads ; fi
	# if [ ! -d /opt/lists/SecLists ]; then git clone https://github.com/danielmiessler/SecLists /opt/lists/SecLists ; fi
	# if [ ! -d /opt/lists/Pwdb-Public ]; then git clone https://github.com/ignis-sec/Pwdb-Public /opt/lists/Pwdb-Public ; fi
	# if [ ! -d /opt/lists/Bug-Bounty-Wordlists ]; then git clone https://github.com/Karanxa/Bug-Bounty-Wordlists /opt/lists/Bug-Bounty-Wordlists ; fi
	# if [ ! -d /opt/lists/richelieu ]; then git clone https://github.com/tarraschk/richelieu /opt/lists/richelieu ; fi
	# if [ ! -d /opt/lists/webapp-wordlists ]; then git clone https://github.com/p0dalirius/webapp-wordlists /opt/lists/webapp-wordlists ; fi

install-hardening: sanity-check  ## Install hardening tools
	yes|sudo pacman -S --noconfirm --needed opensnitch
	# OPT-IN opensnitch as an egress firewall
	# sudo systemctl enable --now opensnitchd.service
