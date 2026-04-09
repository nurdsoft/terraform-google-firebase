output "project_id" {
  description = "Project ID using the string patter projects/{{project_id}}"
  value       = "projects/${var.project_id}"
}

output "ios_apps" {
  description = "Map of Firebase iOS apps keyed by bundle ID."
  value = {
    for bundle_id, app in google_firebase_apple_app.this :
    bundle_id => {
      id           = app.id
      name         = app.name
      app_id       = app.app_id
      bundle_id    = app.bundle_id
      display_name = app.display_name
    }
  }
}

output "android_apps" {
  description = "Map of Firebase Android apps keyed by package name."
  value = {
    for package_name, app in google_firebase_android_app.this :
    package_name => {
      id           = app.id
      name         = app.name
      app_id       = app.app_id
      package_name = app.package_name
      display_name = app.display_name
    }
  }
}

output "ios_app_config" {
  description = "Map of iOS app config artifacts keyed by bundle ID (base64 content)."
  value = {
    for bundle_id, config in data.google_firebase_apple_app_config.this :
    bundle_id => {
      config_filename      = config.config_filename
      config_file_contents = config.config_file_contents
    }
  }
  sensitive = true
}

output "android_app_config" {
  description = "Map of Android app config artifacts keyed by package name (base64 content)."
  value = {
    for package_name, config in data.google_firebase_android_app_config.this :
    package_name => {
      config_filename      = config.config_filename
      config_file_contents = config.config_file_contents
    }
  }
  sensitive = true
}
