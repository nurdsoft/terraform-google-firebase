variable "project_id" {
  description = "The ID of the project in which the resource belongs."
  type        = string
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
    name        = string
    location    = string
    labels      = optional(map(string), {})
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
