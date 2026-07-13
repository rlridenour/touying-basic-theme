// lib.typ
//
// A Touying theme that replicates the "basicwhite" Beamer theme:
// bold text, no header/footer chrome, and a two-column title slide
// with an optional logo. Offers three background/text variants --
// "white" (black on white), "black" (white on black), and "gray"
// (black on light gray) -- selected via `basic-theme(variant: ...)`.
//
// Heading levels map onto the Beamer document structure. By default
// (slide-level: 2, since most talks don't need subsections):
//   =   section  (\section)
//   ==  frame    (\begin{frame}{...})
// Pass slide-level: 3 for a talk that does use subsections:
//   =   section        (\section)
//   ==  subsection      (\subsection)
//   === slide / frame    (\begin{frame}{...})

#import "@preview/touying:0.7.4": *
#import "@preview/touying:0.7.4": speaker-note as touying-speaker-note

/// The date format used for the title slide's date field, e.g. "July 5,
/// 2026". Exposed so a handout (which renders the date directly, outside
/// any Touying context) can format it identically -- see
/// `datetime.display(basic-theme-date-format)`.
#let basic-theme-date-format = "[month repr:long] [day padding:none], [year]"

/// Speaker note, shown smaller than the slide body so it reads as a
/// presenter aside rather than slide content.
#let speaker-note(
  mode: "typ",
  setting: text.with(size: .7em),
  subslide: auto,
  note,
) = touying-speaker-note(mode: mode, setting: setting, subslide: subslide, note)

/// The "univ" logo bundled with the theme, for use as
/// `config-info(logo: univ-logo())`.
#let univ-logo(width: 90%) = image("logos/univ.png", width: width)

/// The "school" logo bundled with the theme, for use as
/// `config-info(logo: school-logo())`.
#let school-logo(width: 90%) = image("logos/school.png", width: width)

// Detect a plain `#pause` marker (equivalent to `jump(1, relative: true)`)
// -- the only pause/jump/meanwhile variant slide authors have access to
// via content.typ's `pause` parameter, so it's the only one `slide()`
// needs to recognize when reserving space for it (see `_reserve-pauses`).
#let _is-simple-pause(child) = (
  type(child) == content
    and child.func() == metadata
    and type(child.value) == dictionary
    and child.value.at("kind", default: none) == "touying-jump/pause/meanwhile"
    and child.value.at("relative", default: false) == true
    and child.value.at("n", default: 0) == 1
)

// Rewrite BODY so each top-level `#pause` becomes a boundary between
// `uncover(...)`-wrapped chunks instead of touying's own default pause
// handling. Plain `#pause` reveals later content by simply omitting it on
// earlier subslides -- no space is reserved, so a shorter,
// partially-revealed body would center at a different vertical position
// than the final, fully-revealed one. `uncover` reserves space for hidden
// content (like `#hide()`), so wrapping each post-pause chunk in it keeps
// the body's total height -- and therefore its centered position -- fixed
// across the whole reveal sequence (see `slide()`'s composer).
#let _reserve-pauses(body) = {
  let children = if utils.is-sequence(body) { body.children } else { (body,) }
  let chunks = ((),)
  for child in children {
    if _is-simple-pause(child) {
      chunks.push(())
    } else {
      chunks.last().push(child)
    }
  }
  if chunks.len() == 1 {
    return body
  }
  chunks
    .enumerate()
    .map(((i, parts)) => {
      let chunk-body = parts.sum(default: [])
      if i == 0 { chunk-body } else { uncover(str(i + 1) + "-", chunk-body) }
    })
    .sum()
}

/// Default slide function. The frame title (the current level-3
/// heading) is shown bold at the top of the slide body via
/// `subslide-preamble` -- there is no separate header/footer chrome,
/// mirroring the Beamer theme's plain `frametitle` template. The body
/// below the title is centered vertically in the remaining space
/// (`#pause` reveals are handled so already-revealed content doesn't
/// shift position as more of the body appears -- see `_reserve-pauses`).
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
  let vertical-composer(..args) = {
    let effective-composer = if composer != auto {
      composer
    } else {
      self.at("default-composer", default: auto)
    }
    let composed = if type(effective-composer) == function {
      effective-composer(..args)
    } else {
      components.cols(
        lazy-layout: false,
        columns: effective-composer,
        ..args,
      )
    }
    align(horizon, composed)
  }
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: setting,
    composer: vertical-composer,
    ..bodies.pos().map(_reserve-pauses),
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
///
/// - bleed (boolean): Has no effect here -- a live slide is always
///   exactly the physical page size regardless. Accepted only so the
///   same call works against a Touying handout's own full-slide
///   stand-in, where bleed: false skips bounding the body in an
///   image-sized box (appropriate for non-graphic content, like a
///   short centered statement, that doesn't need it). Default is `true`.
#let full-slide(config: (:), fill: auto, bleed: true, body) = touying-slide-wrapper(self => {
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
      block(below: .8em, text(size: 1.3em, weight: "bold", info.title))
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

// The speaker-notes-view header (used by `show-notes-on-second-screen`/
// `show-only-notes`) breadcrumbs headings above the frame level, e.g.
// "Section --- Subsection". Touying's own default hardcodes that to
// levels 1 and 2, which is right when slide-level is 3 (level 2 really
// is the subsection) but wrong when slide-level is 2: level 2 is then
// the frame heading itself, so the default just repeats the frame's own
// title as a fake second line. Parameterize it by slide-level instead,
// only showing a second breadcrumb line when there's a genuine
// subsection level (slide-level: 3) to show.
#let basic-theme-show-only-notes(slide-level) = (
  self: none,
  width: 0pt,
  height: 0pt,
  cutout: false,
) => {
  let header-fill = rgb("#CCCCCC")
  let header-height = 88pt
  let header-content = {
    utils.display-current-heading(level: 1, depth: self.slide-level)
    if slide-level > 2 {
      linebreak()
      [ --- ]
      utils.display-current-heading(level: 2, depth: self.slide-level)
    }
  }
  let body-fill = rgb("#E6E6E6")
  let body-content = {
    pad(x: 48pt, utils.current-slide-note)
    // clear the slide note
    utils.slide-note-state.update(none)
  }

  let template(hdr-fill, hdr-content, bdy-fill, bdy-content) = block(
    fill: bdy-fill,
    width: width,
    height: height,
    {
      set align(left + top)
      set text(size: 24pt, fill: black, weight: "regular")
      block(
        width: 100%,
        height: header-height,
        inset: (left: 32pt, top: 16pt),
        outset: 0pt,
        fill: hdr-fill,
        hdr-content,
      )
      bdy-content
    },
  )

  if cutout {
    (
      background: template(header-fill, none, body-fill, none),
      foreground: template(none, header-content, none, body-content),
      cutout-height: header-height,
    )
  } else {
    template(header-fill, header-content, body-fill, body-content)
  }
}

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
/// - slide-level (int): The heading depth that becomes a frame -- `2` (the
///   default) for a talk with no subsections (`=` section, `==` frame
///   directly), or `3` if the talk uses subsections (`=` section, `==`
///   subsection, `===` frame). No other values are supported.
///
/// - subslide-preamble (content): What is shown at the top of each slide's
///   body as its frame title. Default is the current frame-level heading
///   (i.e. the heading at `slide-level`), bold.
#let basic-theme(
  aspect-ratio: "16-9",
  variant: "white",
  slide-level: 2,
  subslide-preamble: auto,
  ..args,
  body,
) = {
  assert(
    variant in variant-colors,
    message: "basic-theme: variant must be one of " + repr(variant-colors.keys()),
  )
  assert(
    slide-level in (2, 3),
    message: "basic-theme: slide-level must be 2 (no subsections) or 3 (with subsections)",
  )
  let (bg, fg) = variant-colors.at(variant)
  let subslide-preamble = if subslide-preamble == auto {
    block(
      below: 2em,
      text(
        size: 1.2em,
        weight: "bold",
        utils.display-current-heading(level: slide-level, numbered: false),
      ),
    )
  } else {
    subslide-preamble
  }

  show: touying-slides.with(
    config-page(
      ..utils.page-args-from-aspect-ratio(aspect-ratio),
      margin: 2em,
      fill: bg,
    ),
    config-common(
      slide-level: slide-level,
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
      // Touying's core dispatch always routes depth-2 headings through
      // new-subsection-slide-fn, regardless of slide-level (see its
      // core.typ). At slide-level: 2, a depth-2 heading *is* the frame
      // itself, not a subsection -- registering this unconditionally
      // made every frame heading also spawn a phantom title-only
      // "subsection" page right before its real content. Only wire it
      // up when slide-level: 3 actually puts a genuine subsection at
      // depth 2.
      new-subsection-slide-fn: if slide-level > 2 { new-subsection-slide } else { none },
      datetime-format: basic-theme-date-format,
    ),
    config-methods(
      init: (self: none, body) => {
        // Beamer's default font theme is sans-serif; match it here.
        set text(
          font: ("SF Pro", "Helvetica Neue", "Arial", "Fira Sans", "DejaVu Sans"),
          size: 25pt,
            weight: "medium",
          fill: self.colors.neutral-darkest,
        )
        set list(marker: [•], spacing: 1em, indent: 1em)
        set enum(numbering: "1.a.i.", spacing: 1em, indent: 1em)
        show footnote.entry: set text(size: .6em)
        body
      },
      alert: utils.alert-with-primary-color,
      show-only-notes: basic-theme-show-only-notes(slide-level),
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
