help:
	echo "Let's get help!"

sanity-check:
	# Ensure we are in /opt/lalucachy
	if [ "$$(pwd)" != "/opt/lalucachy" ]; then \
		echo "You must be in /opt/lalucachy to run this command"; \
		exit 1; \
	fi	

install-base: sanity-check
	echo "installing stuff"
	sudo pacman --noconfirm -Syu
	sudo pacman --noconfirm -S git vim tmux wget curl

install-system: sanity-check
	# Add chaotic-aur to pacman
	sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
	sudo pacman-key --lsign-key 3056513887B78AEB
	sudo pacman --noconfirm -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
	sudo pacman --noconfirm -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
	
	# Append chaotic-aur lines if not present in /etc/pacman.conf
	if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then \
		echo "[chaotic-aur]" >> /etc/pacman.conf; \
		echo "Include = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf; \
	fi
	
	sudo pacman --noconfirm -S yay
	yay --noconfirm -S cursor-bin python-pipx google-chrome

install-shell: sanity-check
	sudo pacman --noconfirm -S zsh zsh-completions zsh-syntax-highlighting zsh-autosuggestions zsh-history-substring-search zsh-theme-powerlevel10k
	# Install oh-my-zsh if not already installed
	if [ ! -d ~/.oh-my-zsh ]; then \
		sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; \
	fi
	
	# if "source /opt/lalucachy/dotfiles/zshrc" is not in ~/.zshrc, add it
	if ! grep -q "source /opt/lalucachy/dotfiles/zshrc" ~/.zshrc; then \
		echo "source /opt/lalucachy/dotfiles/zshrc" >> ~/.zshrc; \
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
		echo "source-file /opt/lalucachy/dotfiles/tmux.conf" >> ~/.tmux.conf; \
	fi

install-i3: sanity-check
	sudo pacman --noconfirm -S i3-gaps i3blocks i3lock i3status dmenu
	