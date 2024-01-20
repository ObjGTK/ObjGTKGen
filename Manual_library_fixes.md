# Manual library fixes

Notes - turned into code/git later

## Pango

OGPangoCoverage.h needs

```
#define PANGO_TYPE_COVERAGE              (pango_coverage_get_type ())
#define PANGO_COVERAGE(object)           (G_TYPE_CHECK_INSTANCE_CAST ((object), PANGO_TYPE_COVERAGE, PangoCoverage))
#define PANGO_IS_COVERAGE(object)        (G_TYPE_CHECK_INSTANCE_TYPE ((object), PANGO_TYPE_COVERAGE))
#define PANGO_COVERAGE_CLASS(klass)      (G_TYPE_CHECK_CLASS_CAST ((klass), PANGO_TYPE_COVERAGE, PangoCoverageClass))
#define PANGO_IS_COVERAGE_CLASS(klass)   (G_TYPE_CHECK_CLASS_TYPE ((klass), PANGO_TYPE_COVERAGE))
#define PANGO_COVERAGE_GET_CLASS(obj)    (G_TYPE_INSTANCE_GET_CLASS ((obj), PANGO_TYPE_COVERAGE, PangoCoverageClass))
```

Because these are in pango-coverage-private.h, which is not part of public headers.

## Gio

OGGSettingsBackend.h requires:

```
#define G_SETTINGS_ENABLE_BACKEND

#include <gio/gsettingsbackend.h>
```

## Gdk

OGGdkWindow.m/.h needs to remove `- (void)destroyNotify;`, because the C part is not defined in the headers.

## EBook

- e_book_client_view_is_running is private/not in the headers
- OGEBookClient: `+ (OGEClient*)connectSyncWithSource:(OGESource*)source waitForConnectedSeconds:(guint32)waitForConnectedSeconds cancellable:(GCancellable*)cancellable` needs to return OGEBookClient

## Camel

-  OGCamelFolderSummary.m: 282 | - (guint32)nextUid is defined twice and needs to be renamed
- camel_mime_parser_set_header_regex is private/not in the headers
- OGCamelMessageInfo.m:76:12: 
```
error: incompatible pointer types initializing 'OFString *' with an expression of type 'gchar *' (aka 'char *') [-Werror,-Wincompatible-pointer-types]
   76 |         OFString* returnValue = gobjectValue;
```
   seems to be missing info about ownership
- `OGCamelSExp.m:23:24: error: call to undeclared function 'camel_sexp_to_sql_sexp'; ISO C99 and later do not support implicit function declarations [-Wimplicit-function-declaration]
   23 |         gchar* gobjectValue = camel_sexp_to_sql_sexp([sexp UTF8String]);`


/usr/bin/ld: /usr/local/lib64/libogio.so: undefined reference to `g_io_module_load'
/usr/bin/ld: /usr/local/lib64/libogebook.so: undefined reference to `e_book_client_view_is_running'
/usr/bin/ld: /usr/local/lib64/libogio.so: undefined reference to `g_io_module_unload'
/usr/bin/ld: /usr/local/lib64/libogcamel.so: undefined reference to `camel_mime_parser_set_header_regex'
/usr/bin/ld: /usr/local/lib64/libogio.so: undefined reference to `g_io_module_query'
