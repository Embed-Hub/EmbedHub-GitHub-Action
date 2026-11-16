# EmbedHub Upload GitHub Action

Automatically upload your build artifacts (binaries, hex files, map files, etc.) to [EmbedHub](https://embedhub.com) projects directly from your GitHub Actions workflows.

## Features

- Upload firmware binaries, hex files, map files, and other build artifacts
- Support for glob patterns to upload multiple files

## Quick Start

### 1. Make a project token

1. On [embedhub.com](https://embedhub.com), open your project's **Settings → Tokens**.
2. Click **New**, give it a name (e.g. "github ci"), and pick the folders the
   workflow needs, for example `releases/` with write.
3. Copy the token. It is shown once.

A token works on that one project and can only do what you can do there.

### 2. Add it as a GitHub secret

- Go to **Settings → Secrets and variables → Actions**
- Click **New repository secret**
- Name: `EMBEDHUB_TOKEN`, value: the token

### 3. Use in Your Workflow

Add this action to your GitHub workflow after your build step:

```yaml
- name: Upload to EmbedHub
  uses: Embed-Hub/EmbedHub-GitHub-Action@master
  with:
    token: ${{ secrets.EMBEDHUB_TOKEN }}
    organization: mycompany
    project: my-firmware
    files: 'build/*.bin'
```

## Usage Examples

### Upload Firmware Binary

```yaml
- name: Upload firmware binary
  uses: Embed-Hub/EmbedHub-GitHub-Action@master
  with:
    token: ${{ secrets.EMBEDHUB_TOKEN }}
    organization: mycompany
    project: iot-device
    files: 'firmware.bin'
```

### Upload Multiple Files with Glob Pattern

```yaml
- name: Upload all build artifacts
  uses: Embed-Hub/EmbedHub-GitHub-Action@master
  with:
    token: ${{ secrets.EMBEDHUB_TOKEN }}
    organization: mycompany
    project: embedded-app
    files: 'build/*.{bin,hex,map,elf}'
```

### Upload to Specific Path

```yaml
- name: Upload release files
  uses: Embed-Hub/EmbedHub-GitHub-Action@master
  with:
    token: ${{ secrets.EMBEDHUB_TOKEN }}
    organization: mycompany
    project: sensor-firmware
    files: 'dist/*.bin'
    path: 'releases/${{ github.ref_name }}/'
```

### Upload from Subdirectory

```yaml
- name: Upload from build directory
  uses: Embed-Hub/EmbedHub-GitHub-Action@master
  with:
    token: ${{ secrets.EMBEDHUB_TOKEN }}
    organization: mycompany
    project: motor-controller
    files: '*.hex'
    working-directory: './build/output'
```

## Inputs

| Input | Required | Description | Default |
|-------|----------|-------------|---------|
| `token` | **Yes** | EmbedHub project token (use `${{ secrets.EMBEDHUB_TOKEN }}`) | - |
| `organization` | **Yes** | Organization slug (e.g., `mycompany` or username) | - |
| `project` | **Yes** | Project slug (e.g., `my-firmware`) | - |
| `files` | **Yes** | Files to upload (supports glob: `*.bin`, `build/*.{hex,map}`) | - |
| `path` | No | Target path in project (e.g., `releases/v1.0.0/`) | Auto-detected |
| `working-directory` | No | Working directory to run from | `.` |

## Default File Paths

When `path` is not specified, files are uploaded to these default locations based on file type:

| File Type | Extensions | Default Path |
|-----------|-----------|--------------|
| Release files | `.bin`, `.elf`, `.map` | `releases/` |
| Documents | `.pdf` | `documents/` |
| Images & videos | `.jpg`, `.jpeg`, `.png`, `.svg`, `.webp`, `.gif`, `.mp4`, `.mov`, `.webm` | `photos/` |
| Captures | `.sr`, `.vcd`, `.log` | `captures/` |
| Other files (including `.hex`) | All others | Root directory |

## Development

The action is a small Debian image with the EmbedHub CLI (pinned by
`EMBEDHUB_CLI_VERSION` in the `Dockerfile`; bump it on each CLI release) and
`entrypoint.sh`.

```bash
test/entrypoint_test.sh   # entrypoint against a stub CLI: inputs, token handling, outputs
test/image_test.sh        # builds the image (podman or docker), checks the pinned CLI
```

## License

MIT License

## Support

- [EmbedHub Documentation](https://docs.embedhub.com/integrations/gh-action)