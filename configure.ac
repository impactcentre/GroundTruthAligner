#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([d-images], [1.0.0], [antonio.corbi@ua.es])

AC_CONFIG_SRCDIR([src/main/main.d])

AM_INIT_AUTOMAKE([-Wall -Werror foreign dist-bzip2])
AM_SILENT_RULES([yes])

# AC_CONFIG_HEADER([src/config.d])

# Checks for programs.
AC_CHECK_PROGS(DC, dmd gdc ldc2)

AM_CONDITIONAL([DMD], [test x$DC = xdmd])

# Checks for libraries.

PKG_CHECK_MODULES(CORE_DEPS, [gtkd2])

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.

AC_CONFIG_FILES([
	Makefile
	src/Makefile
	src/main/Makefile
])

AC_OUTPUT
