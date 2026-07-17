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

Compiling against the local package (rather than a relative path) requires a one-time symlink setup — see the `install-local-theme-package` skill.

## Repo layout

- **`basic-theme/`** — the theme itself, laid out as a Typst package (`typst.toml` with `entrypoint = "lib.typ"`). Tracked in git; this is the only directory whose changes matter for the "product" of this repo.
  - `lib.typ` — all theme code (see Architecture below).
  - `logos/univ.png`, `logos/school.png` — bundled logos, exposed via `univ-logo()`/`school-logo()` helpers.
  - `README.md` — the theme's own usage docs (import syntax, heading convention, local-package install instructions). Keep in sync with `lib.typ` when changing its public API.
- **`basicwhite-beamer-theme/`** — the original Beamer `.sty` theme being replicated, plus a sample PDF and logo assets, kept purely as a visual/behavioral reference. **Gitignored** — do not expect changes here to be committable.
- **`touying-presentation/`** — a scratch Touying project used to manually test the theme against the Beamer reference. **Gitignored** — changes here are for local verification only and will never show up in `git status`. Contains `config.typ` (shared setup) + `content.typ` (shared slide content, written as a function so it can drive both slides and handout) + three slide entry points (`touying-presentation-slides-{white,black,gray}.typ`, one per theme variant) + one handout entry point. `content.typ` is generated from `talk.org` via `ox-touying.el` (see below) rather than hand-edited directly.
- **`touying-presentation-no-subsections/`** — the same scratch setup as `touying-presentation/`, but exercising the theme's default `slide-level: 2` (no subsections) instead of `slide-level: 3`. Also gitignored.
- **`rlr-touying-scaffold.el`** and **`ox-touying.el`** — Emacs tooling, tracked in git, that scaffold new presentations and generate `content.typ` from `talk.org`. The Org→Typst convention mapping (special blocks, `@@typst:...@@` snippets, image attributes, etc.) is documented in the top-level `README.md`'s "Authoring slides in Org mode" section — keep that in sync with `ox-touying.el` when the mapping changes, and don't hand-edit `content.typ` since re-exporting overwrites it.

## Architecture

### Theme structure (`basic-theme/lib.typ`)

The theme is a single file built on top of `@preview/touying:0.7.4`. Key design points a future change needs to respect:

- **Heading levels map onto the Beamer document structure**, not Touying's own default (`slide-level: 2`). This theme sets `slide-level: 3`: `=` is a section (triggers `new-section-slide`), `==` is a subsection (triggers `new-subsection-slide`), and `===` is the actual slide/frame — only `===` headings produce a visible frame title, shown via `subslide-preamble` (not a page header/footer; there is none).
- **No header/footer chrome at all.** The default `slide()` function explicitly sets `config-page(header: none, footer: none)`. The frame title comes entirely from `subslide-preamble`, which renders the current level-3 heading in bold at the top of the slide body.
- **Section slides center both ways; subsection slides don't.** This mirrors the original Beamer theme, where the section page used `\begin{centering}` but the subsection page had that line commented out. See `new-section-slide`/`new-subsection-slide`'s doc comments in `lib.typ` for why they're built directly on `touying-slide-wrapper` rather than delegating to the generic `centered-slide`/`left-slide` helpers — don't merge the two.
- **Colors are variant-driven, not hardcoded.** `basic-theme(variant:)` looks up `(bg, fg, accent)` from `variant-colors` and threads them through `config-page`/`config-colors`/`config-store(title-color:)` — see the doc comments around `variant-colors` and the `title-color` store entry in `lib.typ` for the exact mechanism. If you add new themed elements, follow the same pattern — don't hardcode a color.
- **Title slide is metadata-driven**, not freeform content. `title-slide()` takes no body; it reads `self.info` (populated via `config-info(title:, subtitle:, author:, institution:, date:, logo:)`) and lays it out as a two-column grid (60% text / 40% logo), wrapped in `align(horizon, ...)` so the whole row centers vertically as a unit — per-cell `align(horizon, ...)` alone does not achieve this, since a single-row grid's row height already equals its content height.
- **Font is explicitly sans-serif** (`"Helvetica Neue", "Arial", "Liberation Sans", "DejaVu Sans"` fallback chain) because Beamer's own default font theme is sans-serif and Typst's default is serif — this is a deliberate fidelity choice, not an arbitrary pick.

### Two-entry-point pattern (`touying-presentation/`)

`content.typ` defines slide content once as a function parameterized over `title-slide`/`pause`/`slide`/`speaker-note`/`handout-note`. Each compiled entry point (`touying-presentation-slides-*.typ` vs. `touying-presentation-handout.typ`) supplies different implementations of those parameters via `config.typ`: the slides entry points pass the real Touying primitives (real pagination/animation/notes), while the handout passes plain no-op stand-ins so the same content renders as one flowing, non-paginated document instead. When adding new content constructs to `content.typ`, both implementations in `config.typ` need to handle them.
