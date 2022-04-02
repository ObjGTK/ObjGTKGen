ObjGTKGen
==========

ObjGTKGen is a utility that generates Objective-C language bindings for GNOME GLib/Gobject based libraries using GObject Introspection (GOI), which it does by parsing GIR files.

ObjGTK is a fork of [CoreGTK](https://github.com/coregtk)(Gen) by Tyler Burton for use
with [ObjFW](https://objfw.nil.im/) by Jonathan Schleifer.

## Usage

// FIXME

## Licensing

ObjGTKGen is free software. Its source files Tyler Burton originally released under
GNU LGPL 2.1 or later. This licensing was kept for the files existing and for the directory LibrarySourceAdditions, which is meant to be part of the generated libraries and is NOT part of the generator.

The additions to the generator written by Johannes Brakensiek are added under GNU GPL 3.0 or later. So any generator binary built using these files will need to be distributed under the terms of GNU GPL 3.0 or later.

Regarding GTK3 (and 4 or any other library wrapper) the generator is meant to generate wrapper source files which may be distributed under LGPL 2.1 or later.

## Code base

The ObjGTK code base should be compatible with the Objective C dialect of GCC ("Objective C 2.0") as introduced as of Mac OS X 10.5. So there should be no need to use clang. There are plans to implement advanced support of clang language features, especially memory management via Automatic Reference Counting (ARC).

Currently there are only untested, unstable preview releases of ObjGTK. Take care when using. API is going to change. See [milestones](https://codeberg.org/Letterus/objgtkgen/milestones) for the further release plan.

## How it works

The generator does the following currently:

1. It parses a GIR file (.gir) using `XMLReader` into object instances of the GIR classes (see directory `src/GIR`) (source models)
2. `Gir2Objc` then maps the information of the GIR models into the models prefixed with `OGTK` (see directory `src/Generator`) (target models). Please note that these models still hold API/class informationen using C names and types as used by the Glib/GObject libraries. These models provide methods to transform their Glib ("c") data/names/types into Objective C classes/names/types.
3. Finally `OGTKClassWriter` is called which writes out ObjC class definitions. Doing so it maps GObject types to Objective C / OGTK types (swaps them) by using `OGTKMapper`.
4. When all classes are written, necessary base classes at `src/BaseClasses` are added to `Output` (the generated library) to actually make it compile and run. Please note that the classes at `src/BaseClasses` are **not** used by the generator itself at any time.

You will find the main business logik in `Gir2Objc.m` and `Generator/OGTKMapper.m` as `Gir2Objc` calls `OGTKMapper` for multiple loops through all the parsed (Gobj) class/API information to complete dependency information (naming of parent classes) and the dependency graph (parent classes, depending classes). This is necessary to correctly insert `#import` and `@class` statements when generating the ObjC class definitions without getting stuck in a circular dependency loop.
