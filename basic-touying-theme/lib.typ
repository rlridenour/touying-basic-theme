// lib.typ
//
// A Touying theme that replicates the "basicwhite" Beamer theme:
// bold text, no header/footer chrome, and a two-column title slide
// with an optional logo. Offers three background/text variants --
// "white" (black on white), "black" (white on black), and "gray"
// (black on light gray) -- selected via `basic-theme(variant: ...)`.
//
// Heading levels map onto the Beamer document structure:
//   =   section        (\section)
//   ==  subsection      (\subsection)
//   === slide / frame    (\begin{frame}{...})

#import "@preview/touying:0.7.4": *

/// The "univ" logo bundled with the theme, for use as
/// `config-info(logo: univ-logo())`.
#let univ-logo(width: 90%) = image("logos/univ.png", width: width)

/// The "school" logo bundled with the theme, for use as
/// `config-info(logo: school-logo())`.
#let school-logo(width: 90%) = image("logos/school.png", width: width)

/// Default slide function. The frame title (the current level-3
/// heading) is shown bold at the top of the slide body via
/// `subslide-preamble` -- there is no separate header/footer chrome,
/// mirroring the Beamer theme's plain `frametitle` template.
#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  let self = utils.merge-dicts(
    self,
    config-page(header: none, footer: none),
    config-common(subslide-preamble: self.store.subslide-preamble),
  )
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: setting,
    composer: composer,
    ..bodies,
  )
})

/// A slide with two side-by-side columns, e.g. text next to an
/// image. Set its frame title with a `===` heading as usual and call
/// this in place of that heading's plain body.
///
/// Example:
///
/// ```typst
/// === My Slide
/// #two-column-slide[Left content][Right content]
/// ```
///
/// - columns (array): The two column widths. Default is `(1fr, 1fr)`.
///
/// - gutter (length): The space between the two columns. Default is `2em`.
#let two-column-slide(
  config: (:),
  columns: (1fr, 1fr),
  gutter: 2em,
  ..bodies,
) = slide(
  config: config,
  composer: cols.with(columns: columns, gutter: gutter),
  ..bodies,
)

/// A full-bleed slide with no margin, no header/footer, and no frame
/// title -- for a full-screen image or other graphic. Doesn't need a
/// heading; if placed right after one, that heading's title is
/// simply not shown on this slide.
///
/// Example: `#full-slide(image("photo.jpg", width: 100%, height: 100%, fit: "cover"))`
///
/// - fill (color, none, auto): The slide's background fill, useful as
///   letterboxing behind a graphic that doesn't cover the full frame.
///   Default is `auto`, which keeps the theme's current variant background.
#let full-slide(config: (:), fill: auto, body) = touying-slide-wrapper(self => {
  let page-args = (margin: 0pt, header: none, footer: none)
  if fill != auto {
    page-args.fill = fill
  }
  let self = utils.merge-dicts(
    self,
    config-page(..page-args),
    config-common(subslide-preamble: none),
  )
  touying-slide(self: self, config: config, body)
})

/// A slide whose body is centered, both horizontally and vertically.
/// Used for the title and section slides.
#let centered-slide(config: (:), ..args) = touying-slide-wrapper(self => {
  touying-slide(self: self, ..args.named(), config: config, align(
    center + horizon,
    args.pos().sum(default: none),
  ))
})

/// A slide whose body is vertically centered but flush left, used for
/// the subsection slide -- the Beamer theme's `subsection page`
/// template, unlike its `section page`, doesn't horizontally center.
#let left-slide(config: (:), ..args) = touying-slide-wrapper(self => {
  touying-slide(self: self, ..args.named(), config: config, align(
    horizon,
    args.pos().sum(default: none),
  ))
})

/// Title slide, built from the metadata set with `config-info`
/// (title, subtitle, author, institution, date, logo). Mirrors the
/// Beamer theme's `title page` template: text in the left 60%,
/// an optional logo vertically centered in the right 40%.
#let title-slide(config: (:), extra: none, ..args) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(self, config-common(freeze-slide-counter: true), config)
  let info = self.info + args.named()

  let text-block = {
    set align(left)
    set text(fill: self.colors.neutral-darkest)
    block(below: .5em, text(size: 1.3em, weight: "bold", info.title))
    if info.subtitle not in (none, []) {
      block(below: 1em, text(size: .9em, weight: "bold", info.subtitle))
    }
    if info.author not in (none, []) {
      block(below: .6em, text(size: 0.8em, info.author))
    }
    if info.institution not in (none, []) {
        block(below: .6em, text(size: .8em, info.institution))
    }
    if info.date != none {
      block(below: .6em, text(size: .8em, utils.display-info-date(self)))
    }
    if extra != none {
      block(above: .5em, text(size: .75em, extra))
    }
  }

  let body = align(horizon, grid(
    columns: (60%, 40%),
    align(horizon, text-block),
    align(center + horizon, if info.logo != none { info.logo }),
  ))

  touying-slide(self: self, config: config, body)
})

/// New section slide: bold heading, centered on an otherwise blank
/// slide, mirroring the `section page` template. Triggered
/// automatically on level-1 (`=`) headings.
#let new-section-slide(config: (:), body) = centered-slide(config: config, [
  #text(size: 1.4em, weight: "bold", utils.display-current-heading(level: 1))
  #body
])

/// New subsection slide: same treatment, one size down, but flush
/// left rather than centered, mirroring the `subsection page`
/// template. Triggered automatically on level-2 (`==`) headings.
#let new-subsection-slide(config: (:), body) = left-slide(config: config, [
  #text(size: 1.15em, weight: "bold", utils.display-current-heading(level: 2))
  #body
])

// Background/text colors for each variant.
#let variant-colors = (
  white: (bg: white, fg: black),
  black: (bg: black, fg: white),
  gray: (bg: rgb("#eeeeee"), fg: black),
)

/// Touying basic theme.
///
/// Example:
///
/// ```typst
/// #show: basic-theme.with(
///   aspect-ratio: "16-9",
///   variant: "black",
///   config-info(
///     title: [My Talk],
///     author: [Dr. Ridenour],
///     institution: [Department of Philosophy],
///     date: datetime.today(),
///     logo: univ-logo(),
///   ),
/// )
/// ```
///
/// - aspect-ratio (string): The aspect ratio of the slides. Default is `16-9`.
///
/// - variant (string): The background/text color scheme -- `"white"` (black
///   on white), `"black"` (white on black), or `"gray"` (black on light
///   gray). Default is `"white"`.
///
/// - subslide-preamble (content): What is shown at the top of each slide's
///   body as its frame title. Default is the current level-3 heading, bold.
#let basic-theme(
  aspect-ratio: "16-9",
  variant: "white",
  subslide-preamble: block(
    below: 2em,
    text(size: 1.2em, weight: "bold", utils.display-current-heading(level: 3)),
  ),
  ..args,
  body,
) = {
  assert(
    variant in variant-colors,
    message: "basic-theme: variant must be one of " + repr(variant-colors.keys()),
  )
  let (bg, fg) = variant-colors.at(variant)

  show: touying-slides.with(
    config-page(
      ..utils.page-args-from-aspect-ratio(aspect-ratio),
      margin: 2em,
      fill: bg,
    ),
    config-common(
      slide-level: 3,
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
      new-subsection-slide-fn: new-subsection-slide,
    ),
    config-methods(
      init: (self: none, body) => {
        // Beamer's default font theme is sans-serif; match it here.
        set text(
          font: ("Helvetica Neue", "Arial", "Liberation Sans", "DejaVu Sans"),
          size: 25pt,
          fill: self.colors.neutral-darkest,
        )
        set list(marker: [•])
        set enum(numbering: "1.a.i)")
        show footnote.entry: set text(size: .6em)
        body
      },
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      neutral-lightest: bg,
      neutral-darkest: fg,
      primary: fg,
    ),
    // save the variables for later use
    config-store(
      subslide-preamble: subslide-preamble,
    ),
    ..args,
  )

  body
}
