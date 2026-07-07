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

## Authoring slides in Org mode

`ox-touying.el` is a custom Org export backend that generates a working `content.typ` from a `talk.org` file, so a talk's content can be written once in Org and re-exported instead of hand-written as Typst. `M-x rlr/new-touying-presentation` (see `rlr-touying-scaffold.el`) scaffolds a new presentation's `talk.org` alongside `config.typ` and the slides/handout entry points, generating an initial `content.typ` from it automatically. After that, edit `talk.org` and re-export with `M-x rlr/org-export-to-touying-content` any time it changes -- don't hand-edit the generated `content.typ`, since re-exporting overwrites it.

Conventions:

- Headline depth maps 1:1 onto Typst heading depth (`*` -> `=`, `**` -> `==`, `***` -> `===`); plain body text under a heading needs no wrapper, exactly as in `content.typ` directly. Whether `==` is a frame or a subsection depends on the presentation's own `slide-level` in `config.typ`, not on the exporter.
- `#+begin_speakernote ... #+end_speakernote` → `#speaker-note[...]`
- `#+begin_handoutnote ... #+end_handoutnote` → `#handout-note[...]`
- `@@typst:...@@` export snippets pass straight through as raw Typst — use `@@typst:#pause@@` for a progressive reveal.
- `#+begin_columns` containing two `#+begin_column ... #+end_column` blocks → `#two-column-slide[...][...]`
- `#+begin_fullslide ... #+end_fullslide` → `#full-slide(...)`. A lone image link inside becomes a full-bleed image (`width: 100%, height: 100%, fit: "cover"`) unless it has its own `#+ATTR_TOUYING` sizing (see below), which is kept as-is instead of being forced to fill the slide.
- `#+begin_statement ... #+end_statement` → big centered text (`align(center + horizon, text(size: ...)[...])`), sized via a preceding `#+ATTR_TOUYING: :size ...` (default `2em`). Nest inside `#+begin_fullslide` for a blank, title-less statement slide, or leave it standalone under a heading to keep the frame title.
- An image link honors a preceding `#+ATTR_TOUYING: :width ... :height ... :fit ... :align ...`, e.g. `#+ATTR_TOUYING: :width 50%`. `:align` (e.g. `center`, `center + horizon`) wraps the image in `#align(...)`, since alignment is a property of the surrounding container in Typst, not of `image()` itself.
- Bold/italic/code/lists/links get basic Typst equivalents. Tables, footnotes, and other exotic constructs aren't specially handled (they fall back to plain ascii-backend rendering) -- expect to touch those up by hand in `content.typ` afterward.

Example:

```org
#+TITLE: My Talk

* Section

** A slide

Plain content, no wrapper needed.

@@typst:#pause@@

More content, revealed after a pause.

#+begin_handoutnote
Reader-only context -- never shown on the live slides, only in the handout.
#+end_handoutnote

** Main Point

#+begin_fullslide
#+ATTR_TOUYING: :size 3em
#+begin_statement
Main Point
#+end_statement
#+end_fullslide
```
