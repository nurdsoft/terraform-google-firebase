module "firebase_mobile_apps" {
  source                  = "../../"
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

output "ios_apps" {
  value = module.firebase_mobile_apps.ios_apps
}

output "android_apps" {
  value = module.firebase_mobile_apps.android_apps
}

output "ios_app_config" {
  value     = module.firebase_mobile_apps.ios_app_config
  sensitive = true
}

output "android_app_config" {
  value     = module.firebase_mobile_apps.android_app_config
  sensitive = true
}
