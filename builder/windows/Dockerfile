FROM docker.io/gentoo/stage3:latest
# NOTE: try to keep the current container image compatible with the latest
# stable source release, so people can conveniently build from the source
# tarball
RUN touch /etc/openslide-winbuild-builder-v5
RUN echo 'FEATURES="-sandbox -usersandbox -ipc-sandbox -network-sandbox -pid-sandbox"' >> /etc/portage/make.conf
COPY package.accept_keywords /etc/portage/package.accept_keywords/openslide
COPY package.use /etc/portage/package.use/openslide
RUN mkdir -p /var/db/repos/crossdev/{profiles,metadata} && echo crossdev > /var/db/repos/crossdev/profiles/repo_name && echo 'masters = gentoo' > /var/db/repos/crossdev/metadata/layout.conf && chown -R portage:portage /var/db/repos/crossdev
COPY repos.conf /etc/portage/repos.conf/crossdev.conf
COPY --from=docker.io/gentoo/portage:latest /var/db/repos/gentoo /var/db/repos/gentoo
RUN emerge -u dev-build/meson && \
    rm -f /var/cache/distfiles/*
RUN emerge app-portage/gentoolkit dev-lang/nasm dev-libs/glib \
    dev-python/tomli dev-util/glib-utils dev-vcs/git sys-devel/crossdev && \
    rm /var/cache/distfiles/*
RUN crossdev -t x86_64-w64-mingw32 && \
    rm /var/cache/distfiles/*
