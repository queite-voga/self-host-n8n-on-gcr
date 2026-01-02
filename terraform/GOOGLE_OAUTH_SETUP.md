# Google OAuth Configuration for n8n

This document explains how to configure n8n to allow users to sign in with Google (Google Workspace) without needing to manually set up the Client ID and Client Secret.

## How it works

With the configuration implemented in this project, Google OAuth credentials are pre-configured at the instance level. This means:

1. ✅ Users see only the "Sign in with Google" button
2. ✅ There's no need to manually create or fill Client ID and Client Secret
3. ✅ Each user still authorizes access to their own Google account
4. ✅ Credentials are stored per user
5. ✅ One user cannot access another user's data

## Supported Google Services

The Terraform configuration in `terraform/main.tf` injects a single pre-filled OAuth credential under the key `googleOAuth2Api`. This generic credential can be reused across multiple n8n integrations (for example: Google Sheets, Drive, Calendar and Gmail) as long as the OAuth client registered in Google Cloud includes the required scopes for those APIs.

If an integration expects a different credential key (for example `googleSheetsOAuth2Api`) or you want to use a distinct OAuth client per service, add additional entries to the `CREDENTIALS_OVERWRITE_DATA` object in `terraform/main.tf` (see "Adding more Google services" below).

## Configure in Google Cloud Console

### 1. Create an OAuth project in Google Cloud

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Go to **APIs & Services** > **Credentials**

### 2. Configure the OAuth Consent Screen

1. Open **OAuth consent screen**
2. **IMPORTANT**: Choose **Internal** as the User Type
   - This restricts sign-in to users in your Google Workspace
   - If you choose "External", any Google account could attempt sign-in
3. Fill in the required information:
   - **App name**: n8n Workflows
   - **User support email**: support email
   - **Developer contact**: support email
4. In **Scopes**, add the required scopes, for example:
```
https://www.googleapis.com/auth/userinfo.email
https://www.googleapis.com/auth/userinfo.profile
https://www.googleapis.com/auth/gmail.send
https://www.googleapis.com/auth/gmail.modify
https://www.googleapis.com/auth/spreadsheets
https://www.googleapis.com/auth/calendar
https://www.googleapis.com/auth/drive
https://www.googleapis.com/auth/contacts
```

### 3. Create OAuth 2.0 Credentials

1. Go to **Credentials** > **Create Credentials** > **OAuth client ID**
2. Select **Web application**
3. Configure:
   - **Name**: n8n OAuth Client
   - **Authorized JavaScript origins**:
     - `https://n8n-XXXXXXXXXX-uc.a.run.app` (your Cloud Run URL)
   - **Authorized redirect URIs**:
     - `https://n8n-XXXXXXXXXX-uc.a.run.app/rest/oauth2-credential/callback`
4. Click **Create**
5. **Copy** the generated Client ID and Client Secret

### 4. Update `terraform.tfvars`

Update `terraform/terraform.tfvars` with the credentials:

```hcl
# Google OAuth2 - pre-fill credentials for all users
google_client_id = "YOUR-CLIENT-ID-HERE.apps.googleusercontent.com"
google_client_secret = "YOUR-CLIENT-SECRET-HERE"
```

### 5. Apply the configuration

```bash
cd terraform
terraform apply
```

## Environment variables set by Terraform

Terraform currently sets the `CREDENTIALS_OVERWRITE_DATA` environment variable in Cloud Run with a JSON object that contains the `googleOAuth2Api` credential. The values come from `var.google_client_id` and `var.google_client_secret` (set in `terraform/terraform.tfvars`). Example (actual content is JSON-encoded in the env var):

```json
{
  "googleOAuth2Api": {
    "clientId": "<value from var.google_client_id>",
    "clientSecret": "<value from var.google_client_secret>"
  }
}
```

You can verify the variables used in `terraform/terraform.tfvars` or the outputs after deployment (`cloud_run_service_url`).

## How users use it

1. The user visits the n8n instance
2. When creating a credential for Google Sheets, Gmail, etc., they will see:
   - ✅ A **"Sign in with Google"** button
   - ❌ NO fields to enter Client ID and Client Secret
3. Clicking the button redirects the user to Google to authorize
4. After authorization, the credential is saved and ready to use

## Security

- ✅ Each user authorizes access only to their own Google account
- ✅ OAuth credentials are stored encrypted in the database
- ✅ The Client Secret is kept securely in Terraform variables (consider using Secret Manager in production)
- ✅ With User Type set to "Internal", only your Workspace users can sign in

## Adding more Google services
To add support for more Google services, edit `terraform/main.tf` and add the desired credential keys into the `jsonencode({...})` object that is assigned to `CREDENTIALS_OVERWRITE_DATA`. Each key should map to an object with `clientId` and `clientSecret` (you can reuse the same var names or add new variables).

Example: in `terraform/main.tf` add entries like:

```hcl
value = jsonencode({
  googleOAuth2Api = {
    clientId     = var.google_client_id
    clientSecret = var.google_client_secret
  }
  googleSheetsOAuth2Api = {
    clientId     = var.google_sheets_client_id
    clientSecret = var.google_sheets_client_secret
  }
})
```

Also update `terraform/variables.tf` and `terraform.tfvars` to provide any new client ID/secret variables.

Refer to the [n8n documentation](https://docs.n8n.io/integrations/builtin/credentials/) for the credential key names.

## Verification

1. Visit your n8n instance
2. Go to **Settings** > **Credentials**
3. Click **+ Add credential**
4. Choose "Google Sheets OAuth2 API" (or another Google service)
5. You should see only the button to connect, without Client ID/Secret fields

## Troubleshooting

### Client ID/Secret fields still appear

- Verify that `CREDENTIALS_OVERWRITE_DATA` is configured correctly
- Check Cloud Run logs: `gcloud run services logs read n8n --region=us-west2`
- Ensure the credential name matches exactly what n8n expects

### Error "redirect_uri_mismatch"

- Verify the redirect URL in Google Cloud Console is correct
- It should follow the pattern: `https://YOUR-SERVICE.run.app/rest/oauth2-credential/callback`

### External users can sign in

- Make sure the OAuth consent screen User Type is set to **Internal**
- Only Workspace users should be able to sign in

## References

- [n8n - Credentials Overwrite](https://docs.n8n.io/hosting/configuration/environment-variables/credentials/)
- [Google OAuth 2.0](https://developers.google.com/identity/protocols/oauth2)
- [n8n - Google OAuth Setup](https://docs.n8n.io/integrations/builtin/credentials/google/)
