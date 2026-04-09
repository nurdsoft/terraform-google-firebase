module "firestore" {
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
              },
              {
                collection  = "devices"
                document_id = "device2"
                fields      = { os = "ios", version = "17" }
              }
            ]
          },
          {
            collection  = "users"
            document_id = "user2"
            fields      = { name = "Bob", role = "editor" }
          }
        ]
      },
      {
        id       = "analytics-db"
        location = "us-central"
        type     = "FIRESTORE_NATIVE"

        documents = [
          {
            collection  = "events"
            document_id = "event1"
            fields      = { type = "login", timestamp = "2025-09-03T12:00:00Z" }
          }
        ]
      }
    ]
  }

  firebase_rules = [
    {
      id      = "firestore-inline-rules"
      content = <<EOT
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow create: if request.auth != null && request.auth.uid == request.resource.data.uid;
      allow update, delete: if request.auth != null && request.auth.uid == resource.data.uid;
      allow read: if request.auth != null && request.auth.uid == resource.data.uid;
    }
  }
}
EOT
    },
    {
      id      = "firestore"
      content = file("${path.module}/example.rules")
    }
  ]
}
