FROM registry.fedoraproject.org/fedora:37
RUN dnf -y install bzip2 cmake gcc gettext git-core glib2-devel java-devel \
    mingw{32,64}-gcc-c++ nasm ninja-build python3-pip wget xz zip && \
    dnf clean all
# in Fedora 38 we can switch back to the meson RPM
RUN pip install meson==1.0.0 && rm -r /root/.cache/pip
