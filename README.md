# PhonixPBX website

Product landing page for [PhonixPBX](https://github.com/PhonixPBX/PhonixPBX), built with
[Hugo](https://gohugo.io), [Tailwind CSS](https://tailwindcss.com) and [daisyUI](https://daisyui.com)
in the colours of the PhonixPBX web interface.

## Development

```sh
npm ci           # installs Hugo (hugo-extended), Tailwind CSS and daisyUI
npm run dev      # http://localhost:1313/website/
npm run build    # production build into public/
```

Set `HUGO_GITHUB_TOKEN` to avoid GitHub API rate limits when fetching release data.

## Content

| What | Where |
|---|---|
| Feature cards | `data/features.yaml` |
| Platforms and download mapping (board → asset) | `data/platforms.yaml` |
| Screenshots (placeholders until `src` is set) | `data/screenshots.yaml`, images in `static/screenshots/` |
| Links, Docker image | `[params]` in `hugo.toml` |
| Theme colours (`phonix`, `phonix-dark`) | `assets/css/main.css` |
| Logos (from `phonix/web/static/img/` upstream) | `static/img/` |

### Downloads

The download section is generated at build time from the GitHub releases API
(`layouts/_partials/releases.html`):

- **Stable**: the newest non-prerelease release. Until the first one exists, the tab shows a notice.
- **Nightly**: the release tagged `nightly`, with Docker tag `edge`.

Assets are matched by the naming scheme `phonix-<version>-<board>.<ext>`. If the API cannot be reached,
the build still succeeds and links to the GitHub releases page.

## Deployment

`.github/workflows/pages.yml` builds and deploys to GitHub Pages:

- on push to `main`
- daily (to pick up new nightlies)
- on manual dispatch
- on a `repository_dispatch` event of type `release`

The PhonixPBX release workflow can trigger a rebuild with:

```sh
gh api repos/PhonixPBX/website/dispatches -f event_type=release
```

(this needs a token with access to this repository).

Pull requests are built but not deployed.

### Dependencies

Dependabot updates npm packages (including Hugo itself via `hugo-extended`) and GitHub Actions weekly.
Patch updates are merged automatically by `.github/workflows/dependabot-automerge.yml` once checks pass.

One-time repository settings:

1. **Settings → Pages → Source:** GitHub Actions
2. **Settings → General:** enable *Allow auto-merge*
3. **Branch protection / ruleset for `main`:** require the `build` status check, so auto-merge waits for a green build.
