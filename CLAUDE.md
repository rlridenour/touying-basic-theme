# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A [Touying](https://touying-typ.github.io/) theme for Typst presentations that replicates the author's `basicwhite` Beamer/LaTeX theme. The Typst theme package (`basic-theme/`) is the deliverable; everything else is reference material or scratch test content.

## Commands

There is no build system, linter, or test suite — this is a Typst package. Compile with the `typst` CLI (v0.15.0 during development).

Compile a presentation that imports the theme via relative path (not installed as a package): pass `--root` pointed at a common ancestor directory, since the theme lives outside whatever folder you compile from:

```sh
typst compile --root . touying-presentation/touying-presentation-slides-white.typ
```

If the theme is installed as a local package (see below), compile normally with no `--root` needed:

```sh
cd touying-presentation
typst compile touying-presentation-slides-white.typ
```

There's no automated verification — after any change to `basic-theme/lib.typ`, compile the `touying-presentation/` test deck (all three variants) and read the resulting PDF to visually confirm the change, rather than trusting a clean compile alone.

### Installing/updating the local package

The theme is developed by editing `basic-theme/` directly and importing it as `@local/basic-theme:0.1.0` from test presentations. This only works if the versioned package directory is symlinked into Typst's local package directory:

```sh
mkdir -p "$HOME/Library/Application Support/typst/packages/local/basic-theme"
ln -s "/path/to/touying-basic-theme/basic-theme" \
  "$HOME/Library/Application Support/typst/packages/local/basic-theme/0.1.0"
```

(Linux: `~/.local/share/typst/packages/local/...`; Windows: `%APPDATA%\typst\packages\local\...`.) Because it's a symlink, edits to `lib.typ` take effect immediately — there is no separate copy/install step to remember.

## Repo layout

- **`basic-theme/`** — the theme itself, laid out as a Typst package (`typst.toml` with `entrypoint = "lib.typ"`). Tracked in git; this is the only directory whose changes matter for the "product" of this repo.
  - `lib.typ` — all theme code (see Architecture below).
  - `logos/univ.png`, `logos/school.png` — bundled logos, exposed via `univ-logo()`/`school-logo()` helpers.
  - `README.md` — the theme's own usage docs (import syntax, heading convention, local-package install instructions). Keep in sync with `lib.typ` when changing its public API.
- **`basicwhite-beamer-theme/`** — the original Beamer `.sty` theme being replicated, plus a sample PDF and logo assets, kept purely as a visual/behavioral reference. **Gitignored** — do not expect changes here to be committable.
- **`touying-presentation/`** — a scratch Touying project used to manually test the theme against the Beamer reference. **Gitignored** — changes here are for local verification only and will never show up in `git status`. Contains `config.typ` (shared setup) + `content.typ` (shared slide content, written as a function so it can drive both slides and handout) + three slide entry points (`touying-presentation-slides-{white,black,gray}.typ`, one per theme variant) + one handout entry point. `content.typ` is generated from `talk.org` via `ox-touying.el` (see below) rather than hand-edited directly.
- **`touying-presentation-no-subsections/`** — the same scratch setup as `touying-presentation/`, but exercising the theme's default `slide-level: 2` (no subsections) instead of `slide-level: 3`. Also gitignored.
- **`rlr-touying-scaffold.el`** and **`ox-touying.el`** — Emacs tooling, tracked in git. `rlr-touying-scaffold.el` scaffolds a new presentation directory (`M-x rlr/new-touying-presentation`): `config.typ`, `talk.org`, the slides/handout entry points, and a `content.typ` generated from `talk.org`. `ox-touying.el` is the Org export backend that generates `content.typ` from an Org file (`M-x rlr/org-export-to-touying-content`) — heading depth maps 1:1 onto Typst heading depth, `#+begin_speakernote`/`#+begin_handoutnote` special blocks map to `#speaker-note[...]`/`#handout-note[...]`, `@@typst:...@@` export snippets (e.g. `@@typst:#pause@@`) pass through raw, `#+begin_columns`/`#+begin_fullslide` special blocks cover the two-column and full-bleed layouts, `#+begin_statement` renders big centered text (size via a preceding `#+ATTR_TOUYING: :size ...`, default `2em`), and an image link honors a preceding `#+ATTR_TOUYING: :width/:height/:fit/:align ...`. Since talk.org is the authoring source, `content.typ` should be re-exported rather than hand-edited once ox-touying.el is in use.

## Architecture

### Theme structure (`basic-theme/lib.typ`)

The theme is a single file built on top of `@preview/touying:0.7.4`. Key design points a future change needs to respect:

- **Heading levels map onto the Beamer document structure**, not Touying's own default (`slide-level: 2`). This theme sets `slide-level: 3`: `=` is a section (triggers `new-section-slide`), `==` is a subsection (triggers `new-subsection-slide`), and `===` is the actual slide/frame — only `===` headings produce a visible frame title, shown via `subslide-preamble` (not a page header/footer; there is none).
- **No header/footer chrome at all.** The default `slide()` function explicitly sets `config-page(header: none, footer: none)`. The frame title comes entirely from `subslide-preamble`, which renders the current level-3 heading in bold at the top of the slide body.
- **Section slides center both ways; subsection slides don't.** This mirrors the original Beamer theme, where the section page used `\begin{centering}` but the subsection page had that line commented out. Hence two slide-wrapper helpers exist: `centered-slide` (center + horizon; used for `title-slide` and `new-section-slide`) and `left-slide` (horizon only; used for `new-subsection-slide`). Don't merge these — the asymmetry is intentional.
- **Colors are variant-driven, not hardcoded.** `basic-theme(variant: "white" | "black" | "gray")` looks up `(bg, fg)` from the `variant-colors` dict and threads them through `config-page(fill: bg)` and `config-colors(neutral-lightest: bg, neutral-darkest: fg, primary: fg)`. Everywhere else in the file that needs a text/heading color reads `self.colors.neutral-darkest` (or relies on the ambient `set text(fill: ...)` from `config-methods(init: ...)`) rather than hardcoding black/white, so all three variants stay in sync automatically. If you add new themed elements, follow the same pattern — don't hardcode a color.
- **Title slide is metadata-driven**, not freeform content. `title-slide()` takes no body; it reads `self.info` (populated via `config-info(title:, subtitle:, author:, institution:, date:, logo:)`) and lays it out as a two-column grid (60% text / 40% logo), wrapped in `align(horizon, ...)` so the whole row centers vertically as a unit — per-cell `align(horizon, ...)` alone does not achieve this, since a single-row grid's row height already equals its content height.
- **Font is explicitly sans-serif** (`"Helvetica Neue", "Arial", "Liberation Sans", "DejaVu Sans"` fallback chain) because Beamer's own default font theme is sans-serif and Typst's default is serif — this is a deliberate fidelity choice, not an arbitrary pick.

### Two-entry-point pattern (`touying-presentation/`)

`content.typ` defines slide content once as a function parameterized over `title-slide`/`pause`/`slide`/`speaker-note`/`handout-note`. Each compiled entry point (`touying-presentation-slides-*.typ` vs. `touying-presentation-handout.typ`) supplies different implementations of those parameters via `config.typ`: the slides entry points pass the real Touying primitives (real pagination/animation/notes), while the handout passes plain no-op stand-ins so the same content renders as one flowing, non-paginated document instead. When adding new content constructs to `content.typ`, both implementations in `config.typ` need to handle them.
