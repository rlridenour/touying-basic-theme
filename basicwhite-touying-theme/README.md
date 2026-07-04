# basicwhite Touying theme

A [Touying](https://touying-typ.github.io/) theme that replicates the
`basicwhite` Beamer theme (see `../basicwhite-beamer-theme`): a plain
white background, bold black text, no header/footer chrome, and a
two-column title slide with an optional logo.

This folder is laid out as a Typst package (`typst.toml` + `lib.typ`
entrypoint), so it can be installed as a local package -- see
[Installing as a local package](#installing-as-a-local-package) below.

## Usage

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

If you'd rather not install it as a package, you can import `lib.typ`
directly by relative path instead -- but since it then lives outside
whatever folder you compile from, you'll need to pass `--root` (or
configure your editor's Typst root) to a common ancestor directory:

```typst
#import "path/to/basicwhite-touying-theme/lib.typ": *
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
mkdir -p "$HOME/Library/Application Support/typst/packages/local/basicwhite-touying-theme"
ln -s "/path/to/touying-basic-theme/basicwhite-touying-theme" \
  "$HOME/Library/Application Support/typst/packages/local/basicwhite-touying-theme/0.1.0"
```

Then `#import "@local/basicwhite-touying-theme:0.1.0": *` works from
any Typst project on the machine.

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

## Logos

`univ-logo(width: 60%)` and `school-logo(width: 60%)` return the two
logos bundled with the theme (copied from the Beamer theme), for use
as `config-info(logo: univ-logo())`. Omit `logo` (or pass `none`) for
a plain title slide with no image.
