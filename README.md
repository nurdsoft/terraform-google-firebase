# Google Firebase Terraform Module

Terraform module for managing Firebase resources on top of an existing GCP project.

## What This Module Supports

- Initializing Firebase on an existing GCP project
- Firebase Authentication configuration
- Firestore databases and documents
- Firebase Storage bucket linking
- Firebase Rules ruleset and release management
- Multiple Firebase iOS app registrations
- Multiple Firebase Android app registrations
- Firebase mobile app config artifact retrieval

## Existing Project Requirement

This module does not create a GCP project. You must pass an existing project ID via project_id.

## Usage

```hcl
module "firebase" {
  source     = "../../"
  project_id = "existing-firebase-project-id"
  fetch_mobile_app_config = true

  firebase_ios_apps = [
    {
      display_name = "My iOS App"
      bundle_id    = "com.example.ios"
    },
    {
      display_name = "My iOS App Staging"
      bundle_id    = "com.example.ios.staging"
      team_id      = "ABCDE12345"
    }
  ]

  firebase_android_apps = [
    {
      display_name = "My Android App"
      package_name = "com.example.android"
    },
    {
      display_name  = "My Android App Staging"
      package_name  = "com.example.android.staging"
      sha1_hashes   = ["2145bdf698b8715039bd0e83f2069bed435ac21c"]
      sha256_hashes = ["2145bdf698b8715039bd0e83f2069bed435ac21ca1b2c3d4e5f6123456789abc"]
    }
  ]
}
```

## Inputs (New Mobile App Options)

- project_id (string, required): Existing GCP project ID.
- fetch_mobile_app_config (bool, optional): Defaults to false. When true, app config artifacts are fetched and populated in config outputs.
- firebase_ios_apps (list(object), optional): iOS apps to create.
  - display_name (required)
  - bundle_id (required, unique)
  - app_store_id (optional)
  - team_id (optional)
  - deletion_policy (optional, default DELETE, allowed: DELETE or ABANDON)
- firebase_android_apps (list(object), optional): Android apps to create.
  - display_name (required)
  - package_name (required, unique)
  - sha1_hashes (optional)
  - sha256_hashes (optional)
  - deletion_policy (optional, default DELETE, allowed: DELETE or ABANDON)

## Outputs (New Mobile App Outputs)

- ios_apps: Map of created iOS apps keyed by bundle ID.
- android_apps: Map of created Android apps keyed by package name.
- ios_app_config: Map of iOS config artifacts (sensitive, base64 config content). Empty map when fetch_mobile_app_config is false.
- android_app_config: Map of Android config artifacts (sensitive, base64 config content). Empty map when fetch_mobile_app_config is false.

## Provider Support Validation

The mobile app functionality uses provider-supported Firebase resources and data sources:

- google_firebase_apple_app
- google_firebase_android_app
- google_firebase_apple_app_config (data source)
- google_firebase_android_app_config (data source)

These Firebase app endpoints are beta-backed in provider documentation, so this module uses google-beta for app creation and app config retrieval.

## Known Limitations and Requirements

- Firebase app config outputs contain base64-encoded bootstrap credentials; they are marked sensitive.
- This module does not manage API key resources for mobile apps.
- The module enables required APIs and initializes Firebase, but it assumes the caller has sufficient IAM permissions.

## Remote State / Backend Guidance

This module intentionally does not define a backend block. Configure remote state in your root module (for example, a GCS backend) per environment.

## Examples

- examples/firestore: Firestore + rules example
- examples/mobile-apps: Multiple iOS and Android app example

## License

Apache 2. See LICENSE.
