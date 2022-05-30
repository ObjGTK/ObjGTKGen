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


## Gdk

OGGdkWindow.m/.h needs to remove `- (void)destroyNotify;`, because the C part is not defined in the headers.