SUBDIRS = Exceptions \
	Generator \
	GIR \
	XMLReader

STATIC_LIB_NOINST = gir2objc.a

OBJS_EXTRA = Exceptions/lib.a \
	Generator/lib.a \
	GIR/lib.a \
	XMLReader/lib.a

SRCS = Gir2Objc.m \
	Gir2ObjcApplication.m

include ../buildsys.mk

CPPFLAGS += -DDATA_DIR='"${DESTDIR}${datadir}/${PACKAGE_NAME}"'
