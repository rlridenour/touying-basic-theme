---
name: install-local-theme-package
description: Symlink basic-theme/ into Typst's local package directory so it can be imported as @local/basic-theme:0.1.0 from test presentations, with edits taking effect immediately.
---

The theme is developed by editing `basic-theme/` directly and importing it as `@local/basic-theme:0.1.0` from test presentations. This only works if the versioned package directory is symlinked into Typst's local package directory:

```sh
mkdir -p "$HOME/Library/Application Support/typst/packages/local/basic-theme"
ln -s "/path/to/touying-basic-theme/basic-theme" \
  "$HOME/Library/Application Support/typst/packages/local/basic-theme/0.1.0"
```

(Linux: `~/.local/share/typst/packages/local/...`; Windows: `%APPDATA%\typst\packages\local\...`.) Because it's a symlink, edits to `lib.typ` take effect immediately — there is no separate copy/install step to remember.
