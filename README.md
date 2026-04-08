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

## Requirements

| Name | Version |
|------|---------|
| google | ~> 6.0 |
| google-beta | ~> 6.0 |

## Providers

| Name | Alias | Notes |
|------|-------|-------|
| google | no_user_project_override | Used for API enablement with user project override disabled |
| google | default | Used for GA resources |
| google-beta | default | Used for Firebase beta-backed resources/data sources |

## Resources

| Name | Type |
|------|------|
| google_project_service.required_apis | resource |
| google_firebase_project.this | resource |
| google_firebase_apple_app.this | resource |
| google_firebase_android_app.this | resource |
| google_identity_platform_config.this | resource |
| google_firestore_database.this | resource |
| google_firestore_document.this | resource |
| google_firestore_document.subdocs | resource |
| google_storage_bucket.this | resource |
| google_firebase_storage_bucket.this | resource |
| google_firebaserules_ruleset.this | resource |
| google_firebaserules_release.this | resource |
| google_firebase_apple_app_config.this | data source |
| google_firebase_android_app_config.this | data source |

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| project_id | string | n/a | Existing GCP project ID where Firebase resources are managed. |
| firebase_auth | object({ enabled_providers = optional(list(string), []), allow_duplicate_emails = optional(bool, false), phone_test_numbers = optional(map(string), {}) }) | null | Optional Firebase Authentication configuration. |
| firestore_config | object({ databases = optional(list(object({ id = string, location = string, type = optional(string, "FIRESTORE_NATIVE"), concurrency_mode = optional(string, "PESSIMISTIC"), app_engine_mode = optional(string, "DISABLED"), documents = optional(list(object({ collection = string, document_id = string, fields = map(any), subdocs = optional(list(object({ collection = string, document_id = string, fields = map(any) })), []) })), []) })), []) }) | {} | Optional Firestore databases and documents configuration. |
| firebase_storage | list(object({ name = string, location = string, labels = optional(map(string), {}) })) | [] | Optional Firebase Storage bucket definitions. |
| firebase_rules | list(object({ id = string, name = optional(string, ""), language = optional(string, ""), content = optional(string, ""), fingerprint = optional(string, "") })) | [] | Optional Firebase rules definitions. |
| fetch_mobile_app_config | bool | false | Whether to fetch iOS/Android app config artifacts after app creation. |
| firebase_ios_apps | list(object({ display_name = string, bundle_id = string, app_store_id = optional(string), team_id = optional(string), deletion_policy = optional(string, "DELETE") })) | [] | Optional list of Firebase iOS apps. bundle_id values must be unique. |
| firebase_android_apps | list(object({ display_name = string, package_name = string, sha1_hashes = optional(list(string), []), sha256_hashes = optional(list(string), []), deletion_policy = optional(string, "DELETE") })) | [] | Optional list of Firebase Android apps. package_name values must be unique. |

## Outputs

| Name | Description | Sensitive |
|------|-------------|-----------|
| project_id | Project ID in projects/{{project_id}} format. | No |
| ios_apps | Map of created Firebase iOS apps keyed by bundle ID. | No |
| android_apps | Map of created Firebase Android apps keyed by package name. | No |
| ios_app_config | Map of iOS app config artifacts keyed by bundle ID (base64 config content). Empty map when fetch_mobile_app_config is false. | Yes |
| android_app_config | Map of Android app config artifacts keyed by package name (base64 config content). Empty map when fetch_mobile_app_config is false. | Yes |

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
