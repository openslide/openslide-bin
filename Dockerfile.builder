FROM registry.fedoraproject.org/fedora:36
RUN dnf -y install ant cmake gcc gettext git-core glib2-devel java meson \
    mingw{32,64}-gcc-c++ nasm wget zip && \
    dnf clean all
