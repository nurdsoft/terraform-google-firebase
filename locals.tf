locals {
  # List of documents across all databases
  documents = flatten([
    for db in try(var.firestore_config.databases, []) : [
      for doc in try(db.documents, []) : {
        db_id       = db.id
        collection  = doc.collection
        document_id = doc.document_id
        fields      = doc.fields
      }
    ]
  ])

  # List of subdocs
  subdocs = flatten([
    for db in try(var.firestore_config.databases, []) : [
      for doc in try(db.documents, []) : [
        for sub in try(doc.subdocs, []) : {
          db_id       = db.id
          parent_doc  = doc.document_id
          parent_col  = doc.collection
          collection  = sub.collection
          document_id = sub.document_id
          fields      = sub.fields
        }
      ]
    ]
  ])

  storage_buckets = {
    for storage in var.firebase_storage : storage.id => storage
  }

  firebase_rules = {
    for rule in var.firebase_rules :
    rule.id => rule
  }

  ios_apps = {
    for app in var.firebase_ios_apps :
    app.bundle_id => app
  }

  android_apps = {
    for app in var.firebase_android_apps :
    app.package_name => app
  }
}
