// lib.typ
//
// A Touying theme that replicates the "Basic White" Beamer theme: a
// plain white background, bold black text, no header/footer chrome,
// and a two-column title slide with an optional logo.
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
/// heading) is shown bold and black at the top of the slide body via
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

/// A slide whose body is centered, both horizontally and vertically.
/// Used for the title, section, and subsection slides.
#let centered-slide(config: (:), ..args) = touying-slide-wrapper(self => {
  touying-slide(self: self, ..args.named(), config: config, align(
    center + horizon,
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

/// New section slide: bold black heading, centered on an otherwise
/// blank slide, mirroring the `section page` template. Triggered
/// automatically on level-1 (`=`) headings.
#let new-section-slide(config: (:), body) = centered-slide(config: config, [
  #text(size: 1.4em, weight: "bold", utils.display-current-heading(level: 1))
  #body
])

/// New subsection slide: same treatment, one size down, mirroring
/// the `subsection page` template. Triggered automatically on
/// level-2 (`==`) headings.
#let new-subsection-slide(config: (:), body) = centered-slide(config: config, [
  #text(size: 1.15em, weight: "bold", utils.display-current-heading(level: 2))
  #body
])

/// Touying basicwhite theme.
///
/// Example:
///
/// ```typst
/// #show: basicwhite-theme.with(
///   aspect-ratio: "16-9",
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
/// - subslide-preamble (content): What is shown at the top of each slide's
///   body as its frame title. Default is the current level-3 heading, bold
///   and black.
#let basicwhite-theme(
  aspect-ratio: "16-9",
  subslide-preamble: block(
    below: 1em,
    text(size: 1.2em, weight: "bold", utils.display-current-heading(level: 3)),
  ),
  ..args,
  body,
) = {
  show: touying-slides.with(
    config-page(
      ..utils.page-args-from-aspect-ratio(aspect-ratio),
      margin: 2em,
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
      neutral-lightest: white,
      neutral-darkest: black,
      primary: black,
    ),
    // save the variables for later use
    config-store(
      subslide-preamble: subslide-preamble,
    ),
    ..args,
  )

  body
}
