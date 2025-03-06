.PHONY: help
help: ## Show this help message
	@echo 'Welcome to LalukArk! 🌹'
	@echo ''
	@echo 'Usage: make [target]'
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*##"; printf "\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  %-18s %s\n", $$1, $$2 } /^##@/ { printf "\n%s\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo ''

sanity-check: ## Simple sanity check
	@# Ensure we are in /opt/lalucachy
	@if [ "$$(pwd)" != "/opt/lalucachy" ]; then \
		echo "You must be in /opt/lalucachy to run this command"; \
		exit 1; \
	fi	

install-base: sanity-check  ## Install base packages
	echo "installing stuff"
	sudo pacman --noconfirm --needed -Syu
	sudo pacman --noconfirm --needed -S git vim tmux wget curl

install-system: sanity-check  ## Install system packages
	# Long lived data
	if [ ! -d /DATA ]; then \
		mkdir -pv /tmp/DATA; \
		sudo mv /tmp/DATA /DATA; \
	fi

	# Trash-bin per volume
	if [ ! -d /DATA/.Trash ]; then \
		mkdir -pv /tmp/.Trash/1000; \
		sudo mv /tmp/.Trash /.Trash; \
		sudo chmod +t /.Trash; \
	fi

	# Add chaotic-aur to pacman
	sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
	sudo pacman-key --lsign-key 3056513887B78AEB
	sudo pacman --noconfirm --needed -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
	sudo pacman --noconfirm --needed -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
	
	# Append chaotic-aur lines if not present in /etc/pacman.conf
	if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then \
		echo -e "[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist\n# Add your custom config here" | cat - /etc/pacman.conf > temp; \
		mv temp /etc/pacman.conf; \
	fi
	
	sudo pacman --noconfirm --needed -S arandr base-devel bison blueman bzip2 ca-certificates cheese cloc cmake code code-marketplace discord dos2unix dunst expect ffmpeg filezilla flameshot foremost gdb ghex gnupg google-chrome gparted htop bottom hwinfo icu inotify-tools iproute2 jq kdenlive kompare libreoffice-fresh llvm lsof ltrace make meld mlocate mplayer ncurses net-tools ngrep nmap okular openssh openssl parallel perl-image-exiftool picom pkgconf python-virtualenv qbittorrent re2c readline ripgrep rlwrap socat sqlite sshpass tmate tor torbrowser-launcher traceroute trash-cli tree unzip vbindiff vlc-luajit wireshark-qt ghidra xclip xz yay zip dragon-drop-git nomachine cachyos/obs-studio-browser signal-desktop veracrypt
	sudo ln -sf /usr/bin/google-chrome-stable /usr/local/bin/gog
	code --install-extension bibhasdn.unique-lines
	code --install-extension eriklynd.json-tools
	code --install-extension mechatroner.rainbow-csv
	code --install-extension mitchdenny.ecdc
	code --install-extension ms-azuretools.vscode-docker
	code --install-extension ms-python.debugpy
	code --install-extension ms-python.python
	code --install-extension ms-python.vscode-pylance
	code --install-extension ms-vscode-remote.remote-containers
	code --install-extension ms-vscode-remote.remote-ssh
	code --install-extension ms-vscode-remote.remote-ssh-edit
	code --install-extension ms-vscode.remote-explorer
	code --install-extension ms-vsliveshare.vsliveshare
	code --install-extension trailofbits.weaudit
	code --install-extension yzane.markdown-pdf
	code --install-extension zobo.php-intellisense
	yay --noconfirm --needed -S cursor-bin fswebcam fastgron
	sudo ln -sf /usr/bin/fastgron /usr/local/bin/fgr
	if [ ! -f ~/.config/picom.conf ]; then \
		touch ~/.config/picom.conf; \
	fi
	if ! grep -q "@include \"/opt/lalucachy/dotfiles/picom.conf\"" ~/.config/picom.conf; then \
		echo -e "@include \"/opt/lalucachy/dotfiles/picom.conf\"\n# Add your custom config here" | cat - ~/.config/picom.conf > temp; \
		mv temp ~/.config/picom.conf; \
	fi
	yay --noconfirm --needed -S python-pipx
	pipx ensurepath
	for package in argcomplete bypass-url-parser dirsearch exegol pre-commit sqlmap wafw00f yt-dlp semgrep; do \
		pipx install "$$package"; \
		pipx inject "$$package" setuptools; \
	done

install-shell: sanity-check  ## Install shell packages
	sudo pacman --noconfirm --needed -S zsh zsh-completions zsh-syntax-highlighting zsh-autosuggestions zsh-history-substring-search zsh-theme-powerlevel10k
	# Install oh-my-zsh if not already installed
	if [ ! -d ~/.oh-my-zsh ]; then \
		sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; \
	fi
	
	# if "source /opt/lalucachy/dotfiles/zshrc" is not in ~/.zshrc, add it
	if ! grep -q "source /opt/lalucachy/dotfiles/zshrc" ~/.zshrc; then \
		echo -e "source /opt/lalucachy/dotfiles/zshrc\n# Add your custom config here" | cat - ~/.zshrc > temp; \
		mv temp ~/.zshrc; \
	fi
	
	if [ ! -d ~/.oh-my-zsh/plugins/zsh-completions ]; then \
		git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/plugins/zsh-completions; \
	fi
	if [ ! -d ~/.oh-my-zsh/plugins/zsh-autosuggestions ]; then \
		git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions; \
	fi
	if [ ! -d ~/.oh-my-zsh/plugins/zsh-syntax-highlighting ]; then \
		git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/plugins/zsh-syntax-highlighting; \
	fi
	
	# Install and configure fzf
	if [ ! -d ~/.fzf ]; then \
		git clone --depth 1 https://github.com/junegunn/fzf ~/.fzf && \
		~/.fzf/install --all; \
	fi
	
	if [ ! -f ~/.tmux.conf ]; then \
		touch ~/.tmux.conf; \
	fi

	if ! grep -q "source-file /opt/lalucachy/dotfiles/tmux.conf" ~/.tmux.conf; then \
		echo -e "source-file /opt/lalucachy/dotfiles/tmux.conf\n# Add your custom config here" | cat - ~/.tmux.conf > temp; \
		mv temp ~/.tmux.conf; \
	fi

	for plugin in aws colored-man-pages docker extract fzf mise npm terraform tmux zsh-autosuggestions zsh-completions zsh-syntax-highlighting; do \
		zsh -c "source ~/.zshrc && omz plugin enable $$plugin || true"; \
	done

	if [ ! -f ~/.vimrc ]; then \
		touch ~/.vimrc; \
	fi

	if ! grep -q "source /opt/lalucachy/dotfiles/vimrc" ~/.vimrc; then \
		echo -e "source /opt/lalucachy/dotfiles/vimrc\n# Add your custom config here" | cat - ~/.vimrc > temp; \
		mv temp ~/.vimrc; \
	fi

install-docker: sanity-check  ## Install docker
	sudo pacman --noconfirm --needed -S docker docker-compose
	sudo usermod -aG docker "$$USER"
	sudo systemctl enable docker
	sudo systemctl start docker

install-i3: sanity-check  ## Install i3
	sudo pacman --noconfirm --needed -S i3-gaps i3blocks i3lock i3lock-fancy-git i3status dmenu feh rofi
	gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
	# If /home/lalu/.config/i3/config doesnt exist, create it
	if [ ! -f ~/.config/i3/config ]; then \
		mkdir -p ~/.config/i3; \
		touch ~/.config/i3/config; \
	fi

	# If "include /opt/lalucachy/dotfiles/i3/config" not in /home/lalu/.config/i3/config, add it as the first line
	if ! grep -q "include /opt/lalucachy/dotfiles/i3/config" ~/.config/i3/config; then \
		echo -e "include /opt/lalucachy/dotfiles/i3/config\n# Add your custom config here" | cat - ~/.config/i3/config > temp; \
		mv temp ~/.config/i3/config; \
	fi

	if [ ! -f ~/.config/rofi/config.rasi ]; then \
		mkdir -p ~/.config/rofi; \
		touch ~/.config/rofi/config.rasi; \
	fi

	# If "@theme \"/opt/lalucachy/dotfiles/rofi/spotlight-dark.rasi\"" not in ~/.config/rofi/config.rasi, add it as the first line
	if ! grep -q "@theme \"/opt/lalucachy/dotfiles/rofi/spotlight-dark.rasi\"" ~/.config/rofi/config.rasi; then \
		echo -e "@theme \"/opt/lalucachy/dotfiles/rofi/spotlight-dark.rasi\"\n// Add your custom config here" | cat - ~/.config/rofi/config.rasi > temp; \
		mv temp ~/.config/rofi/config.rasi; \
	fi

	if [ ! -f /etc/X11/xorg.conf.d/30-touchpad.conf ]; then \
		sudo cp /opt/lalucachy/dotfiles/30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf; \
	fi

install-polybar: sanity-check  ## Install polybar
	sudo pacman --noconfirm --needed -S polybar

	# If ~/.config/polybar/config.ini doesnt exist, create it
	if [ ! -f ~/.config/polybar/config.ini ]; then \
		mkdir -p ~/.config/polybar; \
		touch ~/.config/polybar/config.ini; \
	fi
	# If "include-file = /opt/lalucachy/dotfiles/polybar/config.ini" not in ~/.config/polybar/config.ini, add it as the first line
	if ! grep -q "include-file = /opt/lalucachy/dotfiles/polybar/config.ini" ~/.config/polybar/config.ini; then \
		echo -e "include-file = /opt/lalucachy/dotfiles/polybar/config.ini\n# Add your custom config here" | cat - ~/.config/polybar/config.ini > temp; \
		mv temp ~/.config/polybar/config.ini; \
	fi

install-terminal: sanity-check  ## Install terminal
	sudo pacman --noconfirm --needed -S kitty
	if [ ! -f ~/.config/kitty/kitty.conf ]; then \
		mkdir -p ~/.config/kitty/; \
		touch ~/.config/kitty/kitty.conf; \
	fi
	
	# If "include /opt/lalucachy/dotfiles/kitty/kitty.conf" not in ~/.config/kitty/kitty.conf, add it as the first line
	if ! grep -q "include /opt/lalucachy/dotfiles/kitty/kitty.conf" ~/.config/kitty/kitty.conf; then \
		echo -e "include /opt/lalucachy/dotfiles/kitty/kitty.conf\n# Add your custom config here" | cat - ~/.config/kitty/kitty.conf > temp; \
		mv temp ~/.config/kitty/kitty.conf; \
	fi

install-mise: sanity-check  ## Install mise
	# Install mise and all php-build dependencies
	sudo pacman --needed --noconfirm -S mise libedit libffi libjpeg-turbo libpcap libpng libxml2 libzip postgresql-libs
	mise use -g usage@latest
	for package in pdm rust terraform golang python nodejs; do mise use -g $$package@latest; done
	# Install libs to build current latest, aka php 8.4.4
	sudo pacman --needed --noconfirm -S libedit libffi libjpeg-turbo libpcap libpng libxml2 libzip postgresql-libs
	mise use -g php@latest; \
	# WIP build compat php 7.4
	# openssl-1.1; export PKG_CONFIG_PATH=/usr/lib/openssl-1.1/pkgconfig ; export LDFLAGS="-L/usr/lib/openssl-1.1" ; export CPPFLAGS="-I/usr/include/openssl-1.1"

install-goodies: sanity-check  ## Install goodies
	sudo pacman --noconfirm --needed -S git-delta bottom  viu xsv jq asciinema htmlq neovim glow jless websocat superfile discord
	if [ ! -d ~/.config/nvim ]; then \
		git clone https://github.com/LazyVim/starter ~/.config/nvim; \
	fi
	if [ ! -d ~/.config/nvim/lua/user ]; then \
		mkdir -p ~/.config/nvim/lua/user; \
	fi
	if [ ! -f ~/.config/nvim/init.lua ]; then \
		touch ~/.config/nvim/init.lua; \
	fi
	if ! grep -q 'vim.opt.mouse = ""' ~/.config/nvim/init.lua; then \
		echo -e 'vim.opt.mouse = ""' | cat ~/.config/nvim/init.lua - > temp; \
		mv temp ~/.config/nvim/init.lua; \
	fi

install-offensive: sanity-check  ## Install offensive tools
	sudo pacman --noconfirm --needed -S metasploit burpsuite fx lazygit fq
	yay --noconfirm --needed -S ffuf gau pdtm-bin brutesprayx waybackurls
	mise exec -- go install github.com/sw33tLie/sns@latest
	mise exec -- go install github.com/glitchedgitz/cook/v2/cmd/cook@latest
	pdtm -install-all
	zsh -c "source ~/.zshrc && nuclei -update-templates -update-template-dir ~/.nuclei-templates"; \
	
	# Clone custom tools
	if [ ! -d /opt/chisel ]; then git clone https://github.com/jpillora/chisel && sudo mv chisel /opt/chisel; fi
	if [ ! -d /opt/phpggc ]; then git clone https://github.com/ambionics/phpggc && sudo mv phpggc /opt/phpggc; fi
	if [ ! -d /opt/PyFuscation ]; then git clone https://github.com/CBHue/PyFuscation && sudo mv PyFuscation /opt/PyFuscation; fi
	if [ ! -d /opt/CloudFlair ]; then git clone https://github.com/christophetd/CloudFlair && sudo mv CloudFlair /opt/CloudFlair; fi
	if [ ! -d /opt/minos-static ]; then git clone https://github.com/minos-org/minos-static && sudo mv minos-static /opt/minos-static; fi
	if [ ! -d /opt/exploit-database ]; then git clone https://github.com/offensive-security/exploit-database && sudo mv exploit-database /opt/exploit-database; fi
	if [ ! -d /opt/exploitdb ]; then git clone https://gitlab.com/exploit-database/exploitdb && sudo mv exploitdb /opt/exploitdb; fi
	if [ ! -d /opt/pty4all ]; then git clone https://github.com/laluka/pty4all && sudo mv pty4all /opt/pty4all; fi
	if [ ! -d /opt/pypotomux ]; then git clone https://github.com/laluka/pypotomux && sudo mv pypotomux /opt/pypotomux; fi
	
	# Clone wordlists
	if [ ! -d /opt/lists ]; then mkdir /tmp/lists && sudo mv /tmp/lists /opt/lists; fi
	if [ ! -f /opt/lists/rockyou.txt ]; then curl -L https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt -o /opt/lists/rockyou.txt; fi
	if [ ! -d /opt/lists/PayloadsAllTheThings ]; then git clone https://github.com/swisskyrepo/PayloadsAllTheThings /opt/lists/PayloadsAllTheThings ; fi
	if [ ! -d /opt/lists/fuzzing-templates ]; then git clone https://github.com/projectdiscovery/fuzzing-templates /opt/lists/fuzzing-templates ; fi
	if [ ! -d /opt/lists/BruteX ]; then git clone https://github.com/1N3/BruteX /opt/lists/BruteX ; fi
	if [ ! -d /opt/lists/IntruderPayloads ]; then git clone https://github.com/1N3/IntruderPayloads /opt/lists/IntruderPayloads ; fi
	if [ ! -d /opt/lists/Probable-Wordlists ]; then git clone https://github.com/berzerk0/Probable-Wordlists /opt/lists/Probable-Wordlists ; fi
	if [ ! -d /opt/lists/Open-Redirect-Payloads ]; then git clone https://github.com/cujanovic/Open-Redirect-Payloads /opt/lists/Open-Redirect-Payloads ; fi
	if [ ! -d /opt/lists/SecLists ]; then git clone https://github.com/danielmiessler/SecLists /opt/lists/SecLists ; fi
	if [ ! -d /opt/lists/Pwdb-Public ]; then git clone https://github.com/ignis-sec/Pwdb-Public /opt/lists/Pwdb-Public ; fi
	if [ ! -d /opt/lists/Bug-Bounty-Wordlists ]; then git clone https://github.com/Karanxa/Bug-Bounty-Wordlists /opt/lists/Bug-Bounty-Wordlists ; fi
	if [ ! -d /opt/lists/richelieu ]; then git clone https://github.com/tarraschk/richelieu /opt/lists/richelieu ; fi
	if [ ! -d /opt/lists/webapp-wordlists ]; then git clone https://github.com/p0dalirius/webapp-wordlists /opt/lists/webapp-wordlists ; fi

install-security: sanity-check  ## Install security tools
	sudo pacman --noconfirm --needed -S opensnitch
	sudo systemctl disable --now nxserver.service
	# OPT-IN opensnitch as an egress firewall
	# sudo systemctl enable --now opensnitchd.service

all: install-base install-system install-shell install-docker install-i3 install-polybar install-terminal install-mise install-goodies install-offensive install-security
	echo "You are all set up! Enjoy ! 🌹"