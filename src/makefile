#Executable
EXECUTABLE=objgtkgen

#Sources
SOURCES=ObjGTKGen.m \
	XMLReader/XMLReader.m \
	GIR/GIRAPI.m \
	GIR/GIRArray.m \
	GIR/GIRBase.m \
	GIR/GIRClass.m \
	GIR/GIRConstant.m \
	GIR/GIRConstructor.m \
	GIR/GIRDoc.m \
	GIR/GIREnumeration.m \
	GIR/GIRField.m \
	GIR/GIRFunction.m \
	GIR/GIRImplements.m \
	GIR/GIRInclude.m \
	GIR/GIRInterface.m \
	GIR/GIRParameter.m \
	GIR/GIRProperty.m \
	GIR/GIRMember.m \
	GIR/GIRMethod.m \
	GIR/GIRNamespace.m \
	GIR/GIRPrerequisite.m \
	GIR/GIRReturnValue.m \
	GIR/GIRType.m \
	GIR/GIRVarargs.m \
	GIR/GIRVirtualMethod.m \
	Generator/OGTKClassWriter.m \
	Generator/OGTKClass.m \
	Generator/OGTKMethod.m \
	Generator/OGTKParameter.m \
	Generator/OGTKUtil.m \
	Generator/OGTKMapper.m \
	Generator/OFDictionary+OGTKJsonDictionaryOfFile.m \
	Gir2Objc.m \
	Exceptions/OGTKIncorrectConfigException.m \
	Exceptions/OGTKNoGIRAPIException.m \
	Exceptions/OGTKNoGIRDictException.m \
	Exceptions/OGTKReceivedNilExpectedStringException.m

#Objects
OBJECTS=$(SOURCES:.m=.o)

#compiler
CC=clang

#CFLAGS
CFLAGS=`objfw-config --cppflags` -g -O0 -c -Wall

#Objective-c specific flags
OBJCFLAGS=`objfw-config --objcflags`

#Objective-c specific flags
MACOBJCFLAGS=$(OBJCFLAGS)

#GTK dependencies
GTKDEPS=`pkg-config --libs gtk+-3.0`

LIBS=`objfw-config --rpath --libs` $(GTKDEPS)

#Common flags
COMMONFLAGS=$(CFLAGS) $(OBJCFLAGS)

#Targets

#Linux Target
linux: all

#Mac Target
mac: COMMONFLAGS=$(MACOBJCFLAGS) $(GTKDEPS)
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
	rm -rf BaseClasses/*.o BaseClasses/*.d
	rm -rf Generator/*.o Generator/*.d
	rm -rf GIR/*.o GIR/*.d
	rm -rf XMLReader/*.o XMLReader/*.d
	rm -rf Exceptions/*.o Exceptions/*.d
#Uncomment these if you want to also clean the generated source files
#	rm -rf Output/ObjGTK/*.h
#	rm -rf Output/ObjGTK/*.m
