module "firebase_mobile_apps" {
  source                  = "git::https://github.com/nurdsoft/terraform-google-firebase.git?ref=v1.1.0"
  project_id              = "existing-firebase-project-id"
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
      sha1_hashes   = var.android_staging_sha1_hashes
      sha256_hashes = var.android_staging_sha256_hashes
    }
  ]
}
