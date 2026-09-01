#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux alacritty

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

dnf5 install -y dnf-plugins-core
dnf5 config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
dnf5 install -y brave-browser

## Throne (VPN-клиент) + SUID для TUN

echo "Downloading Throne VPN..."
curl -fsSL -o /etc/yum.repos.d/throne.repo https://parhelia512.github.io/throne.repo
dnf5 install -y throne
chown root:root /usr/lib64/Throne/ThroneCore
chmod u+s /usr/lib64/Throne/ThroneCore

## Happ (VPN-клиент)

HAPP_URL="https://github.com/Happ-proxy/happ-desktop/releases/latest/download/Happ.linux.x64.rpm"
echo "Downloading Happ VPN..."
curl -fsSL -L -o /tmp/happ.rpm "$HAPP_URL"
dnf5 install -y /tmp/happ.rpm
rm -f /tmp/happ.rpm

#### Example for enabling a System Unit File

systemctl enable podman.socket
