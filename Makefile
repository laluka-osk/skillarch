help:
	echo "Let's get help!"

sanity-check:
	@# Ensure we are in /opt/lalucachy
	@if [ "$$(pwd)" != "/opt/lalucachy" ]; then \
		echo "You must be in /opt/lalucachy to run this command"; \
		exit 1; \
	fi	

install-base: sanity-check
	echo "installing stuff"
	sudo pacman --noconfirm -Syu
	sudo pacman --noconfirm -S git vim tmux wget curl

install-system: sanity-check
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
	sudo pacman --noconfirm -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
	sudo pacman --noconfirm -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
	
	# Append chaotic-aur lines if not present in /etc/pacman.conf
	if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then \
		echo -e "[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist\n# Add your custom config here" | cat - /etc/pacman.conf > temp; \
		mv temp /etc/pacman.conf; \
	fi
	
	sudo pacman --noconfirm -S yay blueman picom flameshot dunst trash-cli
	if [ ! -f ~/.config/picom.conf ]; then \
		touch ~/.config/picom.conf; \
	fi
	if ! grep -q "@include \"/opt/lalucachy/dotfiles/picom.conf\"" ~/.config/picom.conf; then \
		echo -e "@include \"/opt/lalucachy/dotfiles/picom.conf\"\n# Add your custom config here" | cat - ~/.config/picom.conf > temp; \
		mv temp ~/.config/picom.conf; \
	fi
	yay --noconfirm -S cursor-bin python-pipx google-chrome
	pipx ensurepath
	for package in argcomplete bypass-url-parser dirsearch exegol pre-commit sqlmap wafw00f yt-dlp semgrep; do \
		pipx install "$$package"; \
		pipx inject "$$package" setuptools; \
	done

install-shell: sanity-check
	# sudo pacman --noconfirm -S zsh zsh-completions zsh-syntax-highlighting zsh-autosuggestions zsh-history-substring-search zsh-theme-powerlevel10k
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

install-colored-man-pages: sanity-check
	sudo pacman --noconfirm -S colored-man-pages

install-docker: sanity-check
	sudo pacman --noconfirm -S docker docker-compose
	sudo usermod -aG docker "$$USER"
	sudo systemctl enable docker
	sudo systemctl start docker

install-i3: sanity-check
	sudo pacman --noconfirm -S i3-gaps i3blocks i3lock i3status dmenu feh
	gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
	# If /home/lalu/.config/i3/config doesnt exist, create it
	if [ ! -f ~/.config/i3/config ]; then \
		mkdir -p ~/.config/i3; \
		touch ~/.config/i3/config; \
	fi
	# If include /opt/lalucachy/dotfiles/i3/config not in /home/lalu/.config/i3/config, add it as the first line
	if ! grep -q "include /opt/lalucachy/dotfiles/i3/config" ~/.config/i3/config; then \
		echo -e "include /opt/lalucachy/dotfiles/i3/config\n# Add your custom config here" | cat - ~/.config/i3/config > temp; \
		mv temp ~/.config/i3/config; \
	fi
	if [ ! -f /etc/X11/xorg.conf.d/30-touchpad.conf ]; then \
		sudo cp /opt/lalucachy/dotfiles/30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf; \
	fi

install-polybar: sanity-check
	sudo pacman --noconfirm -S polybar

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

install-terminal: sanity-check
	sudo pacman --noconfirm -S kitty
	if [ ! -f ~/.config/kitty/kitty.conf ]; then \
		mkdir -p ~/.config/kitty/; \
		touch ~/.config/kitty/kitty.conf; \
	fi
	
	# If "include /opt/lalucachy/dotfiles/kitty/kitty.conf" not in ~/.config/kitty/kitty.conf, add it as the first line
	if ! grep -q "include /opt/lalucachy/dotfiles/kitty/kitty.conf" ~/.config/kitty/kitty.conf; then \
		echo -e "include /opt/lalucachy/dotfiles/kitty/kitty.conf\n# Add your custom config here" | cat - ~/.config/kitty/kitty.conf > temp; \
		mv temp ~/.config/kitty/kitty.conf; \
	fi

install-mise: sanity-check
	sudo pacman --noconfirm -S mise
	mise use -g usage@latest
	for package in pdm rust terraform golang python nodejs; do \
		mise use -g $$package@latest; \
	done
	# Todo add all php shitty libs & build php

install-cligoodies: sanity-check
	sudo pacman --noconfirm -S git-delta bottom  viu xsv jq asciinema htmlq neovim glow jless websocat superfile
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


all: install-base install-system install-shell install-docker install-i3 install-polybar install-terminal install-cligoodies
	echo "You are all set up! Enjoy ! 🌹"

# base-devel bison bzip2 ca-certificates cloc cmake curl dos2unix expect ffmpeg foremost fswebcam gcc gd gdb gettext git gnupg hashid hexyl htop hwinfo icu imagemagick inotify-tools iproute2 jq kdenlive leptonica libedit libffi libjpeg-turbo libpcap libpng libxml2 libzip linux-tools-meta llvm lsb-release lsof ltrace make mariadb-libs meld mlocate ncurses neofetch net-tools ngrep nmap oniguruma openssh openssl pacman parallel perl-image-exiftool pkgconf postgresql-libs powerline powerline-fonts python python-pip python-virtualenv re2c readline ripgrep rlwrap socat sqlite sshpass tesseract tk tmate tmux tor traceroute tree ufw unzip vbindiff vim wget wl-clipboard xclip xmlsec xz yaml-cpp zip zlib fastgron
# disable tor cups etc