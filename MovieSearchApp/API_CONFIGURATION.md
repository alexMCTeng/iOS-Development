# TMDb credentials

## Local development

The app reads `TMDBAPIKey` from its built Info.plist. Xcode expands that value from the `TMDB_API_KEY` build setting. Both Debug and Release use `Configuration/App.xcconfig`, which optionally includes `Configuration/Secrets.xcconfig`.

1. Copy `Configuration/Secrets.example.xcconfig` to `Configuration/Secrets.xcconfig` if the local file does not already exist.
2. Put your TMDb **v3 API key** after `TMDB_API_KEY =` in the local file. Do not put it in Swift, the project file, or the example configuration.
3. Build again. Configuration is embedded at build time, so changing the file requires rebuilding the app.

`Secrets.xcconfig` is ignored by this project's `.gitignore`. Never force-add it. Check with:

```sh
git check-ignore -v Configuration/Secrets.xcconfig
```

Without a key, the project still builds. Movie discovery/search are disabled with a configuration message; local favorites remain available. Tests can exercise that path with the `TMDB_API_KEY=` build-setting override.

CI should obtain the key from its secret store and create the ignored configuration file during the job. Avoid printing it, enabling shell tracing, or uploading build logs/artifacts containing the key. A checked-in `.env` file or GitHub Actions secret does not automatically configure a native Xcode app.

## Existing key and Git history

The previous key was already committed locally before this change. It has been moved to the ignored local configuration to preserve local behavior, but **it has not been rotated or revoked**.

Replacing the current source does not erase older commits. Before making that history public, invalidate/rotate the old credential with TMDb and update the local configuration with the replacement. If it was already publicly pushed, treat it as exposed. Start at your [TMDb API settings](https://www.themoviedb.org/settings/api); use TMDb support if your account does not offer a reset/revoke option.

If you also want to remove the old value from history, follow [GitHub's sensitive-data removal guide](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository). Coordinate any history rewrite with collaborators. This change does not rewrite history or push anything. The Git repository currently spans the parent `iOSDevelopment` directory, not just this app.

## Repository privacy versus app security

This setup keeps the key out of future source commits. It does **not** make a shared credential secret inside an iOS app: someone with the built app can read its Info.plist. Obfuscation and Keychain storage cannot make a credential shipped to every user unextractable.

For a credential that must stay secret, use an authenticated, rate-limited backend:

```text
iOS app → your backend → TMDb
                         ↑
                  key held on server
```

Keep the TMDb key in the backend's secret store. The backend makes the TMDb requests and returns only the needed movie data; it must not return the key or act as an unrestricted public proxy.
