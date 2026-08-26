#!/bin/bash

set -ouex pipefail

# 1. DNF Speedup & Fresh Metadata
sed -i '/^\[main\]/a max_parallel_downloads=10\nmetadata_expire=0' /etc/dnf/dnf.conf

# 2. Copy system files from repo to image root
cp -avf "/ctx/system_files"/. /

# 3. Enable Repositories
# RPM Fusion Free & Nonfree (Codec, FFmpeg, OBS plugins)
dnf5 -y install \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Terra Repository (per Zed Editor e Ghostty)
curl -fsSL https://github.com/terrapkg/subatomic-repos/raw/main/terra.repo -o /etc/yum.repos.d/terra.repo
dnf5 -y install terra-release

# COPR Dank Material Shell (DMS + Quickshell)
curl --output-dir "/etc/yum.repos.d/" \
  --remote-name "https://copr.fedorainfracloud.org/coprs/avengemedia/dms/repo/fedora-$(rpm -E %fedora)/avengemedia-dms-fedora-$(rpm -E %fedora).repo"

# COPR Bibata Cursors (Cursore moderno per Niri)
# curl -Lo /etc/yum.repos.d/peterwu.repo \
#   https://copr.fedorainfracloud.org/coprs/peterwu/rendezvous/repo/fedora-$(rpm -E %fedora)/peterwu-rendezvous-fedora-$(rpm -E %fedora).repo


# 4. Install Packages
# Virtualizzazione KVM/QEMU & Container
dnf5 -y install \
  qemu-kvm \
  libvirt \
  virt-manager \
  podman-compose \
  flatpak-builder

# Tiling Window Manager (Niri) & Dank Shell
dnf5 -y install \
  niri \
  quickshell \
  dms \
  greetd \
  dms-greeter \
  xdg-desktop-portal-wlr \
  wlr-randr \
  --allowerasing

# Terminale ed Editor
dnf5 -y install \
  ghostty \
  zed

# Shell ZSH & Strumenti CLI
dnf5 -y install \
  zsh \
  zoxide \
  zsh-autosuggestions \
  zsh-syntax-highlighting \
  util-linux-user

# Autenticazione Polkit, Utilità di sistema & Strumenti
dnf5 -y install \
  lxpolkit \
  lxqt-openssh-askpass \
  iotop \
  sysstat \
  parallel \
  just \
  seahorse \
  android-tools \
  iperf3
  # bibata-cursor-themes

# Installazione Cursori McMojave
git clone --depth 1 https://github.com/vinceliuice/McMojave-cursors.git /tmp/mcmojave
mkdir -p /usr/share/icons
cp -rf /tmp/mcmojave/dist/* /usr/share/icons/ 2>/dev/null || /tmp/mcmojave/install.sh -d /usr/share/icons
rm -rf /tmp/mcmojave

# Multimedia, Codec, Gaming & OBS Studio (con accelerazione hardware VA-API per AMD)
dnf5 -y install \
  ffmpeg \
  x264-libs \
  obs-studio \
  obs-studio-plugin-x264 \
  libva-utils \
  mangohud \
  mpv \
  --allowerasing

# 5. Installazione Software Aggiuntivo
# NordVPN (CLI + GUI)
curl -fsSL https://downloads.nordcdn.com/apps/linux/install.sh | sh -s -- -n -p nordvpn-gui

# Spotatui (Spotify TUI)
curl -fsSL https://github.com/LargeModGames/spotatui/releases/latest/download/spotatui-linux-x86_64.tar.gz -o /tmp/spotatui.tar.gz
tar -xzf /tmp/spotatui.tar.gz -C /usr/bin/
rm -f /tmp/spotatui.tar.gz

# 6. Configurazione Shell di Default
# Imposta Zsh come shell predefinita per i nuovi utenti
sed -i 's|^SHELL=.*|SHELL=/bin/zsh|' /etc/default/useradd

# 6. Display Manager & System Services
# Configurazione Greetd con DMS Greeter
mkdir -p /etc/greetd/
cat > /etc/greetd/config.toml << EOF
[terminal]
vt = 1
[default_session]
user = "greeter"
command = "dms-greeter"
EOF

# Imposta Greetd come Display Manager predefinito
rm -f /etc/systemd/system/display-manager.service
ln -s /usr/lib/systemd/system/greetd.service /etc/systemd/system/display-manager.service
systemctl enable --force greetd.service

# Abilitazione servizi di sistema
systemctl enable podman.socket
systemctl enable libvirtd.service
systemctl enable default-flatpaks.service
systemctl enable nordvpnd.service

# 6. Default User Skeleton / Dotfiles Configuration
if [ -d "/ctx/dot_config" ]; then
  mkdir -p /etc/skel/.config
  cp -rf /ctx/dot_config/* /etc/skel/.config/
fi

# 7. GLib Schemas compilation
glib-compile-schemas /usr/share/glib-2.0/schemas/

# 8. Clean up DNF cache to reduce final image size
dnf5 -y clean all
rm -rf /run/dnf /run/selinux-policy /var/lib/dnf
