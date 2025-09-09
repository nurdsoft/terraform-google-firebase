output "project_id" {
  description = "Project ID using the string patter projects/{{project_id}}"
  value       = "projects/${var.project_id}"
}
