# README - About this directory

The generator will try to copy source files from a directory:

For each destination library that is generated it will try to
    copy the contents from a dir that matches a name 
    of the pattern ${girName}-${version}, f.e. "Camel-1.2".
    This pattern usually should be the naming of the
    corresponding input gir file.