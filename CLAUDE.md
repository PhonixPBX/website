# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Single-page product landing site for PhonixPBX, built with Hugo + Tailwind CSS v4 + daisyUI v5. There are no tests and no linter; a successful `hugo` build is the only check (CI's required `build` status).

## Commands

```sh
npm ci           # installs Hugo itself (hugo-extended npm package), Tailwind CLI and daisyUI
npm run dev      # hugo server on http://localhost:1313/
npm run build    # hugo --minify into public/
```

Hugo comes from `node_modules` (use `npx hugo ...`), not a system install; its version is pinned in `package.json` and bumped by Dependabot. CI builds with `npx hugo --minify --gc` and `HUGO_ENVIRONMENT=production`.

Set `HUGO_GITHUB_TOKEN` locally to avoid GitHub API rate limits. Remote release data is cached for 10 minutes (`[caches.getresource]` in `hugo.toml`).

## Architecture

- **One page.** `content/_index.md` only sets the title. `layouts/home.html` composes the page from section partials in `layouts/_partials/`; `layouts/baseof.html` is the shell. Section copy lives in the partials; repeated items (features, platforms, screenshots) live in `data/*.yaml`; links, repo, Docker image and contact email are `[params]` in `hugo.toml`.
- **Tailwind via Hugo's `css.TailwindCSS`.** `assets/css/main.css` is the Tailwind entry point and defines the daisyUI themes `phonix` (light) and `phonix-dark` (colours taken from the PhonixPBX web UI). Tailwind scans `hugo_stats.json` (Hugo `buildStats`), not the templates, so `layouts/_partials/css.html` wraps the CSS in `templates.Defer` to run after all pages render. Classes must appear literally in rendered HTML to be generated — avoid building class names dynamically.
- **Icons.** `partial "icon.html" (dict "name" "<file>" "class" "size-6")` inlines `assets/icons/<name>.svg` (Tabler icons). An unknown name is a build error, so add the SVG to `assets/icons/` first.
- **Downloads are generated at build time** from the GitHub releases API. `releases.html` is a returning partial (called with `partialCached`) that yields `stable` (newest non-draft, non-prerelease) and `nightly` (tag `nightly`); a failed fetch only warns and the page falls back to a link to GitHub releases. `release-assets.html` matches assets per board from `data/platforms.yaml` by the naming scheme `phonix-<version>-<board>.<ext>`: `.img.zst` or `.tar.xz` = image, `.meta.tar.xz` = LXC metadata, `.update` = update bundle, plus `SHA256SUMS`. Docker tag is `latest` for stable and `edge` for nightly. Changing asset naming upstream requires updating this partial.
- **Theme toggle.** An inline script in `baseof.html` applies a stored `localStorage.theme` before paint; otherwise daisyUI follows `prefers-color-scheme`. Toggle and copy-to-clipboard logic are in `layouts/_partials/scripts.html`.
- **Screenshots.** Entries in `data/screenshots.yaml` with an empty `src` render as placeholders; real images go in `static/screenshots/` (PNG/WebP, 16:10, ≥1600 px wide). The first entry is also shown in the hero.

## Deployment

`.github/workflows/pages.yml` builds on every push/PR and deploys to GitHub Pages (custom domain `phonixpbx.org`) for non-PR events: push to `main`, daily cron (fallback), manual dispatch, and `repository_dispatch` type `release` (sent by the `website` job in the PhonixPBX `image.yml` after every tagged release and every nightly, i.e. every push to its `main`; needs the `WEBSITE_DISPATCH_TOKEN` secret in that repo). The workflow overrides `baseURL` with the Pages URL. Dependabot patch updates are auto-merged once `build` passes.
