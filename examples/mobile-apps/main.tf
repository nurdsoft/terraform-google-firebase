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
      sha1_hashes   = ["2145bdf698b8715039bd0e83f2069bed435ac21c"]
      sha256_hashes = ["2145bdf698b8715039bd0e83f2069bed435ac21ca1b2c3d4e5f6123456789abc"]
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
