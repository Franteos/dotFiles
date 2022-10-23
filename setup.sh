#!/bin/bash

function startCheck() {
    ping -c 1 -q google.com >&/dev/null
    if [[ $? != 0 ]]; then
        echo ""
        echo "Must have internet connection!"
        echo ""
        exit 1
    fi

    echo ""
    echo "=============================="
    echo "   Welcome to your new O.S! "
    echo "=============================="
    echo ""
    echo ""
    read -p "Enter your username: " username

    if [[ $username == "root" ]]; then
        echo ""
        echo "Please, enter another username!"
        echo ""
    fi

    read -p "Which SHELL do you prefere BASH [B] or ZSH [Z]? " -e -i "Z" usr_op_shell
    read -p "Do you want to install/configure TMUX? [Y/n] " -e -i "Y" usr_op_tmux
    read -p "Do you want to install/configure NEOVIM? [Y/n] " -e -i "Y" usr_op_neovim
    echo ""
    read -p "Do you want to proceed? [Y/n] " -e -i "Y" usr_op

    if [[ $usr_op != "Y" ]]; then
        echo ""
        echo "See you soon!"
        echo ""
        exit 2
    fi
}

function initialConfig() {
    sudo apt update -y && sudo apt upgrade -y
    sudo apt install git xclip bat zsh zsh-autosuggestions zsh-syntax-highlighting wget nmap tcpdump curl python3 pip
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    rm -d ~/{Documents,Music,Pictures,Public,Templates,Videos}
    mkdir ~/{Scripts,Programs}
    timedatectl set-timezone Europe/Madrid
    sudo dpkg -i ~/dotFiles/assets/lsd.deb
    mkdir ~/tmp
}

function addZSH() {
    # CREATE .ZSHRC
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/loket/oh-my-zsh/feature/batch-mode/tools/install.sh)" -s --batch || {
        echo "Could not install Oh My Zsh" >/dev/stderr
        exit 1
    }

    curl -sS https://starship.rs/install.sh | sh
    cp ~/dotFiles/assets/starship.toml ~/.config/

    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    cp ~/dotFiles/assets/.zshrc ~/.zshrc

    # INSTALL HACK FONT
    sudo unzip -o ~/dotFiles/assets/Hack.zip -d /usr/share/fonts/
}

function addBASH() {
    cat <<EOF >> ~/.bashrc
alias ls='ls -lh --color=auto'
alias ll='ls -la --color=auto'
alias grep='grep --color=auto'
alias cat='batcat'
alias update='sudo apt update -y && sudo apt upgrade -y'
alias poweroff='sudo systemctl poweroff'
alias reboot='sudo systemctl reboot'
alias apt='sudo apt'
alias mkt='mkdir'
alias tmux='tmux -u'
alias vim='nvim'
alias myip='curl ifconfig.co/'
alias copy='xcopy -sel c <'
# === OTHERS ===
export PATH=$PATH:/home/$USERNAME/Scripts/
PS1='\[\e[0;38;5;46m\]\u\[\e[0;38;5;46m\]@\[\e[0;38;5;46m\]\H \[\e[0m\][\[\e[0m\]\w\[\e[0m\]] \[\e[0;93m\]\$ \[\e[0m\]'
EOF
}

function confNVIM() {
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    wget https://github.com/arcticicestudio/nord-vim/archive/master.zip ~/tmp
    unzip ~/tmp/master.zip
    mv ~/tmp/nord-vim-main/colors/ ~/.config/nvim
    cp ~/dotFiles/assets/init.vim ~/.config/nvim/init.vim
}

function confTMUX() {
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    cp ~/dotFiles/assets/tmux.conf ~/.tmux.conf
}

function secureALL() {
    cp ~/dotFiles/assets/secureOS.sh ~
    chmod u+x ~/secureOS.sh

    cp ~/dotFiles/assets/secureSSH.sh ~
    chmod u+x ~/secureSSH.sh
}

function printEnd() {
    clear
    echo ""
    echo ""
    echo '  ZSH:   source ~/.zshrc'
    echo ' BASH:  source ~/.bashrc'
    echo ""
    echo ""
    echo "> Author: impulsado"
}

# === MAIN ===

startCheck

if [[ $usr_op == "Y" ]]; then
    initial
    if [[ $usr_op_shell == "B" ]]; then
        addBASH
    else
        addZSH
    fi
    confTMUX
    confNVIM
    secureALL
    sleep 1
    printEnd
    yes | rm -rf ~/tmp # Delete tmp files
fi
