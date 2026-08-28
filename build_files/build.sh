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

# COPR mise (Polyglot dev tool & runtime manager)
curl --output-dir "/etc/yum.repos.d/" \
  --remote-name "https://copr.fedorainfracloud.org/coprs/jdxcode/mise/repo/fedora-$(rpm -E %fedora)/jdxcode-mise-fedora-$(rpm -E %fedora).repo"

# COPR Bibata Cursors (Cursore moderno per Niri) valida alternativa molto bella
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
  xdg-desktop-portal-wlr \
  wlr-randr \
  --allowerasing

# Terminale ed Editor
dnf5 -y install \
  ghostty \
  zed

# Shell ZSH & Strumenti CLI
dnf5 -y install \
  gh \
  zsh \
  zoxide \
  zsh-autosuggestions \
  zsh-syntax-highlighting \
  util-linux-user \
  mise \
  chezmoi

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

# Installazione e configurazione Cursori McMojave come predefiniti
git clone --depth 1 https://github.com/vinceliuice/McMojave-cursors.git /tmp/mcmojave
mkdir -p /usr/share/icons/McMojave-cursors /usr/share/icons/default
cp -rf /tmp/mcmojave/dist/* /usr/share/icons/McMojave-cursors/
cat > /usr/share/icons/default/index.theme << 'EOF'
[Icon Theme]
Inherits=McMojave-cursors
EOF
rm -rf /tmp/mcmojave

# Multimedia, Codec, Gaming & OBS Studio (con accelerazione hardware VA-API per AMD)
dnf5 -y install \
  ffmpeg \
  x264-libs \
  obs-studio \
  obs-studio-plugin-x264 \
  libva-utils \
  mangohud \
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
# Abilitazione GDM (Display Manager ufficiale che supporta nativamente Niri e GNOME)
systemctl enable gdm.service

# Abilitazione servizi di sistema e utente
systemctl enable podman.socket
systemctl enable libvirtd.service
systemctl enable default-flatpaks.service
systemctl enable nordvpnd.service
chmod +x /usr/libexec/chezmoi-sync.sh
systemctl --global enable chezmoi-sync.service

# 6. Default User Skeleton / Dotfiles Configuration
if [ -d "/ctx/dot_config" ]; then
  mkdir -p /etc/skel/.config
  cp -rf /ctx/dot_config/* /etc/skel/.config/
fi

# 7. GLib Schemas compilation
glib-compile-schemas /usr/share/glib-2.0/schemas/

# 8. Branding Ufficiale ValkyriaOS (Identità per fastfetch, GNOME Settings e os-release)
sed -i 's|^NAME=.*|NAME="ValkyriaOS"|' /usr/lib/os-release
sed -i 's|^PRETTY_NAME=.*|PRETTY_NAME="ValkyriaOS"|' /usr/lib/os-release
sed -i 's|^ID=.*|ID=valkyriaos|' /usr/lib/os-release
sed -i 's|^ID_LIKE=.*|ID_LIKE="bluefin fedora"|' /usr/lib/os-release
sed -i 's|^VARIANT=.*|VARIANT="ValkyriaOS"|' /usr/lib/os-release
sed -i 's|^VARIANT_ID=.*|VARIANT_ID=valkyriaos|' /usr/lib/os-release
sed -i 's|^HOME_URL=.*|HOME_URL="https://github.com/gyratina/ValkyriaOS"|' /usr/lib/os-release
sed -i 's|^DOCUMENTATION_URL=.*|DOCUMENTATION_URL="https://github.com/gyratina/ValkyriaOS"|' /usr/lib/os-release
sed -i 's|^SUPPORT_URL=.*|SUPPORT_URL="https://github.com/gyratina/ValkyriaOS/issues"|' /usr/lib/os-release
sed -i 's|^BUG_REPORT_URL=.*|BUG_REPORT_URL="https://github.com/gyratina/ValkyriaOS/issues"|' /usr/lib/os-release
if [ -f /etc/default/grub ]; then
  sed -i 's|^GRUB_DISTRIBUTOR=.*|GRUB_DISTRIBUTOR="ValkyriaOS"|' /etc/default/grub
fi
if [ -f /usr/share/ublue-os/image-info.json ]; then
  sed -i 's/"image-name": .*/"image-name": "valkyriaos",/' /usr/share/ublue-os/image-info.json
  sed -i 's/"image-vendor": .*/"image-vendor": "gyratina",/' /usr/share/ublue-os/image-info.json
fi

# 8. Rimozione pacchetti non voluti
dnf5 -y remove alacritty || true

# 9. Clean up DNF cache to reduce final image size
dnf5 -y clean all
rm -rf /run/dnf /run/selinux-policy /var/lib/dnf
