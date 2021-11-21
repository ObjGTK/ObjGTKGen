#Executable
EXECUTABLE=HelloWorld

#Sources
SOURCES=HelloWorld.m

#Objects
OBJECTS=$(SOURCES:.m=.o)

#compiler
CC=clang

#CFLAGS
CFLAGS=`objfw-config --cppflags` `pkg-config --cflags gtk+-3.0` -I/usr/local/include/ObjGTK -g -O0 -c

#Objective-c specific flags
OBJCFLAGS=`objfw-config --objcflags`

#Objective-c specific flags
MACOBJCFLAGS=$(OBJCFLAGS)

#OGTK dependency
OGTKDEPS=`pkg-config --libs gtk+-3.0` -lobjgtk

#Common flags
COMMONFLAGS=$(CFLAGS) $(OBJCFLAGS)

LIBS=`objfw-config --rpath --libs` $(OGTKDEPS)

#Targets

#Linux Target
linux: all

#Mac Target
mac: COMMONFLAGS=$(MACOBJCFLAGS) $(OGTKDEPS)
mac: all

#Windows Target
windows: all

#All Target
all: $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(CC) $(OBJECTS) $(LIBS) -o $@

%.o: %.m
	$(CC) $(COMMONFLAGS) $< -o $@

clean: 
	rm -rf *.o *.d $(EXECUTABLE)
	rm -rf ObjGTK/*.o ObjGTK/*.d $(EXECUTABLE)
