# basic Touying theme

A [Touying](https://touying-typ.github.io/) theme that replicates the
`basicwhite` Beamer theme (see `../basicwhite-beamer-theme`): bold
text, no header/footer chrome, and a two-column title slide with an
optional logo. Offers three background/text variants: `"white"`
(black on white, the default), `"black"` (white on black), and
`"gray"` (black on light gray).

This folder is laid out as a Typst package (`typst.toml` + `lib.typ`
entrypoint), so it can be installed as a local package -- see
[Installing as a local package](#installing-as-a-local-package) below.

## Usage

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

== Subsection

=== A slide

Content goes here.
```

If you'd rather not install it as a package, you can import `lib.typ`
directly by relative path instead -- but since it then lives outside
whatever folder you compile from, you'll need to pass `--root` (or
configure your editor's Typst root) to a common ancestor directory:

```typst
#import "path/to/basic-theme/lib.typ": *
```

```sh
typst compile --root . your-presentation/your-presentation.typ
```

## Installing as a local package

Typst looks for local packages in:

- macOS: `~/Library/Application Support/typst/packages/local/<name>/<version>`
- Linux: `~/.local/share/typst/packages/local/<name>/<version>`
- Windows: `%APPDATA%\typst\packages\local\<name>\<version>`

Symlink the versioned directory to this folder so edits here are picked
up immediately, without a separate copy/install step:

```sh
# macOS
mkdir -p "$HOME/Library/Application Support/typst/packages/local/basic-theme"
ln -s "/path/to/touying-basic-theme/basic-theme" \
  "$HOME/Library/Application Support/typst/packages/local/basic-theme/0.1.0"
```

Then `#import "@local/basic-theme:0.1.0": *` works from any
Typst project on the machine.

## Heading levels

Headings map onto the Beamer document structure:

| Heading | Beamer equivalent    |
| ------- | -------------------- |
| `=`     | `\section{}`          |
| `==`    | `\subsection{}`       |
| `===`   | `\begin{frame}{...}`  |

Only `===` headings become the visible frame title (bold, top of the
slide body); `=` and `==` headings produce their own full section /
subsection slides.

If a talk has no subsections, pass `slide-level: 2` to skip the
subsection level entirely -- then `=` is a section and `==` is the
frame directly (its heading becomes the visible frame title, and
there's no separate subsection slide):

```typst
#show: basic-theme.with(
  slide-level: 2,
  // ...
)

= Section

== A slide

Content goes here.
```

## Two-column slides

`two-column-slide` lays out its two arguments side by side, under the
usual `===` frame title:

```typst
=== A Slide
#two-column-slide(gutter: 2em)[Left content][Right content]
```

`columns` (default `(1fr, 1fr)`) and `gutter` (default `2em`) control
the widths and spacing. For anything more custom (three columns, an
asymmetric split, etc.), call the underlying `slide` directly with
Touying's `composer` argument, e.g. `#slide(composer: (2fr, 1fr))[...][...]`.

## Full-bleed graphic slides

`full-slide` renders its body with no margin, no header/footer, and
no frame title -- for a full-screen image or other graphic that
should fill the slide edge to edge:

```typst
#full-slide(image("photo.jpg", width: 100%, height: 100%, fit: "cover"))
```

It doesn't need a preceding heading; placed right after one, that
heading's title simply isn't shown on this particular slide. Pass
`fill:` to letterbox behind a graphic that doesn't cover the full
frame -- by default the fill is `auto`, which keeps the theme's
current variant background.

## Logos

`univ-logo(width: 90%)` and `school-logo(width: 90%)` return the two
logos bundled with the theme (copied from the Beamer theme), for use
as `config-info(logo: univ-logo())`. Omit `logo` (or pass `none`) for
a plain title slide with no image.
