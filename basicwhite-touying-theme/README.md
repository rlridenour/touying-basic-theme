# basicwhite Touying theme

A [Touying](https://touying-typ.github.io/) theme that replicates the
`basicwhite` Beamer theme (see `../basicwhite-beamer-theme`): a plain
white background, bold black text, no header/footer chrome, and a
two-column title slide with an optional logo.

## Usage

```typst
#import "@preview/touying:0.7.4": *
#import "path/to/basicwhite-touying-theme/theme.typ": *

#show: basicwhite-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [My Talk],
    subtitle: [A subtitle],
    author: [Dr. Ridenour],
    institution: [Department of Philosophy],
    date: datetime.today(),
    logo: image("path/to/basicwhite-touying-theme/logos/univ.png", width: 60%),
  ),
)

#title-slide()

= Section

== Subsection

=== A slide

Content goes here.
```

Since `theme.typ` lives outside whatever folder you compile from, pass
`--root` (or configure your editor's Typst root) to a common ancestor
directory so the import doesn't escape the project sandbox, e.g. from
this repo's root:

```sh
typst compile --root . touying-presentation/touying-presentation-slides.typ
```

## Heading levels

Headings map onto the Beamer document structure:

| Heading | Beamer equivalent   |
| ------- | ------------------- |
| `=`     | `\section{}`         |
| `==`    | `\subsection{}`      |
| `===`   | `\begin{frame}{...}` |

Only `===` headings become the visible frame title (bold, top of the
slide body); `=` and `==` headings produce their own full section /
subsection slides.

## Logos

`logos/univ.png` and `logos/school.png` are copied from the Beamer
theme for use as `config-info(logo: ...)`. Omit `logo` (or pass
`none`) for a plain title slide with no image.
