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
