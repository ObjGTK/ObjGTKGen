ObjGTKGen
==========

ObjGTKGen is a utility that generates Objective-C language bindings for GNOME GLib/Gobject based libraries using GObject Introspection (GOI), which it does by parsing GIR files.

ObjGTK is a fork of [CoreGTK](https://github.com/coregtk)(Gen) by Tyler Burton for use
with [ObjFW](https://objfw.nil.im/) by Jonathan Schleifer.

## Usage

`objgtkgen` currently is meant to be run within a local directory like the one given in this repository. Next to the binary it expects a `Config` dir containing the two files provided and it is going put its output into a directory specified in `global_conf.json`.

Run it like so:

```
./objgtkgen </path/to/file.gir>
```

f.e.
```
./objgtkgen /usr/share/gir-1.0/Gtk-3.0.gir
```

This will generate the library definition for GTK3 into the output dir, including all the library dependencies specified by `Gtk-3.0.gir`.

The generator is going to lookup these dependencies recursively at the path of the gir file specified as argument. You may exclude library and class dependencies of each library by modifying `global_conf.json` and `library_conf.json`.

## Dependencies and building

### Dependencies

- You need [ObjFW](https://objfw.nil.im/).
- For building a generated library you need [OGObject](https://codeberg.org/ObjGTK/OGObject).

### Building

- `chmod +x autogen.sh && ./autogen.sh && ./configure && make`


## Licensing

ObjGTKGen is free software. Its source files Tyler Burton originally released under
GNU LGPL 2.1 or later. This licensing was kept for the files existing and for the directory LibrarySourceAdditions, which is meant to be part of the generated libraries and is NOT part of the generator.

The additions to the generator written by Johannes Brakensiek are added under GNU GPL 3.0 or later. So any generator binary built using these files will need to be distributed under the terms of GNU GPL 3.0 or later.

Regarding GTK3 (and 4 or any other library wrapper) the generator is meant to generate wrapper source files which may be distributed under LGPL 2.1 or later.

## Code base

The code base of ObjGTK should be compatible with the Objective C dialect of GCC ("Objective C 2.0") as introduced as of Mac OS X 10.5. So there should be no need to use clang. There are plans to implement advanced support of clang language features, especially memory management via Automatic Reference Counting (ARC).

Currently there are only untested, unstable preview releases of ObjGTK. Take care when using. API is going to change. See [milestones](https://codeberg.org/Letterus/objgtkgen/milestones) for the further release plan.

## How it works

The generator does the following currently:

1. It parses a GIR file (.gir) using `XMLReader` into object instances of the GIR classes (see directory `src/GIR`) (source models)
2. `Gir2Objc` then maps the information of the GIR models into the models prefixed with `OGTK` (see directory `src/Generator`) (target models). Please note that these models still hold API/class informationen using C names and types as used by the Glib/GObject libraries. These models provide methods to transform their Glib ("c") data/names/types into Objective C classes/names/types.
3. It does the same for further libraries iterating recursively through all the libraries specified as dependencies by the gir file given.
4. When all library and class definitions are held in memory to resolve class dependencies correctly using `OGTKMapper`, then `OGTKLibraryWriter` is called to first invoke `OGTKClassWriter`.
5. `OGTKClassWriter` is going to write out the ObjC class definitions. It does so by mapping GObject types to Objective C / OGTK types (swapping them) using the class definitions hold in multiple `OFDictionary`s by `OGTKMapper`.
6. When all classes are written, additional manual source files, that may be added at `LibrarySourceAdditions` are added to `Output` (the generated library) to actually make it compile and run. Please note the classes at `LibrarySourceAdditions` are **not** part of the generator itself. You may add your own code by creating new directories which naming convention needs to meet that of the corresponding gir file.

You will find the main business logik preparing data structures in `Gir2Objc.m` and `Generator/OGTKMapper.m` as `Gir2Objc` calls `OGTKMapper` for multiple loops through all the parsed (Gobj) class/API information to complete dependency information (naming of parent classes) and the dependency graph (parent classes, depending classes). This is necessary to correctly insert `#import` and `@class` statements when generating the ObjC class definitions without getting stuck in a circular dependency loop.

For the actual generation and composition of the source files see `Generator/OGTKLibraryWriter.m` and `Generator/OGTKClassWriter.m`.