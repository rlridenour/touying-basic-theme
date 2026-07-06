# touying-basic-theme

A [Touying](https://touying-typ.github.io/) theme for Typst presentations, replicating the `basicwhite` Beamer theme: bold sans-serif text, no header/footer chrome, and a two-column title slide with an optional logo. Comes in three background/text variants: `"white"` (black on white, the default), `"black"` (white on black), and `"gray"` (black on light gray).

The theme lives in [`basic-theme/`](basic-theme) — see that folder's README for the full option reference, including how to install it as a local Typst package. Quick start, assuming it's installed as `@local/basic-theme:0.1.0`:

```typst
#import "@preview/touying:0.7.4": *
#import "@local/basic-theme:0.1.0": *

#show: basic-theme.with(
  aspect-ratio: "16-9",
  variant: "white", // or "black", "gray"
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

== A slide

Content goes here.
```

Headings map onto the Beamer document structure: `=` is a section (`\section`) and `==` is a slide/frame (`\begin{frame}{...}`) — pass `slide-level: 3` for a talk that also needs a subsection level (`==` subsection, `===` frame). Plain content under a frame heading needs no wrapper; it becomes a slide automatically, which is why the `content.typ` files in the scratch projects below can stay close to a plain Org-mode export -- only `speaker-note`/`handout-note` (which must differ between the live deck and a handout) and the two special layouts (`two-column-slide`, `full-slide`) are explicit calls.

## Repo layout

- `basic-theme/` — the Touying theme itself (a Typst package: `typst.toml`, `lib.typ`, logos), the deliverable of this repo.
- `basicwhite-beamer-theme/` — the original Beamer theme (`.sty` files, sample PDF, logos) this Touying theme replicates, kept for reference.
- `touying-presentation/` — a scratch Touying project used to test the theme (with `slide-level: 3`, exercising subsections) against the Beamer reference; not tracked in git.
- `touying-presentation-no-subsections/` — the same scratch setup, but with the theme's default `slide-level: 2` (no subsections); not tracked in git.
