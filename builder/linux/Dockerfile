# Use a Linux distro with an older glibc for maximum compatibility
FROM quay.io/almalinuxorg/almalinux:8
RUN touch /etc/openslide-linux-builder-v1
RUN dnf -y upgrade && \
    dnf -y install 'dnf-command(config-manager)' && \
    dnf config-manager --set-enabled powertools && \
    dnf -y install gcc-c++ git-core java-1.8.0-openjdk-devel nasm ninja-build \
    python3.8 unzip && \
    dnf clean all
RUN pip3 install meson
