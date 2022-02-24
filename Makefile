SUBDIRS = src
PROG = objgtkgen
OBJS_EXTRA = src/objgtkgen.a

include buildsys.mk

LD = ${OBJC}