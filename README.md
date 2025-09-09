# Google Firebase Terraform module

Terraform module which creates and manages irebase resources on top of an existing GCP project.

---

## Usage

### Firestore Database

```hcl
module "firebase" {
  source     = "../../"
  project_id = "project-id"

  firestore_config = {
    databases = [
      {
        id               = "(default)"
        location         = "nam5"
        type             = "FIRESTORE_NATIVE"
        concurrency_mode = "PESSIMISTIC"
        app_engine_mode  = "DISABLED"

        documents = [
          {
            collection  = "users"
            document_id = "user1"
            fields      = { name = "Alice", role = "admin" }

            subdocs = [
              {
                collection  = "devices"
                document_id = "device1"
                fields      = { os = "android", version = "13" }
              }
            ]
          }
        ]
      }
    ]
  }

  firebase_storage = [
    {
      name     = "my-firebase-bucket"
      location = "US"
      labels   = { env = "dev" }
    }
  ]

  firebase_rules = [
    {
      id      = "firestore-inline-rules"
      content = <<EOT
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
EOT
    },
    {
      id        = "firestore-file-rules"
      file_path = "${path.module}/firestore.rules"
    }
  ]

  firebase_auth = {
    enabled_providers      = ["EMAIL"]
    allow_duplicate_emails = false
    password_policy = {
      min_length = 8
    }
  }
}
```

---

## Examples 

- [firestore database](https://github.com/nurdsoft/terraform-google-firebase/tree/main/examples/firestore) - Example showing how to provision a **Firestore database**, including attaching Firebase security rules.  

---

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name        | Version |
| ----------- | ------- |
| terraform   | >= 1.5  |
| google      | ~> 6.0  |
| google-beta | ~> 6.0  |

## Providers

| Name        | Version |
| ----------- | ------- |
| Google      | ~> 6.0  | 
| Google-beta | ~> 6.0  |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_project_service.required_apis](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_firebase_project.this](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/firebase_project) | resource |
| [google_identity_platform_config.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/identity_platform_config) | resource |
| [google_firestore_database.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/firestore_database) | resource |
| [google_firestore_document.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/firestore_document) | resource |
| [google_firestore_document.subdocs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/firestore_document) | resource |
| [google_storage_bucket.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_firebase_storage_bucket.this](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/firebase_storage_bucket) | resource |
| [google_firebaserules_ruleset.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/firebaserules_ruleset) | resource |
| [google_firebaserules_release.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/firebaserules_release) | resource |

## Inputs

| Name               | Type             | Default | Description                                                                      |
| ------------------ | ---------------- | ------- | -------------------------------------------------------------------------------- |
| `project_id`       | `string`         | n/a     | **Required.** The GCP Project ID with Firebase enabled.                          |
| `firestore_config` | `list(object)`   | `null`  | Firestore configuration including databases, documents, and subdocuments.        |
| `firebase_storage` | `list(object)`   | `[]`    | List of Firebase Cloud Storage buckets to create and link.                       |
| `firebase_rules`   | `list(object)`   | `[]`    | Firebase security rulesets (inline or file-based).                               |
| `firebase_auth`    | `object`         | `null`  | Firebase Authentication configuration. If `null`, authentication is not managed. |

### Outputs

| Name       | Description                                                  |
| ---------- | ------------------------------------------------------------ |
| `project_id` | Project ID using the string patter `projects/{{project_id}}` |
<!-- END_TF_DOCS -->

---

## Authors

Module is maintained by [Nurdsoft](https://github.com/nurdsoft).

---

## License

Apache 2 Licensed. See [LICENSE](https://github.com/nurdsoft/terraform-google-firebase/tree/main/LICENSE) for full details.
