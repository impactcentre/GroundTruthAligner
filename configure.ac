#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([d-images],[1.0.0],[antonio.corbi@ua.es])

AC_CONFIG_SRCDIR([src/main/main.d])

AM_INIT_AUTOMAKE([-Wall -Werror foreign dist-bzip2])
AM_SILENT_RULES([yes])

# AC_CONFIG_HEADER([src/config.d])

# Checks for programs.
AC_PROG_RANLIB
AM_PROG_AR
AC_CHECK_PROGS(DC, dmd gdc ldc2)

AM_CONDITIONAL([DMD], [test x$DC = xdmd])

# Determine whether to compile with debug settings.  Essentially this just
# disables compiler optimizations for now
AC_ARG_ENABLE(debug-mode, [AS_HELP_STRING([--enable-debug-mode],
			  [build with debug settings (no optimization, test coverage)])],,
              		  [enable_debug_mode=no])
AC_MSG_CHECKING(whether to compile with debug settings)
if test "x$enable_debug_mode" = "xyes"; then
    AC_MSG_RESULT(yes)
    DFLAGS=["-gc -gs -debug"]
    AC_SUBST([DFLAGS])
else
    AC_MSG_RESULT(no)
fi

# Determine whether to compile with optimization settings.  Essentially this just
# disables compiler optimizations for now
AC_ARG_ENABLE(opt-mode, [AS_HELP_STRING([--enable-opt-mode],
			[build with optimization settings (optimization, release-mode, inline)])],,
              		[enable_opt_mode=no])
AC_MSG_CHECKING(whether to compile with optimization settings)
if test "x$enable_opt_mode" = "xyes"; then
    AC_MSG_RESULT(yes)
    DFLAGS=["-O -release -inline"]
    AC_SUBST([DFLAGS])
else
    AC_MSG_RESULT(no)
fi

# Checks for libraries.

PKG_CHECK_MODULES(CORE_DEPS, [gtkd2])

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.

AC_CONFIG_FILES([
	Makefile
	src/Makefile
	src/main/Makefile
	src/gui/Makefile
	src/config/constants.d
])

AC_OUTPUT
