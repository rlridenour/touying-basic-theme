// config.typ
// Shared configuration for both the live slide deck (sample-presentation-slides.typ) and
// the continuous handout (sample-presentation-handout.typ).
//
// content.typ defines its content as a function that takes title-slide/
// pause/speaker-note/handout-note/two-column-slide/full-slide/statement
// as parameters -- plain body content under a heading needs no wrapper
// at all; Touying automatically turns it into a slide when the theme's
// slide-fn is registered (see basic-theme.with(...) below), which keeps
// content.typ close to a plain Org-mode export. Each entry point below
// supplies its own implementations of the remaining parameters:
// sample-presentation-slides.typ passes the real Touying building blocks (real
// pagination, animations, speaker notes); sample-presentation-handout.typ passes plain,
// non-paginating stand-ins so the whole thing renders as one flowing
// document instead of a slide deck.

#import "@preview/touying:0.7.4": *
#import "@local/basic-theme:0.1.0": (
  basic-theme,
  basic-theme-date-format,
  univ-logo,
  title-slide as live-title-slide,
  pause as live-pause,
  speaker-note as live-speaker-note,
  two-column-slide as live-two-column-slide,
  full-slide as live-full-slide,
)

// Presentation metadata, shared between the live title slide (which
// reads it via Touying's `self.info`) and the handout title "slide"
// (which has no Touying context and so renders it directly).
#let presentation-info = (
  title: [Sample Presentation],
  subtitle: [Touying Basic Theme],
  author: [Randy Ridenour],
  date: datetime.today(),
  institution: [Department of Philosophy],
)

// variant: "white" (default), "black", or "gray".
//
// slide-level: 2 (default) for a talk with no subsections (`=`
// section, `==` frame directly), or 3 if this talk uses subsections
// (`=` section, `==` subsection, `===` frame).
#let project(variant: "white", slide-level: 2, body) = {
  show: basic-theme.with(
    aspect-ratio: "16-9",
    variant: variant,
    slide-level: slide-level,
    config-common(
      show-notes-on-second-screen: right,
    ),
    config-info(
      ..presentation-info,
      logo: univ-logo(),
    ),
  )

  body
}

// Big centered text for #+begin_statement -- both axes via
// align(center + horizon), since a live slide is a fixed-size page.
#let live-statement(size: 2em, body) = align(center + horizon, text(size: size, body))

// Handout notes never show on the live deck.
#let live-handout-note(body) = none

// -- Handout: a single flowing document, no slide pagination ---------------

// Portrait US letter, 12pt body text; no theme/pagination machinery at
// all. Headings (section, and frame, and subsection if slide-level: 3
// is used) render plainly with their own numbering (1, 1.1, 1.2, ...)
// -- there's no box, so a frame heading doesn't need special hiding/
// relocation the way it did when its title had to be pulled inside one.
#let handout-project(body) = {
  set page(paper: "us-letter")
  set text(size: 12pt)
  set heading(numbering: "1.1")
  body
}

// The document title is not a "slide" in the same sense as the others
// -- kept outside any box, same as section/subsection titles.
#let handout-title-slide() = align(center)[
  #text(size: 1.4em, weight: "bold", presentation-info.title)

  #if presentation-info.subtitle not in (none, []) {
    text(size: 1.15em, weight: "bold", presentation-info.subtitle)
  }

  #v(0.5em)

  #presentation-info.author

  #presentation-info.institution

  #presentation-info.date.display(basic-theme-date-format)
]

// No animation reveal in a flowing document: everything is simply shown.
#let handout-pause = none

// Speaker notes are presenter-only; never shown in the handout.
#let handout-speaker-note(body) = none

// A plain two-up grid; there's no pagination to preserve here.
#let handout-two-column-slide(columns: (1fr, 1fr), gutter: 2em, ..bodies) = grid(
  columns: columns,
  gutter: gutter,
  ..bodies.pos(),
)

// There's no full-bleed page in a flowing document, and a `100%` height
// inside body would otherwise resolve against the whole rest of the
// page -- bound it to a fixed-height box instead, so the graphic shows
// inline at a sane size. bleed: false opts out of that box for
// non-graphic content (e.g. a #+begin_statement nested inside
// #+begin_fullslide) that doesn't need it and would otherwise sit in a
// mostly-empty box, wasting paper.
#let handout-full-slide(fill: auto, bleed: true, body) = if bleed {
  box(width: 100%, height: 300pt, clip: true, body)
} else {
  body
}

// Same reasoning as handout-full-slide: align(..., horizon, ...) would
// expand to fill the whole rest of the page in a flowing document,
// leaving a lot of blank space above and below the text and wasting
// paper. Center horizontally only, with no added vertical spacing --
// ordinary block spacing (same as a plain paragraph) is enough, and an
// explicit v() here would stack on top of the next heading's own
// above-spacing and look doubled.
#let handout-statement(size: 2em, body) = align(center, text(size: size, body))

// A handout note is reader-only context that never appeared on the live
// slide -- a line above it marks that boundary, so it's clear the text
// below the line wasn't part of what the audience saw.
#let handout-note(body) = {
  v(0.5em)
  line(length: 100%, stroke: 0.5pt + gray)
  v(0.5em)
  body
}
