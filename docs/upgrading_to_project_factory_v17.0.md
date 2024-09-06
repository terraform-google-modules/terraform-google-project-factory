# Upgrading to Project Factory v17.0

The v17.0 release of Project Factory is a backwards incompatible release.

### Google Cloud Provider Project deletion_policy

The `deletion_policy` for projects now defaults to `"PREVENT"` rather than `"DELETE"`.  This aligns with the behavior in Google Cloud Platform Provider v6+.  To maintain the old behavior you can set `deletion_policy = "DELETE"`.

```diff
  module "project" {
-   version          = "~> 16.0"
+   version          = "~> 17.0"

+   deletion_policy = "DELETE"
}
```

### Google Cloud Platform Provider upgrade

The Project Factory module now requires version `5.41` or higher of the Google Cloud Platform Provider and `5.41` or higher of the Google Cloud Platform Beta Provider.
