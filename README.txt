This is a set of scripts for building OpenSlide for Windows, including all
of its dependencies, using MinGW.

This is a very early version.  Do not rely on its output.

Cross-compiling from Linux
--------------------------

You will need MinGW, OpenJDK, and Apache Ant.  You will also need the
GNU Classpath version of jni.h installed.  (On Fedora this is in the
libgcj-devel package.)

Then:

make CROSS_HOST=i686-pc-mingw32

Output will be in bin/.

Building natively on Windows
----------------------------

You will need a JDK, Apache Ant, MinGW, and MSYS.  Edit the MSYS fstab file
(e.g. C:\MinGW\msys\1.0\etc\fstab) to mount your JDK and Apache Ant
installations within the MSYS directory tree:

C:\Progra~1\Java\jdk1.6.0_29   /java
C:\ant                         /ant

You must use 8.3 short file names for path elements that contain spaces.

Then:

make ANT_HOME=/ant JAVA_HOME=/java

Output will be in bin/.

Note that cross-compiling is MUCH faster than compiling natively.

Make targets
------------

all
	Build OpenSlide and all dependencies.
sdist
	Build Zip file containing build system and sources for OpenSlide
	and all dependencies.
bdist
	Build Zip file containing binaries of OpenSlide and all
	dependencies.
clean
	Delete build and binary directories, but not downloaded tarballs.
