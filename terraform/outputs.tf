output "cloud_run_service_url" {
  description = "URL of the deployed n8n Cloud Run service."
  value       = google_cloud_run_v2_service.n8n.uri
}

output "n8n_host_value" {
  description = "Value to use for n8n_host variable (without https://)"
  value       = replace(google_cloud_run_v2_service.n8n.uri, "https://", "")
}

output "webhook_url_value" {
  description = "Value to use for webhook_url variable (with https://)"
  value       = google_cloud_run_v2_service.n8n.uri
}

output "configuration_instructions" {
  description = "Instructions for completing the OAuth configuration after deployment."
  value = <<-EOT
    
    ⚠️ IMPORTANT: Configure the following variables in terraform.tfvars:
    
    n8n_host = "${replace(google_cloud_run_v2_service.n8n.uri, "https://", "")}"
    webhook_url = "${google_cloud_run_v2_service.n8n.uri}"
    
    Then run 'terraform apply' again to apply the correct URLs.
    
    Also add these URLs in the Google Cloud Console:
    - Authorized JavaScript origins: ${google_cloud_run_v2_service.n8n.uri}
    - Authorized redirect URIs: ${google_cloud_run_v2_service.n8n.uri}/rest/oauth2-credential/callback
  EOT
} 
