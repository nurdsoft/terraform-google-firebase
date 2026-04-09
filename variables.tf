variable "project_id" {
  description = "The ID of the project in which the resource belongs."
  type        = string

  validation {
    condition     = length(trimspace(var.project_id)) > 0
    error_message = "project_id must not be empty."
  }
}

variable "firebase_auth" {
  description = "(Optional) Firebase Authentication config. If null, authentication is not managed."
  type = object({
    enabled_providers      = optional(list(string), [])
    allow_duplicate_emails = optional(bool, false)
    phone_test_numbers     = optional(map(string), {})
  })

  default = null
}

variable "firestore_config" {
  description = "(Optional) Firestore configuration with database and documents"
  type = object({
    databases = optional(list(object({
      id               = string
      location         = string
      type             = optional(string, "FIRESTORE_NATIVE")
      concurrency_mode = optional(string, "PESSIMISTIC")
      app_engine_mode  = optional(string, "DISABLED")

      documents = optional(list(object({
        collection  = string
        document_id = string
        fields      = map(any)

        subdocs = optional(list(object({
          collection  = string
          document_id = string
          fields      = map(any)
        })), [])
      })), [])
    })), [])
  })

  default = {}
}

variable "firebase_storage" {
  description = "(Optional) list of Firebase Cloud Storage buckets"
  type = list(object({
    name     = string
    location = string
    labels   = optional(map(string), {})
  }))
  default = []
}

variable "firebase_rules" {
  description = "(Optional) list of Firebase rulesets to deploy (Firestore & Storage). Either inline content or file path can be used."
  type = list(object({
    id          = string
    name        = optional(string, "")
    language    = optional(string, "")
    content     = optional(string, "")
    fingerprint = optional(string, "")
  }))

  default = []
}

variable "fetch_mobile_app_config" {
  description = "(Optional) Whether to fetch Firebase iOS/Android app config artifacts after app creation."
  type        = bool
  default     = false
}

variable "firebase_ios_apps" {
  description = "(Optional) List of Firebase iOS apps to create in the existing Firebase project."
  type = list(object({
    display_name    = string
    bundle_id       = string
    app_store_id    = optional(string)
    team_id         = optional(string)
    deletion_policy = optional(string, "DELETE")
  }))
  default = []

  validation {
    condition     = alltrue([for app in var.firebase_ios_apps : length(trimspace(app.display_name)) > 0 && length(trimspace(app.bundle_id)) > 0])
    error_message = "Each iOS app must have non-empty display_name and bundle_id."
  }

  validation {
    condition     = length(var.firebase_ios_apps) == length(toset([for app in var.firebase_ios_apps : app.bundle_id]))
    error_message = "firebase_ios_apps bundle_id values must be unique."
  }

  validation {
    condition     = alltrue([for app in var.firebase_ios_apps : contains(["DELETE", "ABANDON"], app.deletion_policy)])
    error_message = "firebase_ios_apps deletion_policy must be either DELETE or ABANDON."
  }
}

variable "firebase_android_apps" {
  description = "(Optional) List of Firebase Android apps to create in the existing Firebase project."
  type = list(object({
    display_name    = string
    package_name    = string
    sha1_hashes     = optional(list(string), [])
    sha256_hashes   = optional(list(string), [])
    deletion_policy = optional(string, "DELETE")
  }))
  default = []

  validation {
    condition     = alltrue([for app in var.firebase_android_apps : length(trimspace(app.display_name)) > 0 && length(trimspace(app.package_name)) > 0])
    error_message = "Each Android app must have non-empty display_name and package_name."
  }

  validation {
    condition     = length(var.firebase_android_apps) == length(toset([for app in var.firebase_android_apps : app.package_name]))
    error_message = "firebase_android_apps package_name values must be unique."
  }

  validation {
    condition     = alltrue([for app in var.firebase_android_apps : contains(["DELETE", "ABANDON"], app.deletion_policy)])
    error_message = "firebase_android_apps deletion_policy must be either DELETE or ABANDON."
  }
}
