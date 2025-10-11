# EmbedHub Upload GitHub Action

Automatically upload your build artifacts (binaries, hex files, map files, etc.) to [EmbedHub](https://embedhub.com) projects directly from your GitHub Actions workflows.

## Features

- Upload firmware binaries, hex files, map files, and other build artifacts
- Support for glob patterns to upload multiple files

## Quick Start

### 1. Create an EmbedHub API Key

1. Log in to your EmbedHub account
2. Go to your settings
3. Navigate to the "API Keys" tab
4. Create a new API key and copy it

### 2. Add GitHub Secrets

Add these secrets to your GitHub repository:
- Go to **Settings → Secrets and variables → Actions**
- Click **New repository secret**

Required secrets:
- `EMBEDHUB_API_KEY` - Your EmbedHub API key
- `EMBEDHUB_ORG` - Your organization slug (e.g., `mycompany` or your username)
- `EMBEDHUB_PROJECT` - Your project slug (e.g., `my-firmware`)

### 3. Use in Your Workflow

Add this action to your GitHub workflow after your build step:

```yaml
- name: Upload to EmbedHub
  uses: embedhub/embedhub-action@v1
  with:
    api-key: ${{ secrets.EMBEDHUB_API_KEY }}
    organization: ${{ secrets.EMBEDHUB_ORG }}
    project: ${{ secrets.EMBEDHUB_PROJECT }}
    files: 'build/*.bin'
```

## Usage Examples

### Upload Firmware Binary

```yaml
- name: Upload firmware binary
  uses: embedhub/embedhub-action@v1
  with:
    api-key: ${{ secrets.EMBEDHUB_API_KEY }}
    organization: mycompany
    project: iot-device
    files: 'firmware.bin'
```

### Upload Multiple Files with Glob Pattern

```yaml
- name: Upload all build artifacts
  uses: embedhub/embedhub-action@v1
  with:
    api-key: ${{ secrets.EMBEDHUB_API_KEY }}
    organization: mycompany
    project: embedded-app
    files: 'build/*.{bin,hex,map,elf}'
```

### Upload to Specific Path

```yaml
- name: Upload release files
  uses: embedhub/embedhub-action@v1
  with:
    api-key: ${{ secrets.EMBEDHUB_API_KEY }}
    organization: mycompany
    project: sensor-firmware
    files: 'dist/*.bin'
    path: 'releases/${{ github.ref_name }}/'
```

### Upload from Subdirectory

```yaml
- name: Upload from build directory
  uses: embedhub/embedhub-action@v1
  with:
    api-key: ${{ secrets.EMBEDHUB_API_KEY }}
    organization: mycompany
    project: motor-controller
    files: '*.hex'
    working-directory: './build/output'
```

## Inputs

| Input | Required | Description | Default |
|-------|----------|-------------|---------|
| `api-key` | **Yes** | EmbedHub API key (use `${{ secrets.EMBEDHUB_API_KEY }}`) | - |
| `organization` | **Yes** | Organization slug (e.g., `mycompany` or username) | - |
| `project` | **Yes** | Project slug (e.g., `my-firmware`) | - |
| `files` | **Yes** | Files to upload (supports glob: `*.bin`, `build/*.{hex,map}`) | - |
| `path` | No | Target path in project (e.g., `releases/v1.0.0/`) | Auto-detected |
| `working-directory` | No | Working directory to run from | `.` |

## Default File Paths

When `path` is not specified, files are uploaded to these default locations based on file type:

| File Type | Extensions | Default Path |
|-----------|-----------|--------------|
| Release Files | `.bin`, `.hex`, `.elf`, `.map` | `releases/` |
| Documents | `.pdf`, `.jpg`, `.png`, `.svg` | `documents/` |
| Other Files | All others | Root directory |

## License

MIT License

## Support

- [EmbedHub Documentation](https://docs.embedhub.com/integrations/gh-action)