# README - About this directory

The generator will try to copy source files from a directory:

For each destination library that is generated it will try to
    copy the contents of a dir that either matches the configured 
    "customName" of the library (see Config/library_conf.json) or 
    otherwise try a directory name of the pattern ${girName}-${version},
    f.e. "Camel-1.2". This pattern usually should match the naming
    of the gir file.