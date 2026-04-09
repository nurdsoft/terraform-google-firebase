resource "google_project_service" "required_apis" {
  provider = google.no_user_project_override
  project  = var.project_id
  for_each = toset([
    "cloudbuild.googleapis.com",
    "firestore.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "identitytoolkit.googleapis.com",
    "firebase.googleapis.com",
    "firebaserules.googleapis.com",
    "firebasestorage.googleapis.com",
    "storage.googleapis.com",
  ])
  service            = each.key
  disable_on_destroy = false
}

resource "google_firebase_project" "this" {
  provider = google-beta
  project  = var.project_id

  depends_on = [google_project_service.required_apis]
}

## Firebase iOS Apps
resource "google_firebase_apple_app" "this" {
  provider = google-beta
  for_each = local.ios_apps

  project         = var.project_id
  display_name    = each.value.display_name
  bundle_id       = each.value.bundle_id
  app_store_id    = try(each.value.app_store_id, null)
  team_id         = try(each.value.team_id, null)
  deletion_policy = each.value.deletion_policy

  depends_on = [google_firebase_project.this]
}

## Firebase Android Apps
resource "google_firebase_android_app" "this" {
  provider = google-beta
  for_each = local.android_apps

  project         = var.project_id
  display_name    = each.value.display_name
  package_name    = each.value.package_name
  sha1_hashes     = each.value.sha1_hashes
  sha256_hashes   = each.value.sha256_hashes
  deletion_policy = each.value.deletion_policy

  depends_on = [google_firebase_project.this]
}

## Firebase iOS App Config
data "google_firebase_apple_app_config" "this" {
  provider = google-beta
  for_each = var.fetch_mobile_app_config ? google_firebase_apple_app.this : {}

  project = var.project_id
  app_id  = each.value.app_id
}

## Firebase Android App Config
data "google_firebase_android_app_config" "this" {
  provider = google-beta
  for_each = var.fetch_mobile_app_config ? google_firebase_android_app.this : {}

  project = var.project_id
  app_id  = each.value.app_id
}

## Firebase Authentication
resource "google_identity_platform_config" "this" {
  provider = google-beta
  count    = var.firebase_auth == null ? 0 : 1
  project  = var.project_id

  multi_tenant {
    allow_tenants = false
  }

  sign_in {
    email {
      enabled           = contains(try(var.firebase_auth.enabled_providers, []), "EMAIL")
      password_required = contains(try(var.firebase_auth.enabled_providers, []), "EMAIL")
    }

    allow_duplicate_emails = try(var.firebase_auth.allow_duplicate_emails, false)

    phone_number {
      enabled            = contains(try(var.firebase_auth.enabled_providers, []), "PHONE")
      test_phone_numbers = try(var.firebase_auth.phone_test_numbers, {})
    }
  }

  depends_on = [google_firebase_project.this]
}

## Firebase Firestore
resource "google_firestore_database" "this" {
  for_each = {
    for database in try(var.firestore_config.databases, []) : database.id => database
  }

  project                     = var.project_id
  name                        = each.value.id
  location_id                 = each.value.location
  type                        = each.value.type
  concurrency_mode            = each.value.concurrency_mode
  app_engine_integration_mode = each.value.app_engine_mode

  depends_on = [
    google_firebase_project.this,
  ]
}

## Firestore Documents
resource "google_firestore_document" "this" {
  for_each = {
    for document in local.documents : "${document.db_id}-${document.collection}-${document.document_id}" => document
  }

  project     = var.project_id
  database    = google_firestore_database.this[each.value.db_id].name
  collection  = each.value.collection
  document_id = each.value.document_id
  fields      = jsonencode(each.value.fields)

  depends_on = [google_firestore_database.this]
}

## Firestore Sub-Documents
resource "google_firestore_document" "subdocs" {
  for_each = {
    for sub in local.subdocs : "${sub.db_id}-${sub.parent_col}-${sub.parent_doc}-${sub.collection}-${sub.document_id}" => sub
  }

  project     = var.project_id
  database    = google_firestore_database.this[each.value.db_id].name
  collection  = "${each.value.parent_col}/${each.value.parent_doc}/${each.value.collection}"
  document_id = each.value.document_id
  fields      = jsonencode(each.value.fields)

  depends_on = [google_firestore_database.this]
}

## Firebase Cloud Storage
resource "google_storage_bucket" "this" {
  for_each = local.storage_buckets

  project                     = var.project_id
  name                        = each.value.id
  location                    = each.value.location
  uniform_bucket_level_access = true
  labels                      = each.value.labels

  depends_on = [google_firebase_project.this]
}

## Link to Firebase
resource "google_firebase_storage_bucket" "this" {
  for_each = local.storage_buckets

  provider  = google-beta
  project   = var.project_id
  bucket_id = google_storage_bucket.this[each.value.id].id

  depends_on = [google_firebase_project.this]
}

## Firebase Rules
resource "google_firebaserules_ruleset" "this" {
  for_each = local.firebase_rules

  project = var.project_id

  source {
    files {
      name        = "${each.value.id}.rules"
      content     = each.value.content
      fingerprint = try(each.value.fingerprint, null)
    }

    language = try(each.value.language, null)
  }

  depends_on = [google_firebase_project.this]
}

resource "google_firebaserules_release" "this" {
  for_each = local.firebase_rules

  project      = var.project_id
  name         = each.value.name != "" ? each.value.name : each.value.id
  ruleset_name = google_firebaserules_ruleset.this[each.value.id].id

  depends_on = [
    google_firebaserules_ruleset.this,
    google_firebase_project.this,
  ]
}
