# PhonixPBX website

Product landing page for [PhonixPBX](https://github.com/PhonixPBX/PhonixPBX), built with
[Hugo](https://gohugo.io), [Tailwind CSS](https://tailwindcss.com) and [daisyUI](https://daisyui.com)
in the colours of the PhonixPBX web interface.

## Development

```sh
npm ci           # installs Hugo (hugo-extended), Tailwind CSS and daisyUI
npm run dev      # http://localhost:1313/
npm run build    # production build into public/
```

Set `HUGO_GITHUB_TOKEN` to avoid GitHub API rate limits when fetching release data.

If the system Node.js is too old, run the same commands in a Node.js LTS container with Podman
instead. A recent system Node.js needs no container.

```sh
./podman.sh npm ci
./podman.sh npm run dev -- --bind 0.0.0.0   # http://localhost:1313/
./podman.sh npm run build
```

## Content

| What | Where |
|---|---|
| Feature cards | `data/features.yaml` |
| Platforms and download mapping (board → asset) | `data/platforms.yaml` |
| Screenshots (placeholders until `src` is set) | `data/screenshots.yaml`, images in `static/screenshots/` |
| Links, contact email, Docker image | `[params]` in `hugo.toml` |
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
- daily (fallback)
- on manual dispatch
- on a `repository_dispatch` event of type `release`, sent by the PhonixPBX `image.yml` workflow
  after every release and nightly build

The dispatch needs the `WEBSITE_DISPATCH_TOKEN` secret in the PhonixPBX repository. See [DEV.md](DEV.md)
for how to create and renew it.

Pull requests are built but not deployed.

### Dependencies

Dependabot updates npm packages (including Hugo itself via `hugo-extended`) and GitHub Actions weekly.
Patch updates are merged automatically by `.github/workflows/dependabot-automerge.yml` once checks pass.

One-time repository settings:

1. **Settings → Pages:**
   - Set **Source** to GitHub Actions.
   - Set **Custom domain** to `phonixpbx.org`.
   - Enable **Enforce HTTPS**.

   No `CNAME` file is needed when deploying with Actions.
2. **Settings → General:** enable *Allow auto-merge*
3. **Branch protection / ruleset for `main`:** require the `build` status check, so auto-merge waits for a green build.

### Custom domain `phonixpbx.org`

DNS records at the registrar ([GitHub docs](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site)):

| Name | Type | Value |
|---|---|---|
| `@` | A | `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153` |
| `@` | AAAA | `2606:50c0:8000::153`, `2606:50c0:8001::153`, `2606:50c0:8002::153`, `2606:50c0:8003::153` |
| `www` | CNAME | `phonixpbx.github.io` |

Keep the existing MX records for the `info@phonixpbx.org` mailbox.

It is also recommended to verify the domain for the organization under
**Organization settings → Pages → Add a domain**, to prevent domain takeover.

The canonical URL in `hugo.toml` is `https://phonixpbx.org/`. In CI, the workflow takes the URL
reported by `actions/configure-pages`, so the two always match.
