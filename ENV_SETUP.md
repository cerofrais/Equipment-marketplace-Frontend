# Environment Variables Setup

## Local Development

1. Create a `.env` file in the project root:
```bash
cp .env.example .env
```

2. Update the values in `.env`:
```
BASE_URL=http://your-backend-url.com:8000
```

## GitHub Actions Setup

To enable the app to build in GitHub Actions, you need to add the environment variables as GitHub Secrets:

### Step 1: Add Secrets to GitHub Repository

1. Go to your GitHub repository: `https://github.com/cerofrais/Equipment-marketplace-Frontend`
2. Click on **Settings** (repository settings, not your profile)
3. In the left sidebar, click **Secrets and variables** → **Actions**
4. Click **New repository secret**
5. Add the following secret:

   **Name:** `BASE_URL`  
   **Value:** `http://backend-eqp-rent.centralindia.cloudapp.azure.com:8000`

6. Click **Add secret**

### Step 2: How It Works

The GitHub Actions workflow (`.github/workflows/release-android.yml`) automatically:
1. Creates a `.env` file during the build process
2. Populates it with values from GitHub Secrets
3. The Flutter app reads these values using `flutter_dotenv`

### Adding More Environment Variables

If you need to add more environment variables in the future:

1. **Add to `.env.example`** (for documentation)
2. **Add to GitHub Secrets** (Settings → Secrets and variables → Actions)
3. **Update the workflow** to include the new variable:

```yaml
- name: Create .env file
  run: |
    echo "BASE_URL=${{ secrets.BASE_URL }}" > .env
    echo "NEW_VARIABLE=${{ secrets.NEW_VARIABLE }}" >> .env
```

Note: Use `>` for the first variable and `>>` for additional variables to append to the file.

## Security Notes

- ⚠️ Never commit the `.env` file to version control
- ✅ Always use `.env.example` for documentation (with dummy values)
- ✅ Keep sensitive values in GitHub Secrets
- ✅ Secrets are encrypted and only exposed to GitHub Actions during builds
