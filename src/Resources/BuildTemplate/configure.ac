AC_INIT(ObjGTK, 0.2, objfw@codingpastor.de)
AC_CONFIG_SRCDIR(src)
AC_CONFIG_AUX_DIR(build-aux)
AC_CONFIG_MACRO_DIR(build-aux/m4)

for i in configure.ac build-aux/m4/*; do
	AS_IF([test $i -nt configure], [
		AC_MSG_ERROR([$i is newer than configure! Run ./autogen.sh!])
	])
done

AC_CHECK_TOOL(OBJFW_CONFIG, objfw-config)
AS_IF([test x"$OBJFW_CONFIG" = x""], [
	AC_MSG_ERROR(You need ObjFW and objfw-config installed!)
])

test x"$OBJC" = x"" && OBJC="$($OBJFW_CONFIG --objc)"

AC_LANG([Objective C])
AC_PROG_OBJC
AC_PROG_OBJCPP
AC_PROG_LN_S
AC_PROG_INSTALL

CPP="$OBJCPP"
CPPFLAGS="$CPPFLAGS $OBJCPPFLAGS $($OBJFW_CONFIG --cppflags)"
OBJCFLAGS="$OBJCFLAGS -Wall $($OBJFW_CONFIG --objcflags)"
LDFLAGS="$LDFLAGS $($OBJFW_CONFIG --ldflags --rpath)"
FRAMEWORK_LIBS="$($OBJFW_CONFIG --framework-libs)"
LIBS="$($OBJFW_CONFIG --libs --rpath)"

AX_CHECK_COMPILER_FLAGS(-Wno-deprecated-declarations,
	[OBJCFLAGS="$OBJCFLAGS -Wno-deprecated-declarations"])

AX_CHECK_COMPILER_FLAGS(-Wno-deprecated,
	[OBJCFLAGS="$OBJCFLAGS -Wno-deprecated"])

AC_ARG_ENABLE(shared,
	AS_HELP_STRING([--disable-shared], [do not build shared library]))
AS_IF([test x"$enable_shared" != x"no"], [
	BUILDSYS_SHARED_LIB
	AC_SUBST(OBJGTK_SHARED_LIB, "${LIB_PREFIX}objgtk${LIB_SUFFIX}")

	BUILDSYS_FRAMEWORK([
		AC_SUBST(OBJGTK_FRAMEWORK, "ObjGTK.framework")
	])
])
AC_ARG_ENABLE(static, AS_HELP_STRING([--enable-static], [build static library]))
AS_IF([test x"$enable_static" = x"yes" -o x"$enable_shared" = x"no"], [
	AC_PATH_TOOL(AR, ar)
	AC_PROG_RANLIB
	AC_SUBST(OBJGTK_STATIC_LIB, "libobjgtk.a")
])

AC_ARG_WITH(gtk, AS_HELP_STRING([--with-gtk=PREFIX],
	[build with GTK in the specified prefix]))
AS_IF([test x"$with_gtk" != x"no" -a x"$with_gtk" != x""], [
       GTK_CPPFLAGS="$GTK_CFLAGS -I$with_gtk/include"
       GTK_LIBS="$GTK_LIBS -L$with_gtk/lib"
       CPPFLAGS="$CPPFLAGS -I$with_gtk/include"
       LIBS="-L$with_gtk/lib $LIBS"
       FRAMEWORK_LIBS="-L$with_gtk/lib $FRAMEWORK_LIBS"
])

PKG_CHECK_MODULES(gtk3, [gtk+-3.0 >= 3.24], [
	CPPFLAGS="$CPPFLAGS $gtk3_CFLAGS"
	LIBS="$LIBS $gtk3_LIBS"
], [
	AC_MSG_ERROR(You need gtk+-3.0 >= 3.24 installed!)
])

AS_IF([test x"$GOBJC" = x"yes"], [
	OBJCFLAGS="$OBJCFLAGS -Wwrite-strings -Wpointer-arith -Werror"
])

BUILDSYS_INIT

dnl We don't call AC_PROG_CPP, but only AC_PROG_OBJCPP and set CPP to OBJCPP
dnl and add OBJCPPFLAGS to CPPFLAGS, thus we need to AC_SUBST these ourself.
AC_SUBST(CPP)
AC_SUBST(CPPFLAGS)

AC_SUBST(OBJGTK_CPPFLAGS)
AC_SUBST(OBJGTK_LIBS)

AC_CONFIG_FILES([buildsys.mk extra.mk ObjGTK.oc])
AC_OUTPUT
