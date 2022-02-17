include ../extra.mk

SHARED_LIB = ${%%UCLIBNAME%%_SHARED_LIB}
STATIC_LIB = ${%%UCLIBNAME%%_STATIC_LIB}
FRAMEWORK = ${%%UCLIBNAME%%_FRAMEWORK}
LIB_MAJOR = %%VERSIONLIBMAJOR%%
LIB_MINOR = %%VERSIONLIBMINOR%%

SRCS = $(wildcard *.m)

INCLUDES = ${SRCS:.m=.h} \
	%%LIBNAME%%-Umbrella.h

include ../buildsys.mk

LD = ${OBJC}
