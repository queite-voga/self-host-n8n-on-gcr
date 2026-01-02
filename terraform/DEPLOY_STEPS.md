# Deploy and configuration steps

## 1️⃣ First Deploy (Without URLs configured)

1. Configure the environment variables, follow the example in `terraform.tfvars.example`.
2. On terminal:
    ```bash
    cd terraform
    terraform plan (optional)
    terraform apply
    ```

After the deploy, Terraform will show the necessary URLs in the **outputs**.

## 2️⃣ Copy the URLs from the Outputs

After `terraform apply`, you'll see something like:

```
Outputs:

cloud_run_service_url = "https://n8n-xxxxx-uc.a.run.app"
n8n_host_value = "n8n-xxxxx-uc.a.run.app"
webhook_url_value = "https://n8n-xxxxx-uc.a.run.app"

configuration_instructions = <<EOT

⚠️  IMPORTANT: Configure the following variables in terraform.tfvars:

n8n_host = "n8n-xxxxx-uc.a.run.app"
webhook_url = "https://n8n-xxxxx-uc.a.run.app"

Then run 'terraform apply' again to apply the correct URLs.
EOT
```

## 3️⃣ Update `terraform.tfvars`

Edit the file `terraform/terraform.tfvars` and add the URLs:

```hcl
# ... other settings ...

# n8n URLs (copy from outputs)
n8n_host = "n8n-xxxxx-uc.a.run.app"  # WITHOUT https://
webhook_url = "https://n8n-xxxxx-uc.a.run.app"  # WITH https://
```

## 4️⃣ Configure Google Cloud Console

1. Go to the Google Cloud Console: https://console.cloud.google.com/
2. Navigate to **APIs & Services** > **Credentials**
3. Edit your OAuth 2.0 credentials
4. Add the URLs:

**Authorized JavaScript origins:**
```
https://n8n-xxxxx-uc.a.run.app
```

**Authorized redirect URIs:**
```
https://n8n-xxxxx-uc.a.run.app/rest/oauth2-credential/callback
```

## 5️⃣ Second Deploy (With URLs configured)

```bash
cd terraform
terraform apply
```

This will update Cloud Run with the correct `N8N_HOST` and `WEBHOOK_URL` variables.

## ✅ Verification

1. Visit your instance: `https://n8n-xxxxx-uc.a.run.app`
2. Create a user account
3. Go to **Credentials** > **+ Add credential**
4. Choose "Google Sheets OAuth2 API"
5. You should see the **"Sign in with Google"** button
6. Click and authorize with your Google Workspace account

## 🔍 Troubleshooting

### Error "redirect_uri_mismatch"
- Verify the URLs in the Google Cloud Console exactly match the Terraform outputs
- Ensure there are no extra spaces or trailing slashes

### Client ID/Secret fields still show
- Make sure you ran the second `terraform apply` after configuring the URLs
- Check logs: `gcloud run services logs read n8n --region=us-west2`

### OAuth redirects to localhost
- Verify `n8n_host` and `webhook_url` are set in `terraform.tfvars`
- Run `terraform apply` again
