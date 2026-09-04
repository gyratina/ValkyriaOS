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

# Allinea le librerie Qt6 per garantire compatibilità ABI con la nuova build di Quickshell
dnf5 -y upgrade "qt6-*" --allowerasing

# Test di integrità: verifica che Quickshell si colleghi correttamente alle librerie Qt6
qs --version

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
  chezmoi \
  eza

# Autenticazione Polkit, Utilità di sistema, Lingua & Strumenti
dnf5 -y install \
  lxpolkit \
  lxqt-openssh-askpass \
  iotop \
  sysstat \
  parallel \
  just \
  seahorse \
  android-tools \
  iperf3 \
  glibc-langpack-it \
  langpacks-it

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

# Antigravity CLI (agy)
HOME=/tmp bash -c 'curl -fsSL https://antigravity.google/cli/install.sh | bash -s -- --dir /usr/bin'

# Collegamento per avviare Zed Editor con il comando 'zed'
if [ -f /usr/bin/zeditor ]; then
  ln -sf /usr/bin/zeditor /usr/local/bin/zed || true
fi

# 6. Configurazione Utente di Default
# Imposta Zsh come shell predefinita e il gruppo nordvpn per i nuovi utenti
groupadd -f nordvpn
sed -i 's|^SHELL=.*|SHELL=/bin/zsh|' /etc/default/useradd
if grep -q "^GROUPS=" /etc/default/useradd; then
  sed -i 's|^GROUPS=.*|GROUPS=nordvpn|' /etc/default/useradd
else
  echo "GROUPS=nordvpn" >> /etc/default/useradd
fi

# 6. Display Manager & System Services
# Abilitazione GDM (Display Manager ufficiale che supporta nativamente Niri e GNOME)
systemctl enable gdm.service

# Abilitazione servizi di sistema e utente
systemctl enable podman.socket
systemctl enable libvirtd.service
systemctl enable default-flatpaks.service
systemctl enable nordvpn-setup.service
systemctl enable nordvpnd.service
chmod +x /usr/libexec/chezmoi-sync.sh /usr/libexec/valkyria-nordvpn-setup.sh /usr/libexec/valkyria-switch-layout.sh
systemctl --global enable chezmoi-sync.service

# 6. Default User Skeleton / Dotfiles Configuration
if [ -d "/ctx/dot_config" ]; then
  mkdir -p /etc/skel/.config
  cp -rf /ctx/dot_config/* /etc/skel/.config/
fi
# Disabilita il banner Bluefin/Universal-Blue MOTD all'apertura del terminale
mkdir -p /etc/skel/.config
touch /etc/skel/.config/no-show-user-motd
rm -f /etc/profile.d/user-motd.sh /etc/profile.d/ublue-os-just.sh /etc/profile.d/ublue-motd.sh /etc/profile.d/ublue-user-motd.sh 2>/dev/null || true

# 7. GLib Schemas, DConf & Font Cache compilation
glib-compile-schemas /usr/share/glib-2.0/schemas/
dconf update 2>/dev/null || true
fc-cache -f /usr/share/fonts

# 8. Branding Ufficiale ValkyriaOS (Identità per fastfetch, GNOME Settings e os-release)
echo "Valkyria" > /etc/hostname
sed -i 's|^NAME=.*|NAME="ValkyriaOS"|' /usr/lib/os-release
sed -i 's|^PRETTY_NAME=.*|PRETTY_NAME="ValkyriaOS"|' /usr/lib/os-release
sed -i 's|^ID=.*|ID=fedora|' /usr/lib/os-release
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
