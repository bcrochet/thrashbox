FROM quay.io/toolbx-images/fedora-toolbox:39

LABEL com.github.containers.toolbox="true" \
      usage="This image is meant to be used with the toolbox or distrobox command" \
      summary="A cloud-native terminal experience" \
      maintainer="brad@crochet.net"
COPY extra-packages /
COPY etc /etc

RUN dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                   https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
    dnf config-manager --enable fedora-cisco-openh264 && \
    dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo && \
    dnf config-manager --add-repo https://copr.fedorainfracloud.org/coprs/atim/starship/repo/fedora-$(rpm -E %fedora)/atim-starship-fedora-$(rpm -E %fedora).repo && \
    dnf copr enable -y varlad/zellij  && \
    dnf upgrade -y && \
    grep -v '^#' /extra-packages | xargs dnf install -y
RUN rm /extra-packages

RUN rpm -Uvh https://github.com/twpayne/chezmoi/releases/download/v2.47.1/chezmoi-2.47.1-x86_64.rpm

# RUN curl -sSL https://github.com/Slackadays/Clipboard/raw/main/install.sh | sh
# First, let's download the code and go a nice place to build everything.
RUN dnf install -y cmake make alsa-lib alsa-lib-devel && \
    cd $(mktemp -d) && \
    git clone https://github.com/Slackadays/Clipboard && \
    cd Clipboard/build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    cmake --build . -j 12 && \
    cmake --install . && \
    cd ../.. && \
    rm -rf Clipboard && \
    dnf remove -y cmake make alsa-lib-devel && \
    dnf clean all

RUN   ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/docker && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/flatpak && \ 
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/podman && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/rpm-ostree && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/transactional-update
     
