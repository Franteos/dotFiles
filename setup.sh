#!/bin/bash

# INSTALL DEPENDENCIES
sudo apt-get update -y
sudo apt install net-tools libuv1-dev build-essential git vim xcb libxcb-util0-dev libxcb-ewmh-dev libxcb-randr0-dev libxcb-icccm4-dev libxcb-keysyms1-dev libxcb-xinerama0-dev libasound2-dev libxcb-xtest0-dev libxcb-shape0-dev -y
sudo apt install cmake cmake-data pkg-config python3-sphinx libcairo2-dev libxcb1-dev libxcb-util0-dev libxcb-randr0-dev libxcb-composite0-dev python3-xcbgen xcb-proto libxcb-image0-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-xkb-dev libxcb-xrm-dev libxcb-cursor-dev libasound2-dev libpulse-dev libjsoncpp-dev libmpdclient-dev libnl-genl-3-dev -y
sudo apt install meson libxext-dev libxcb1-dev libxcb-damage0-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-render-util0-dev libxcb-render0-dev libxcb-randr0-dev libxcb-composite0-dev libxcb-image0-dev libxcb-present-dev libxcb-xinerama0-dev libpixman-1-dev libdbus-1-dev libconfig-dev libgl1-mesa-dev libpcre2-dev libevdev-dev uthash-dev libev-dev libx11-xcb-dev libxcb-glx0-dev -y
sudo apt install bspwm rofi caja feh gnome-terminal scrot neovim xclip tmux acpi scrub bat wmname zsh zsh-autosuggestions zsh-syntax-highlighting -y

# INSTALL BSPWM & SXHKRD
mkdir ~/tmp
git clone https://github.com/baskerville/bspwm.git ~/tmp/bspwm
git clone https://github.com/baskerville/sxhkd.git ~/tmp/sxhkd
cd ~/tmp/bspwm
make
sudo make install
cd ~/tmp/sxhkd
make
sudo make install

mkdir -p ~/.config/{bspwm,sxhkd}
cp ~/tmp/bspwm/examples/bspwmrc ~/.config/bspwm/
cp ~/dotFiles/sxhkd/sxhkdrc ~/.config/sxhkd/
chmod +x ~/.config/bspwm/bspwmrc

# INSTALL POLYBAR
git clone --recursive https://github.com/polybar/polybar ~/tmp/polybar
cd ~/tmp/polybar
cmake .
make -j$(nproc)
sudo make install

# INSTALL PICOM
git clone https://github.com/ibhagwan/picom.git ~/tmp/picom
cd ~/tmp/picom
git submodule update --init --recursive
meson --buildtype=release . build
ninja -C build
sudo ninja -C build install

# SET WALLPAPER
mkdir ~/.wallpapers
cp ~/dotFiles/assets/wallpaper.jpg ~/.wallpapers
echo 'feh --bg-fill ~/.wallpapers/wallpaper.jpg' >> ~/.config/bspwm/bspwmrc
echo 'xsetroot -cursor_name left_ptr &' >> ~/.config/bspwm/bspwmrc
echo 'wmname LG3D &' >> ~/.config/bspwm/bspwmrc

# CONFIGURE POLYBAR
git clone https://github.com/VaughnValle/blue-sky.git ~/tmp/theme
unzip -o ~/dotFiles/assets/polybar.zip -d ~/.config/polybar/
echo '~/.config/polybar/polybar-backup/launch.sh' >> ~/.config/bspwm/bspwmrc

# CONFIGURE PICOM
mkdir ~/.config/picom
echo 'bspc config focus_follows_pointer true' >> ~/.config/bspwm/bspwmrc
cp ~/dotFiles/picom/picom.conf ~/.config/picom
echo 'bspc config border_width 0' >> ~/.config/bspwm/bspwmrc
mkdir ~/.config/bin
echo 'picom --experimental-backends &' >> ~/.config/bspwm/bspwmrc

# ADDS FUNCTIONS
cd ~/tmp
wget https://raw.githubusercontent.com/yorkox0/exaple01/main/ethernet_status.sh
chmod +x ethernet_status.sh 2>/dev/null
mv ethernet_status.sh ~/.config/bin

wget https://raw.githubusercontent.com/yorkox0/exaple01/main/hackthebox.sh
chmod +x hackthebox.sh
mv hackthebox.sh ~/.config/bin

cp ~/dotFiles/assets/target_to_hack.sh .
chmod +x target_to_hack.sh
mv target_to_hack.sh ~/.config/bin
echo '' > ~/.config/bin/target

cp ~/dotFiles/assets/battery.sh .
mv battery.sh ~/.config/bin
echo '' > ~/.config/bin/target

sudo cp ~/dotFiles/assets/settarget /bin
sudo cp ~/dotFiles/assets/cleartarget /bin
sudo chmod +x /bin/settarget
sudo chmod +x /bin/cleartarget

# CONFIG ROFI
mkdir ~/.config/rofi
mkdir ~/.config/rofi/themes
cp ~/tmp/theme/nord.rasi ~/.config/rofi/themes

# INSTALL POWERLEVEL10K
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k
echo 'source ~/.powerlevel10k/powerlevel10k.zsh-theme'>> ~/.zshrc

# CREATE .ZSHRC
chsh -s /bin/zsh $USERNAME
cp ~/dotFiles/assets/zshrc_conf ~/.zshrc

# INSTALL HACK FONT
sudo unzip -o ~/dotFiles/assets/Hack.zip -d /usr/share/fonts/

# CONFIGURE NVIM
mkdir ~/tmp/nvim
mkdir ~/.config/nvim
cd ~/tmp/nvim
wget https://raw.githubusercontent.com/Necros1s/lotus/master/lotus.vim
wget https://raw.githubusercontent.com/Necros1s/lotus/master/lotusbar.vim
wget https://raw.githubusercontent.com/Necros1s/lotus/master/init.vim
mv *.vim ~/.config/nvim
cp ~/dotFiles/assets/init.vim ~/.config/nvim/init.vim

# CONFIGURE TMUX
mkdir ~/.config/tmux
touch ~/.config/tmux/.tmux.conf
cp ~/dotFiles/assets/tmux.conf ~/.config/tmux/.tmux.conf
tmux source-file ~/.config/tmux/.tmux.conf

# INSTALL lsd
sudo dpkg -i ~/dotFiles/assets/lsd.deb

# INSTALL SSH
sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl stop ssh
    sudo cat <<EOF > /etc/ssh/sshd_config
# === NEW SSH CONFIGURATION ===
# Protocolo 1 is older and less secure
Protocol 2
# Limit passwords attempts
MaxAuthTries 3
# Disable root login
PermitRootLogin no
# Disable empty passwords to login
PermitEmptyPasswords no
# Disable X11 Forwarding
X11Forwarding no
# Period of time before client gets disconnected (Seconds)
ClientAliveInterval 15
# Server waiting time after a connection request is made (Seconds)
LoginGraceTime 20
EOF
sudo systemctl start ssh

# SECURE OS
    # Enable broadcast echo Protection
    echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

    # Disable Source Routed Packets
    for i in /proc/sys/net/ipv4/conf/*/accept_source_route; do
        echo 0 > $i
    done

    # Enable TCP SYN Cookie Protection
    echo 1 > /proc/sys/net/ipv4/tcp_syncookies

    # Disable ICMP Redirect Acceptance
    for i in /proc/sys/net/ipv4/conf/*/accept_redirects; do
        echo 0 > $i
    done

    # Don't send Redirect Messages
    for i in /proc/sys/net/ipv4/conf/*/send_redirects; do
        echo 0 > $i
    done

    # Drop Spoofed Packets coming in on an interface, which, if replied to,
    # would result in the reply going out a different interface.
    for i in /proc/sys/net/ipv4/conf/*/rp_filter; do
        echo 1 > $i
    done

# DELETE FILES
yes | rm -rf ~/tmp