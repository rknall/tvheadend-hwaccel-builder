# CI/CD Configuration

This project includes automated build configurations for both GitHub Actions and GitLab CI/CD.

## GitHub Actions

### Workflow: Build TVHeadend Packages

**File:** `.github/workflows/build.yml`

**Triggers:**
- Push to `main` branch
- Pull requests to `main` branch
- Git tags starting with `v*` (e.g., `v1.0.0`)
- Manual workflow dispatch (via GitHub UI)

**What it does:**
1. Checks out the code
2. Sets up Docker Buildx
3. Frees up disk space (Docker builds need ~6GB)
4. Runs `build-tvheadend.sh`
5. Lists all built packages with details
6. Uploads packages as artifacts (30-day retention)
7. Creates GitHub releases for version tags

**Viewing Build Results:**
1. Go to: **Actions** tab in GitHub
2. Click on the workflow run
3. Download artifacts from the run summary

**Creating a Release:**
```bash
git tag v1.0.0
git push origin v1.0.0
```

This will:
- Trigger the build workflow
- Create a GitHub release with all 5 .deb packages attached
- Generate automatic release notes

**Manual Trigger:**
1. Go to: **Actions** tab
2. Select "Build TVHeadend Packages"
3. Click "Run workflow"
4. Choose branch and run

## GitLab CI/CD

### Pipeline: Build and Release

**File:** `.gitlab-ci.yml`

**Stages:**
1. **build** - Compiles packages
2. **release** - Creates GitLab releases (tags only)

**Triggers:**
- Push to `main` branch
- Merge requests
- Git tags

**What it does:**

**Build Stage:**
- Uses Docker-in-Docker (dind) service
- Runs `build-tvheadend.sh`
- Saves packages as artifacts (30-day retention)
- Shows disk usage and package listing

**Release Stage (tags only):**
- Creates GitLab release
- Attaches all 5 packages as downloadable links
- Auto-generates release description

**Requirements:**
- GitLab Runner with Docker executor
- Runner must have `docker` tag
- Sufficient disk space (~6GB) on runner

**Viewing Build Results:**
1. Go to: **CI/CD → Pipelines**
2. Click on pipeline number
3. View job logs
4. Download artifacts from job page

**Creating a Release:**
```bash
git tag v1.0.0
git push origin v1.0.0
```

**Manual Trigger:**
1. Go to: **CI/CD → Pipelines**
2. Click "Run pipeline"
3. Choose branch
4. Click "Run pipeline"

## Build Artifacts

Both CI/CD systems produce the same artifacts:

```
tvheadend_<version>_<arch>.deb         (~10MB)
tvheadend-comskip_<version>_<arch>.deb (~2MB)
tvheadend-picons_<version>_all.deb     (~450MB)
tvheadend-webgrab_<version>_all.deb    (~5MB)
tvheadend-full_<version>_all.deb       (~1KB)
```

**Total artifact size:** ~467MB

## Disk Space Management

CI/CD runners need significant disk space:

**GitHub Actions:**
- Workflow includes cleanup step to free space
- Removes .NET, GHC, and Boost installations
- Prunes Docker cache before build

**GitLab CI/CD:**
- Ensure runner has at least 10GB free space
- Consider using cleanup jobs between builds
- Monitor runner disk usage regularly

## Build Time

**Expected build times:**
- **First build:** 25-35 minutes
- **Cached builds:** 15-20 minutes (if Docker layers are cached)

**GitHub Actions:**
- Uses GitHub's hosted runners (free for public repos)
- 6 hours timeout per job

**GitLab CI/CD:**
- Depends on your runner configuration
- Recommend timeout: 1 hour

## Troubleshooting

### GitHub Actions: Out of Disk Space

If builds fail with disk space errors:

```yaml
# Already included in .github/workflows/build.yml
- name: Free up disk space
  run: |
    sudo rm -rf /usr/share/dotnet
    sudo rm -rf /opt/ghc
    sudo docker system prune -af
```

### GitLab CI/CD: Runner Out of Disk Space

Clean up runner manually:
```bash
# On GitLab runner host
docker system prune -af --volumes
```

Or add a cleanup job to `.gitlab-ci.yml`:
```yaml
cleanup:
  stage: .pre
  script:
    - docker system prune -af
  when: always
```

### Build Timeouts

Increase timeout in GitHub Actions:
```yaml
jobs:
  build:
    timeout-minutes: 60  # Default is 360
```

Increase timeout in GitLab CI/CD:
```yaml
build-packages:
  timeout: 1h
```

### Docker Layer Caching

**GitHub Actions:**
```yaml
- name: Build packages with cache
  uses: docker/build-push-action@v5
  with:
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

**GitLab CI/CD:**
- Use GitLab's Docker registry as cache
- Or enable runner Docker layer caching

## Version Tagging Strategy

Recommended semantic versioning:

```bash
# Major release (breaking changes)
git tag v2.0.0

# Minor release (new features)
git tag v1.1.0

# Patch release (bug fixes)
git tag v1.0.1

# Pre-release
git tag v1.0.0-beta.1
```

Always push tags to trigger release:
```bash
git push origin v1.0.0
```

## Artifact Retention

**GitHub Actions:**
- Artifacts: 30 days (configurable)
- Releases: Permanent

**GitLab CI/CD:**
- Artifacts: 30 days (configurable)
- Releases: Permanent

To change retention in GitHub Actions:
```yaml
- uses: actions/upload-artifact@v4
  with:
    retention-days: 90  # Change to desired days
```

To change retention in GitLab CI/CD:
```yaml
artifacts:
  expire_in: 90 days  # Change to desired duration
```

## Security Considerations

**GitHub Actions:**
- Uses `GITHUB_TOKEN` automatically (scoped to repo)
- No additional secrets needed
- Workflows from forks require approval

**GitLab CI/CD:**
- Uses GitLab CI/CD permissions
- No additional secrets needed
- Merge request pipelines run in fork context

## Multi-Architecture Builds (Future)

To build for both amd64 and arm64:

**GitHub Actions:**
```yaml
strategy:
  matrix:
    platform:
      - linux/amd64
      - linux/arm64
```

**GitLab CI/CD:**
```yaml
build-packages:
  parallel:
    matrix:
      - ARCH: amd64
      - ARCH: arm64
```

## Notifications

**GitHub Actions:**
- Enable in: **Settings → Notifications**
- Email notifications for failed workflows

**GitLab CI/CD:**
- Enable in: **Settings → Integrations**
- Configure Slack, Discord, or email notifications

## Cost Considerations

**GitHub Actions:**
- Free for public repositories
- 2,000 minutes/month for private repos (free tier)
- Each build: ~30 minutes = ~467MB artifacts

**GitLab CI/CD:**
- Free tier: 400 CI/CD minutes/month
- Self-hosted runners: Free (your infrastructure)

## Next Steps

1. **Test the workflow:**
   ```bash
   git add .github/workflows/build.yml .gitlab-ci.yml
   git commit -m "Add CI/CD configurations"
   git push origin main
   ```

2. **Watch first build:**
   - GitHub: Check Actions tab
   - GitLab: Check CI/CD → Pipelines

3. **Create first release:**
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

4. **Download and test packages from artifacts**
