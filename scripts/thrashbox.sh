#!/bin/sh

# Symlink distrobox shims
./distrobox-shims.sh

dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
dnf config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo
dnf config-manager addrepo --from-repofile=https://copr.fedorainfracloud.org/coprs/atim/starship/repo/fedora-$(rpm -E %fedora)/atim-starship-fedora-$(rpm -E %fedora).repo
dnf config-manager setopt fedora-cisco-openh264.enabled=true
dnf copr enable -y varlad/zellij

# Update the container and install packages
dnf update -y
grep -v '^#' ./thrashbox.packages | xargs dnf install -y

dnf clean all

