FROM registry.fedoraproject.org/fedora:38
RUN dnf -y install bzip2 gcc g++ gettext git-core glib2-devel glib2-devel.i686 \
    glibc-devel glibc-devel.i686 libstdc++-devel libstdc++-devel.i686 pcre.i686 pkgconf java-devel \
    meson mingw{32,64}-gcc-c++ nasm wget xz zip && \
    dnf clean all
