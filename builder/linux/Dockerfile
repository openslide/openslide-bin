# Use a Linux distro with an older glibc for maximum compatibility
FROM quay.io/almalinuxorg/almalinux:8
# NOTE: try to keep the current container image compatible with the latest
# stable source release, so people can conveniently build from the source
# tarball
RUN touch /etc/openslide-linux-builder-v{2,3,4}
RUN dnf -y upgrade && \
    dnf -y install 'dnf-command(config-manager)' epel-release && \
    dnf config-manager --set-enabled powertools && \
    dnf -y install gcc-c++ git-core nasm ninja-build patchelf \
    python3.12-pip && \
    dnf clean all
RUN pip3 install auditwheel meson tomli
