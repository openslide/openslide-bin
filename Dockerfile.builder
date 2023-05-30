FROM registry.fedoraproject.org/fedora:38
RUN dnf -y install bzip2 gcc g++ gettext git-core glib2-devel java-devel \
    meson mingw{32,64}-gcc-c++ nasm wget xz zip && \
    dnf clean all
