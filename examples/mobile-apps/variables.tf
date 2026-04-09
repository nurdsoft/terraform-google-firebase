variable "android_staging_sha1_hashes" {
  description = "Optional SHA-1 fingerprints for the Android staging app signing certificates."
  type        = list(string)
  default     = []
}

variable "android_staging_sha256_hashes" {
  description = "Optional SHA-256 fingerprints for the Android staging app signing certificates."
  type        = list(string)
  default     = []
}
