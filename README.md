ObjGTKGen
==========

ObjGTKGen is a utility that generates Objective-C language bindings for ObjGTK using GObject Introspection (parsing GIR files). ObjGTKGen is free software, licensed under the GNU LGPL.

ObjGTK is a fork of [CoreGTK](https://github.com/coregtk)(Gen) by Tyler Burton for [ObjFW](https://objfw.nil.im/) from Jonathan Schleifer.

The ObjGTK code base is compatible with the Objective C dialect of GCC ("Objective C 2.0") as introduced as of Mac OS X 10.5. So there is no need to use clang. There are plans to create a branch that delivers advanced support of clang language features, especially memory management via Automatic Reference Counting (ARC).

This is an untested preview release of ObjGTK. Take care when using. See [milestones](https://codeberg.org/Letterus/objgtkgen/milestones) for the further release plan.