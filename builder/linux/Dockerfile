# Use a Linux distro with an older glibc for maximum compatibility
FROM quay.io/almalinuxorg/almalinux:8
# NOTE: try to keep the current container image compatible with the latest
# stable source release, so people can conveniently build from the source
# tarball
RUN touch /etc/openslide-linux-builder-v8
RUN dnf -y upgrade && \
    dnf -y install 'dnf-command(config-manager)' epel-release && \
    dnf config-manager --set-enabled powertools && \
    dnf -y install gcc-c++ git-core ninja-build patchelf \
    python3.12-pip zstd && \
    if [ $(uname -m) = x86_64 ]; then dnf -y install nasm; fi && \
    dnf clean all
RUN pip3 install auditwheel license-expression meson
