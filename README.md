# touying-basic-theme

A [Touying](https://touying-typ.github.io/) theme for Typst presentations, replicating the `basicwhite` Beamer theme: a plain white background, bold black sans-serif text, no header/footer chrome, and a two-column title slide with an optional logo.

The theme lives in [`basicwhite-touying-theme/`](basicwhite-touying-theme) — see that folder's README for the full option reference, including how to install it as a local Typst package. Quick start, assuming it's installed as `@local/basicwhite-touying-theme:0.1.0`:

```typst
#import "@preview/touying:0.7.4": *
#import "@local/basicwhite-touying-theme:0.1.0": *

#show: basicwhite-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [My Talk],
    subtitle: [A subtitle],
    author: [Dr. Ridenour],
    institution: [Department of Philosophy],
    date: datetime.today(),
    logo: univ-logo(),
  ),
)

#title-slide()

= Section

== Subsection

=== A slide

Content goes here.
```

Headings map onto the Beamer document structure: `=` is a section (`\section`), `==` is a subsection (`\subsection`), and `===` is a slide/frame (`\begin{frame}{...}`) — only `===` headings become a visible frame title.

## Repo layout

- `basicwhite-touying-theme/` — the Touying theme itself (a Typst package: `typst.toml`, `lib.typ`, logos), the deliverable of this repo.
- `basicwhite-beamer-theme/` — the original Beamer theme (`.sty` files, sample PDF, logos) this Touying theme replicates, kept for reference.
- `touying-presentation/` — a scratch Touying project used to test the theme against the Beamer reference; not tracked in git.
