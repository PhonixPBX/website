# Developer notes

## Rebuilding the site after a PhonixPBX build

The download section only changes when the site is rebuilt. The `website` job in
[`PhonixPBX/PhonixPBX` `.github/workflows/image.yml`](https://github.com/PhonixPBX/PhonixPBX/blob/main/.github/workflows/image.yml)
runs after every tagged release and every nightly build (every push to `main`). It sends a
`repository_dispatch` event of type `release` to this repository, which runs `.github/workflows/pages.yml`.
The daily scheduled build in `pages.yml` is only a fallback.

The job needs the `WEBSITE_DISPATCH_TOKEN` secret in `PhonixPBX/PhonixPBX`. The built-in `github.token`
cannot trigger workflows in another repository. Without the secret, the job only logs a warning.

### Creating the token

The token is created under your personal account settings, not under the repository or organization settings.

1. Open <https://github.com/settings/personal-access-tokens/new>. Or click your avatar → **Settings** →
   **Developer settings** → **Personal access tokens** → **Fine-grained tokens** → **Generate new token**.
2. **Token name:** e.g. `website-dispatch`. **Expiration:** up to one year. Note the expiry date:
   when the token expires, the dispatch stops and the site falls back to the daily build.
3. **Resource owner:** change it from your user to **PhonixPBX**, otherwise the organization's repositories are not listed.
4. **Repository access:** **Only select repositories** → **PhonixPBX/website**.
5. **Permissions:** **+ Add permissions** (or expand **Repository permissions**) → **Contents** → **Read and write**.
   **Metadata: Read** is added automatically.
6. **Generate token** and copy it. It is shown only once.

If **PhonixPBX** is not offered as resource owner, fine-grained tokens are disabled for the organization.
Enable them under <https://github.com/organizations/PhonixPBX/settings/personal-access-tokens>. That page
also controls whether new tokens need approval. If they do, approve the token under **Pending requests**.

### Storing the secret

Under <https://github.com/PhonixPBX/PhonixPBX/settings/secrets/actions> → **New repository secret**, add
`WEBSITE_DISPATCH_TOKEN`. Or with the CLI, which prompts for the value:

```sh
gh secret set WEBSITE_DISPATCH_TOKEN -R PhonixPBX/PhonixPBX
```

### Testing

```sh
GH_TOKEN=<token> gh api repos/PhonixPBX/website/dispatches -f event_type=release
gh run list -R PhonixPBX/website -w Pages -L 1    # should show a new repository_dispatch run
```

### Renewing

Before the token expires, create a new one the same way and overwrite the secret with `gh secret set`.
