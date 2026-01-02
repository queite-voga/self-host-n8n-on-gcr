variable "gcp_project_id" {
  description = "Google Cloud project ID."
  type        = string
}

variable "gcp_region" {
  description = "Google Cloud region for deployment."
  type        = string
  default     = "us-west2"
}

variable "use_custom_image" {
  description = "Set to true to use custom Docker image (Option B), false to use official n8n image (Option A - recommended)."
  type        = bool
  default     = false
}

variable "db_name" {
  description = "Name for the Cloud SQL database."
  type        = string
  default     = "n8n"
}

variable "db_user" {
  description = "Username for the Cloud SQL database user."
  type        = string
  default     = "n8n-user"
}

variable "db_tier" {
  description = "Cloud SQL instance tier."
  type        = string
  default     = "db-f1-micro"
}

variable "db_storage_size" {
  description = "Cloud SQL instance storage size in GB."
  type        = number
  default     = 10
}

variable "artifact_repo_name" {
  description = "Name for the Artifact Registry repository (only used if use_custom_image is true)."
  type        = string
  default     = "n8n-repo"
}

variable "cloud_run_service_name" {
  description = "Name for the Cloud Run service."
  type        = string
  default     = "n8n"
}

variable "service_account_name" {
  description = "Name for the IAM service account."
  type        = string
  default     = "n8n-service-account"
}

variable "cloud_run_cpu" {
  description = "CPU allocation for Cloud Run service."
  type        = string
  default     = "1"
}

variable "cloud_run_memory" {
  description = "Memory allocation for Cloud Run service."
  type        = string
  default     = "2Gi"
}

variable "cloud_run_max_instances" {
  description = "Maximum number of instances for Cloud Run service."
  type        = number
  default     = 1
}

variable "cloud_run_container_port" {
  description = "Internal port the n8n container listens on."
  type        = number
  default     = 5678
}

variable "generic_timezone" {
  description = "Timezone for n8n."
  type        = string
  default     = "UTC"
}

variable "google_client_id" {
  description = "Google OAuth Client ID for pre-filled credentials"
  type        = string
  sensitive   = true
}

variable "google_client_secret" {
  description = "Google OAuth Client Secret for pre-filled credentials"
  type        = string
  sensitive   = true
}

variable "n8n_host" {
  description = "Public URL of the n8n instance (e.g., n8n-xxxxx-uc.a.run.app). If empty, it will need to be configured after the first deployment."
  type        = string
  default     = ""
}

variable "webhook_url" {
  description = "Full URL for webhooks (e.g., https://n8n-xxxxx-uc.a.run.app). If empty, it will need to be configured after the first deployment."
  type        = string
  default     = ""
}
