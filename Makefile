PACKAGES = ZLIB PNG JPEG TIFF OPENJPEG ICONV GETTEXT GLIB PKGCONFIG PIXMAN CAIRO OPENSLIDE OPENSLIDEJAVA
# CONFIGGUESS intentionally not included

# Package names
ZLIB_NAME = zlib
PNG_NAME = libpng
JPEG_NAME = libjpeg
TIFF_NAME = libtiff
OPENJPEG_NAME = OpenJPEG
ICONV_NAME = libiconv
GETTEXT_NAME = gettext
GLIB_NAME = glib
PIXMAN_NAME = pixman
CAIRO_NAME = cairo
OPENSLIDE_NAME = OpenSlide
OPENSLIDEJAVA_NAME = OpenSlide Java

# Versions
CONFIGGUESS_VER = 3bc7c305
ZLIB_VER = 1.2.5
PNG_VER = 1.5.5
JPEG_VER = 8c
TIFF_VER = 3.9.5
OPENJPEG_VER = 1_4
OPENJPEG_REV = 697
ICONV_VER = 1.14
GETTEXT_VER = 0.18.1.1
GLIB_VER = 2.28
GLIB_REV = 8
PKGCONFIG_VER = 0.26
PIXMAN_VER = 0.22.2
CAIRO_VER = 1.10.2
OPENSLIDE_VER = 3.2.4
OPENSLIDEJAVA_VER = 0.9.2

# Tarball URLs
CONFIGGUESS_URL = http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=$(CONFIGGUESS_VER)
ZLIB_URL = http://prdownloads.sourceforge.net/libpng/zlib-$(ZLIB_VER).tar.bz2
PNG_URL = http://prdownloads.sourceforge.net/libpng/libpng-$(PNG_VER).tar.xz
JPEG_URL = http://www.ijg.org/files/jpegsrc.v$(JPEG_VER).tar.gz
TIFF_URL = ftp://ftp.remotesensing.org/pub/libtiff/tiff-$(TIFF_VER).tar.gz
OPENJPEG_URL = http://openjpeg.googlecode.com/files/openjpeg_v$(OPENJPEG_VER)_sources_r$(OPENJPEG_REV).tgz
ICONV_URL = http://ftp.gnu.org/pub/gnu/libiconv/libiconv-$(ICONV_VER).tar.gz
GETTEXT_URL = http://ftp.gnu.org/pub/gnu/gettext/gettext-$(GETTEXT_VER).tar.gz
GLIB_URL = http://ftp.gnome.org/pub/gnome/sources/glib/$(GLIB_VER)/glib-$(GLIB_VER).$(GLIB_REV).tar.xz
PKGCONFIG_URL = http://pkgconfig.freedesktop.org/releases/pkg-config-$(PKGCONFIG_VER).tar.gz
PIXMAN_URL = http://cairographics.org/releases/pixman-$(PIXMAN_VER).tar.gz
CAIRO_URL = http://cairographics.org/releases/cairo-$(CAIRO_VER).tar.gz
OPENSLIDE_URL = http://github.com/downloads/openslide/openslide/openslide-$(OPENSLIDE_VER).tar.xz
OPENSLIDEJAVA_URL = http://github.com/downloads/openslide/openslide-java/openslide-java-$(OPENSLIDEJAVA_VER).tar.xz

# Directories
ROOT := $(shell pwd)/root

# Unpacked source trees
ZLIB_BUILD = build/zlib-$(ZLIB_VER)
PNG_BUILD = build/libpng-$(PNG_VER)
JPEG_BUILD = build/jpeg-$(JPEG_VER)
TIFF_BUILD = build/tiff-$(TIFF_VER)
OPENJPEG_BUILD = build/openjpeg_v$(OPENJPEG_VER)_sources_r$(OPENJPEG_REV)
ICONV_BUILD = build/libiconv-$(ICONV_VER)
GETTEXT_BUILD = build/gettext-$(GETTEXT_VER)/gettext-runtime
GLIB_BUILD = build/glib-$(GLIB_VER).$(GLIB_REV)
PKGCONFIG_BUILD = build/pkg-config-$(PKGCONFIG_VER)
PIXMAN_BUILD = build/pixman-$(PIXMAN_VER)
CAIRO_BUILD = build/cairo-$(CAIRO_VER)
OPENSLIDE_BUILD = build/openslide-$(OPENSLIDE_VER)
OPENSLIDEJAVA_BUILD = build/openslide-java-$(OPENSLIDEJAVA_VER)

# Build artifacts
ZLIB = bin/zlib1.dll
PNG = bin/libpng15-15.dll
JPEG = bin/libjpeg-8.dll
TIFF = bin/libtiff-3.dll
OPENJPEG = bin/libopenjpeg.dll
ICONV = $(addprefix bin/,libiconv-2.dll libcharset-1.dll)
GETTEXT = bin/libintl-8.dll
GLIB = $(addprefix bin/,libglib-2.0-0.dll libgthread-2.0-0.dll)
# pkg-config is used for build, but not distributed
PKGCONFIG =
PIXMAN = bin/libpixman-1-0.dll
CAIRO = bin/libcairo-2.dll
OPENSLIDE = $(addprefix bin/,libopenslide-0.dll openslide-quickhash1sum.exe openslide-show-properties.exe openslide-write-png.exe)
OPENSLIDEJAVA = $(addprefix bin/,openslide-jni.dll openslide.jar)

# Cached tarballs
$(foreach p,$(PACKAGES),$(eval $(p)_TAR = tar/$$(notdir $$($(p)_URL))))
TARS = $(foreach p,$(PACKAGES),$($(p)_TAR))

# Distribution zip files
DATESTAMP := $(shell date +%Y%m%d)
SDIST = openslide-winbuild-$(DATESTAMP).zip
BDIST = openslide-win32-$(DATESTAMP).zip

# Programs
CP = cp
RM = rm
ZIP = zip

# Cross-compilation
CROSS_HOST =
ifeq ($(CROSS_HOST),)
# Native
CROSS_HOST_PREFIX =
IF_NATIVE =
CONFIG_GUESS_EXE =
PKG_CONFIG_EXE = $(ROOT)/bin/pkg-config.exe
CONFIGURE_ARGS = PKG_CONFIG=$(PKG_CONFIG_EXE)
else
# Cross
CROSS_HOST_PREFIX = $(CROSS_HOST)-
IF_NATIVE = @:
CONFIG_GUESS_EXE = tar/config.guess
PKG_CONFIG_EXE =
# Fedora's $(CROSS_HOST)-pkg-config clobbers search paths; avoid it
CONFIGURE_ARGS = --host=$(CROSS_HOST) \
	--build=$(shell sh $(CONFIG_GUESS_EXE)) \
	PKG_CONFIG=pkg-config \
	PKG_CONFIG_LIBDIR="$(ROOT)/lib/pkgconfig" \
	PKG_CONFIG_PATH=
endif

# Use only our pkg-config library directory, even on cross builds
# https://bugzilla.redhat.com/show_bug.cgi?id=688171
DIR_CONFIGURE = cd $(PKG_BUILD) && ./configure \
	--prefix="$(ROOT)" \
	--disable-static \
	$(CONFIGURE_ARGS) \
	CPPFLAGS="-I$(ROOT)/include" \
	LDFLAGS="-L$(ROOT)/lib"
DIR_MAKE = $(MAKE) -C $(PKG_BUILD)

# Install specified program into MSYS if not present
install = @if (! type "$(1)" && type mingw-get) >/dev/null 2>&1 ; then \
	mingw-get install "msys-$(1)-bin"; fi

.PHONY: all sdist bdist
all: $(OPENSLIDE) $(OPENSLIDEJAVA)
sdist: $(SDIST)
bdist: $(BDIST)

.PHONY: clean
clean:
	$(RM) -rf bin build root openslide-win*-*.zip VERSIONS.txt

$(SDIST): Makefile README.txt TODO.txt tar/config.guess $(TARS)
	$(call install,zip)
	$(ZIP) $@ $^

$(BDIST): $(foreach p,$(PACKAGES),$($(p))) VERSIONS.txt
	$(call install,zip)
	$(ZIP) $@ $^

# Download the specified tarball.
$(TARS):
	$(call install,wget)
	mkdir -p tar
	$(foreach p,$(PACKAGES),$(if $(findstring $@,$($(p)_TAR)),wget -P tar -q --no-check-certificate $($(p)_URL)))

# config.guess gets its own download rule because we have to rename the
# saved file
tar/config.guess:
	$(call install,wget)
	mkdir -p tar
	wget -q -O $@ "$(CONFIGGUESS_URL)"

# Unpack the specified tarball.
$(foreach p,$(PACKAGES),$($(p)_BUILD)): $(CONFIG_GUESS_EXE)
	mkdir -p bin build
	rm -rf $@
	$(foreach p,$(PACKAGES),$(if $(findstring $@,$($(p)_BUILD)),tar xf $($(p)_TAR) -C build))

VERSIONS.txt: Makefile
	@rm -f $@
	@$(foreach p,$(PACKAGES),$(if $($(p)_NAME),echo "$($(p)_NAME) $($(p)_VER)" >> $@ &&)) :

$(ZLIB_BUILD): $(ZLIB_TAR)
$(ZLIB): PKG_BUILD = $(ZLIB_BUILD)
$(ZLIB): $(ZLIB_TAR) $(ZLIB_BUILD)
	$(DIR_MAKE) -f win32/Makefile.gcc \
		PREFIX="$(CROSS_HOST_PREFIX)" \
		IMPLIB=libz.dll.a all
	$(IF_NATIVE) $(DIR_MAKE) -f win32/Makefile.gcc \
		IMPLIB=libz.dll.a testdll
	$(DIR_MAKE) -f win32/Makefile.gcc \
		SHARED_MODE=1 \
		PREFIX="$(CROSS_HOST_PREFIX)" \
		IMPLIB=libz.dll.a \
		BINARY_PATH="$(ROOT)/bin" \
		INCLUDE_PATH="$(ROOT)/include" \
		LIBRARY_PATH="$(ROOT)/lib" install
	$(CP) $(ROOT)/bin/$(notdir $@) bin/

$(PNG_BUILD): $(PNG_TAR)
$(PNG): PKG_BUILD = $(PNG_BUILD)
$(PNG): $(PNG_TAR) $(PNG_BUILD) $(ZLIB)
	$(DIR_CONFIGURE)
	$(DIR_MAKE)
	$(IF_NATIVE) $(DIR_MAKE) check
	$(DIR_MAKE) install
	$(CP) $(ROOT)/bin/$(notdir $@) bin/

$(JPEG_BUILD): $(JPEG_TAR)
$(JPEG): PKG_BUILD = $(JPEG_BUILD)
$(JPEG): $(JPEG_TAR) $(JPEG_BUILD)
	$(DIR_CONFIGURE)
	$(DIR_MAKE)
	$(IF_NATIVE) $(DIR_MAKE) check
	$(DIR_MAKE) install
	$(CP) $(ROOT)/bin/$(notdir $@) bin/

$(TIFF_BUILD): $(TIFF_TAR)
$(TIFF): PKG_BUILD = $(TIFF_BUILD)
$(TIFF): $(TIFF_TAR) $(TIFF_BUILD) $(ZLIB) $(JPEG)
	$(DIR_CONFIGURE) \
		--with-zlib-include-dir="$(ROOT)/include" \
		--with-zlib-lib-dir="$(ROOT)/lib" \
		--with-jpeg-include-dir="$(ROOT)/include" \
		--with-jpeg-lib-dir="$(ROOT)/lib"
	$(DIR_MAKE)
	$(IF_NATIVE) $(DIR_MAKE) check
	$(DIR_MAKE) install
	$(CP) $(ROOT)/bin/$(notdir $@) bin/

$(OPENJPEG_BUILD): $(OPENJPEG_TAR)
$(OPENJPEG): PKG_BUILD = $(OPENJPEG_BUILD)
$(OPENJPEG): TCFILE = $(PKG_BUILD)/toolchain.cmake
$(OPENJPEG): $(OPENJPEG_TAR) $(OPENJPEG_BUILD) $(PNG) $(TIFF)
	@# The Autotools build system doesn't correctly build for Windows.
	@#
	@# Certain cmake variables cannot be specified on the command-line due
	@# to cmake #9980.
	echo "SET(CMAKE_SYSTEM_NAME Windows)" > $(TCFILE)
	echo "SET(CMAKE_C_COMPILER $(CROSS_HOST_PREFIX)gcc)" >> $(TCFILE)
	echo "SET(CMAKE_RC_COMPILER $(CROSS_HOST_PREFIX)windres)" >> $(TCFILE)
	cd $(PKG_BUILD) && cmake -G "Unix Makefiles" \
		-DCMAKE_TOOLCHAIN_FILE=$(notdir $(TCFILE)) \
		-DCMAKE_INSTALL_PREFIX="$(ROOT)" \
		-DCMAKE_FIND_ROOT_PATH="$(ROOT)" \
		-DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
		-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
		-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY .
	$(DIR_MAKE) all install
	$(CP) $(ROOT)/lib/$(notdir $@) bin/

$(ICONV_BUILD): $(ICONV_TAR)
$(ICONV): PKG_BUILD = $(ICONV_BUILD)
$(ICONV): $(ICONV_TAR) $(ICONV_BUILD)
	$(DIR_CONFIGURE)
	$(DIR_MAKE)
	$(IF_NATIVE) $(DIR_MAKE) check
	$(DIR_MAKE) install
	$(CP) $(foreach f,$(ICONV),$(ROOT)/bin/$(notdir $(f))) bin/

$(GETTEXT_BUILD): $(GETTEXT_TAR)
$(GETTEXT): PKG_BUILD = $(GETTEXT_BUILD)
$(GETTEXT): $(GETTEXT_TAR) $(GETTEXT_BUILD) $(ICONV)
	@# Missing tests for C++ compiler, which is only needed on Windows
	$(DIR_CONFIGURE) \
		CXX=$(CROSS_HOST_PREFIX)g++ \
		--disable-java \
		--disable-native-java \
		--disable-csharp \
		--disable-libasprintf \
		--enable-threads=win32
	$(DIR_MAKE)
	$(IF_NATIVE) $(DIR_MAKE) check
	$(DIR_MAKE) install
	$(CP) $(ROOT)/bin/$(notdir $@) bin/

$(GLIB_BUILD): $(GLIB_TAR)
$(GLIB): PKG_BUILD = $(GLIB_BUILD)
$(GLIB): $(GLIB_TAR) $(GLIB_BUILD) $(ZLIB) $(ICONV) $(GETTEXT)
	$(DIR_CONFIGURE)
	$(DIR_MAKE)
	#$(IF_NATIVE) $(DIR_MAKE) check
	$(DIR_MAKE) install
	$(CP) $(foreach f,$(GLIB),$(ROOT)/bin/$(notdir $(f))) bin/

# Only built during native builds; use $(PKG_CONFIG_EXE) in dependencies
$(PKGCONFIG_BUILD): $(PKGCONFIG_TAR)
$(ROOT)/bin/pkg-config.exe: PKG_BUILD = $(PKGCONFIG_BUILD)
$(ROOT)/bin/pkg-config.exe: $(PKGCONFIG_TAR) $(PKGCONFIG_BUILD) $(GLIB)
	$(DIR_CONFIGURE) \
		GLIB_CFLAGS="-I$(ROOT)/include/glib-2.0 -I$(ROOT)/lib/glib-2.0/include" \
		GLIB_LIBS="-L$(ROOT)/lib -lglib-2.0 -lintl"
	$(DIR_MAKE)
	#$(IF_NATIVE) $(DIR_MAKE) check
	$(DIR_MAKE) install

$(PIXMAN_BUILD): $(PIXMAN_TAR)
$(PIXMAN): PKG_BUILD = $(PIXMAN_BUILD)
$(PIXMAN): $(PIXMAN_TAR) $(PIXMAN_BUILD) $(PKG_CONFIG_EXE)
	$(DIR_CONFIGURE)
	$(DIR_MAKE)
	#$(IF_NATIVE) $(DIR_MAKE) check
	$(DIR_MAKE) install
	$(CP) $(ROOT)/bin/$(notdir $@) bin/

$(CAIRO_BUILD): $(CAIRO_TAR)
$(CAIRO): PKG_BUILD = $(CAIRO_BUILD)
$(CAIRO): $(CAIRO_TAR) $(CAIRO_BUILD) $(PKG_CONFIG_EXE) $(ZLIB) $(PNG) $(PIXMAN)
	# -Dffs to work around 1.10.2 bug
	# https://bugs.freedesktop.org/show_bug.cgi?id=30277
	$(DIR_CONFIGURE) \
		CFLAGS="-Dffs=__builtin_ffs" \
		--enable-ft=no \
		--enable-xlib=no
	$(DIR_MAKE)
	#$(IF_NATIVE) $(DIR_MAKE) check
	$(DIR_MAKE) install
	$(CP) $(ROOT)/bin/$(notdir $@) bin/

$(OPENSLIDE_BUILD): $(OPENSLIDE_TAR)
$(OPENSLIDE): PKG_BUILD = $(OPENSLIDE_BUILD)
$(OPENSLIDE): $(OPENSLIDE_TAR) $(OPENSLIDE_BUILD) $(PKG_CONFIG_EXE) $(PNG) $(JPEG) $(TIFF) $(OPENJPEG) $(GLIB) $(CAIRO)
	$(DIR_CONFIGURE)
	$(DIR_MAKE)
	$(IF_NATIVE) $(DIR_MAKE) check
	$(DIR_MAKE) install
	$(CP) $(foreach f,$(OPENSLIDE),$(ROOT)/bin/$(notdir $(f))) bin/

$(OPENSLIDEJAVA_BUILD): $(OPENSLIDEJAVA_TAR)
$(OPENSLIDEJAVA): PKG_BUILD = $(OPENSLIDEJAVA_BUILD)
$(OPENSLIDEJAVA): $(OPENSLIDEJAVA_TAR) $(OPENSLIDEJAVA_BUILD) $(PKG_CONFIG_EXE) $(OPENSLIDE)
	$(DIR_CONFIGURE) \
		ANT_HOME=$(ANT_HOME) \
		JAVA_HOME=$(JAVA_HOME)
	$(DIR_MAKE)
	$(DIR_MAKE) install
	$(CP) $(foreach f,$(OPENSLIDEJAVA),$(ROOT)/lib/openslide-java/$(notdir $(f))) bin/
