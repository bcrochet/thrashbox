FROM registry.fedoraproject.org/fedora-toolbox:43 as clipboard-builder

RUN \
    # First, let's download the code and go a nice place to build everything. \
    dnf install -y cmake make alsa-lib alsa-lib-devel openssl-devel gcc-c++ && \
    cd $(mktemp -d) && \
    git clone https://github.com/Slackadays/Clipboard && \
    cd Clipboard/build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    cmake --build . -j 12 && \
    cmake --install .

FROM registry.fedoraproject.org/fedora-toolbox:43 as eza-install
RUN cd /tmp && \
    curl -OL https://github.com/eza-community/eza/releases/download/v0.21.0/eza_x86_64-unknown-linux-gnu.tar.gz \
    && tar xzf eza_x86_64-unknown-linux-gnu.tar.gz 

FROM registry.fedoraproject.org/fedora-toolbox:43

LABEL com.github.containers.toolbox="true" \
    usage="This image is meant to be used with the toolbox or distrobox command" \
    summary="A cloud-native terminal experience" \
    maintainer="brad@crochet.net"
COPY extra-packages /
COPY etc /etc

COPY --from=clipboard-builder /usr/local/bin/cb /usr/local/bin/cb
COPY --from=eza-install /tmp/eza /usr/local/bin/eza

RUN dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
    dnf config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo && \
    dnf config-manager addrepo --from-repofile=https://copr.fedorainfracloud.org/coprs/atim/starship/repo/fedora-$(rpm -E %fedora)/atim-starship-fedora-$(rpm -E %fedora).repo && \
    dnf config-manager setopt fedora-cisco-openh264.enabled=true && \
    dnf copr enable -y varlad/zellij  && \
    dnf upgrade -y && \
    grep -v '^#' /extra-packages | xargs dnf install -y && \
    dnf clean all
RUN rm /extra-packages

#RUN   ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/docker && \
#      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/flatpak && \ 
#      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/podman && \
#      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/rpm-ostree && \
#      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/transactional-update
#
