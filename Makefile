SUBDIRS = src
PROG = objgtkgen
OBJS_EXTRA = src/objgtkgen.a

include buildsys.mk

LD = ${OBJC}

install-extra:
	mkdir -p ${DESTDIR}${datadir}/${PACKAGE_NAME}/
	cp -R Config ${DESTDIR}${datadir}/${PACKAGE_NAME}/
	cp -R Resources ${DESTDIR}${datadir}/${PACKAGE_NAME}/
	cp -R LibrarySourceAdditions ${DESTDIR}${datadir}/${PACKAGE_NAME}/