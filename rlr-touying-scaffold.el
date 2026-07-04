;;; rlr-touying-scaffold.el --- Scaffold a new Touying presentation -*- lexical-binding: t; -*-

;; Creates a new Touying presentation directory containing config.typ,
;; content.typ, a live slide deck, and a flowing handout, following the
;; config.typ / content.typ / slides.typ / handout.typ pattern where the
;; slide deck and handout are the two things you actually compile.
;;
;; Uses the "basic-theme" Touying package (@local/basic-theme:0.1.0):
;; heading levels map onto section (=) / subsection (==) / frame (===),
;; the theme supports "white"/"black"/"gray" variants, and the generated
;; handout boxes each slide (with its title inside the box) and numbers
;; sections/subsections.
;;
;; Usage: M-x rlr/new-touying-presentation

(require 'seq)

(defun rlr/touying-slugify (title)
  "Build a lowercase, hyphenated filename slug from TITLE.
Words of two letters or fewer, and the words \"the\" and \"and\", are
dropped."
  (let ((words (split-string (downcase title) "[^a-z0-9]+" t)))
    (mapconcat #'identity
               (seq-filter (lambda (w) (and (> (length w) 2)
                                            (not (member w '("the" "and")))))
                           words)
               "-")))

(defun rlr/touying--write-file (path content)
  "Write CONTENT to PATH, refusing to overwrite an existing file."
  (when (file-exists-p path)
    (user-error "File already exists: %s" path))
  (with-temp-file path
    (insert content)))

(defun rlr/touying-config-template (slug title)
  "Return the contents of config.typ for a presentation titled TITLE.
SLUG names the corresponding slides/handout files in the comments."
  (format "// config.typ
// Shared configuration for both the live slide deck (%1$s-slides.typ) and
// the continuous handout (%1$s-handout.typ).
//
// content.typ defines its content as a function that takes title-slide/
// pause/slide/speaker-note/handout-note/two-column-slide/full-slide as
// parameters. Each entry point below supplies its own implementations:
// %1$s-slides.typ passes the real Touying building blocks (real
// pagination, animations, speaker notes); %1$s-handout.typ passes plain,
// non-paginating stand-ins so the whole thing renders as one flowing
// document instead of a slide deck.

#import \"@preview/touying:0.7.4\": *
#import \"@local/basic-theme:0.1.0\": (
  basic-theme,
  univ-logo,
  title-slide as live-title-slide,
  slide as live-slide,
  pause as live-pause,
  speaker-note as live-speaker-note,
  two-column-slide as live-two-column-slide,
  full-slide as live-full-slide,
)

// Presentation metadata, shared between the live title slide (which
// reads it via Touying's `self.info`) and the handout title \"slide\"
// (which has no Touying context and so renders it directly).
#let presentation-info = (
  title: [%2$s],
  subtitle: [],
  author: [Dr. Ridenour],
  date: datetime.today(),
  institution: [Department of Philosophy],
)

// variant: \"white\" (default), \"black\", or \"gray\".
#let project(variant: \"white\", body) = {
  show: basic-theme.with(
    aspect-ratio: \"16-9\",
    variant: variant,
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

// Handout notes never show on the live deck.
#let live-handout-note(body) = none

// -- Handout: a single flowing document, no slide pagination ---------------

// Portrait US letter, 12pt body text; no theme/pagination machinery at
// all. Level-3 headings (slide titles) are hidden here -- they're shown
// inside handout-slide-box instead, so the title ends up inside the box
// rather than as a separate heading above it. Section (level 1) and
// subsection (level 2) headings are untouched: they stay outside any
// box, same as the document title, and are numbered (1, 1.1, 1.2, 2, ...).
#let handout-project(body) = {
  set page(paper: \"us-letter\")
  set text(size: 12pt)
  set heading(numbering: \"1.1\")
  show heading.where(level: 3): none

  body
}

// The nearest level-3 heading at or before `here()`, compared by actual
// position (page, then y) rather than by page alone -- Touying's own
// `utils.display-current-heading` only compares pages, which isn't
// precise enough when several boxed slides share one handout page.
#let nearest-heading-title(level: 3) = context {
  let loc = here().position()
  let candidates = query(heading.where(level: level)).filter(h => {
    let p = h.location().position()
    p.page < loc.page or (p.page == loc.page and p.y <= loc.y)
  })
  if candidates.len() > 0 { candidates.last().body } else { none }
}

// Every \"slide\" in the handout is boxed like this, with its title (the
// nearest preceding level-3 heading) shown inside the box, so it's
// visually clear where one slide ends and the next begins in the
// flowing document. `breakable: false` keeps a slide's content from
// splitting across a page break.
#let handout-slide-box(body) = block(
  width: 100%%,
  inset: 1em,
  stroke: 0.5pt + gray,
  radius: 2pt,
  breakable: false,
  above: 1.5em,
  below: 1.5em,
  [
    #text(weight: \"bold\", size: 1.1em, nearest-heading-title())
    #v(0.8em)
    #body
  ],
)

// The document title is not a \"slide\" in the same sense as the others
// -- kept outside any box, same as section/subsection titles.
#let handout-title-slide() = align(center)[
  #text(size: 1.4em, weight: \"bold\", presentation-info.title)

  #if presentation-info.subtitle not in (none, []) {
    text(size: 1.15em, weight: \"bold\", presentation-info.subtitle)
  }

  #v(0.5em)

  #presentation-info.author

  #presentation-info.institution

  #presentation-info.date.display()
]

// No animation reveal in a flowing document: everything is simply shown.
#let handout-pause = none

// A multi-subslide callback slide becomes one block showing the final
// subslide's state.
#let handout-slide(repeat: auto, ..bodies) = handout-slide-box({
  let n = if repeat == auto { 1 } else { repeat }
  bodies
    .pos()
    .map(b => if type(b) == function { b((subslide: n)) } else { b })
    .sum(default: none)
})

// Speaker notes are presenter-only; never shown in the handout.
#let handout-speaker-note(body) = none

// A plain two-up grid; there's no pagination to preserve here.
#let handout-two-column-slide(columns: (1fr, 1fr), gutter: 2em, ..bodies) = handout-slide-box(grid(
  columns: columns,
  gutter: gutter,
  ..bodies.pos(),
))

// There's no full-bleed page in a flowing document, and a `100%%` height
// inside body would otherwise resolve against the whole rest of the
// page -- bound it to a fixed-height box instead, so the graphic shows
// inline at a sane size.
#let handout-full-slide(fill: auto, body) = handout-slide-box(
  box(width: 100%%, height: 300pt, clip: true, body),
)

// Handout notes read as ordinary body text, with no visual marker
// distinguishing them from the rest of the article.
#let handout-note(body) = body
"
          slug title))

(defun rlr/touying-content-template (title)
  "Return the contents of content.typ for a presentation titled TITLE."
  (format "// content.typ
// Slide content for %1$s, written once as a function of its building
// blocks so it can render either as live Touying slides (*-slides.typ) or
// as a flowing handout (*-handout.typ).

#let content(
  title-slide,
  pause,
  slide,
  speaker-note,
  handout-note,
  two-column-slide,
  full-slide,
) = [
  #title-slide()

  #speaker-note[
    Welcome the audience and introduce the topic.
  ]

  = First Section

  === First Slide

  #slide[
    Replace this with your content.

    #pause

    Use `#pause` for progressive reveals.
  ]

  #handout-note[
    Add reader-facing context here — it will not appear on the live
    slides, only in the handout.
  ]
]
"
          title))

(defun rlr/touying-slides-template (slug)
  "Return the contents of the live-deck entry file for SLUG."
  (format "// %1$s-slides.typ
// Entry point for the live slide deck: applies the Touying config and
// renders content.typ's content using the real Touying building blocks.

#import \"config.typ\": (
  project,
  live-title-slide,
  live-pause,
  live-slide,
  live-speaker-note,
  live-handout-note,
  live-two-column-slide,
  live-full-slide,
)
#import \"content.typ\": content

#show: project

#content(
  live-title-slide,
  live-pause,
  live-slide,
  live-speaker-note,
  live-handout-note,
  live-two-column-slide,
  live-full-slide,
)
"
          slug))

(defun rlr/touying-handout-template (slug)
  "Return the contents of the handout entry file for SLUG."
  (format "// %1$s-handout.typ
// Handout compile: same content as %1$s-slides.typ, rendered as a single
// continuous document instead of paginated slides — no page break between
// slides, animations collapsed to their final state, handout notes shown,
// and speaker notes omitted. Compile with: typst compile %1$s-handout.typ

#import \"config.typ\": (
  handout-project,
  handout-title-slide,
  handout-pause,
  handout-slide,
  handout-speaker-note,
  handout-note,
  handout-two-column-slide,
  handout-full-slide,
)
#import \"content.typ\": content

#show: handout-project

#content(
  handout-title-slide,
  handout-pause,
  handout-slide,
  handout-speaker-note,
  handout-note,
  handout-two-column-slide,
  handout-full-slide,
)
"
          slug))

;;;###autoload
(defun rlr/new-touying-presentation (title dir)
  "Scaffold a new Touying presentation called TITLE inside DIR.

Creates a subdirectory of DIR (named after a slug derived from TITLE)
containing config.typ, content.typ, and a slides/handout pair whose
filenames are prefixed with that slug, e.g. \"my-talk-slides.typ\" and
\"my-talk-handout.typ\". The slug is TITLE lower-cased, hyphenated, with
the words \"the\" and \"and\", and any two-letter-or-shorter words,
removed."
  (interactive
   (list (read-string "Presentation title: ")
         (read-directory-name "Create in directory: " default-directory)))
  (let* ((slug (rlr/touying-slugify title)))
    (when (string-empty-p slug)
      (user-error "Title \"%s\" has no usable words for a filename" title))
    (let* ((project-dir (expand-file-name slug dir))
           (config-file (expand-file-name "config.typ" project-dir))
           (content-file (expand-file-name "content.typ" project-dir))
           (slides-file (expand-file-name (concat slug "-slides.typ") project-dir))
           (handout-file (expand-file-name (concat slug "-handout.typ") project-dir)))
      (make-directory project-dir t)
      (rlr/touying--write-file config-file (rlr/touying-config-template slug title))
      (rlr/touying--write-file content-file (rlr/touying-content-template title))
      (rlr/touying--write-file slides-file (rlr/touying-slides-template slug))
      (rlr/touying--write-file handout-file (rlr/touying-handout-template slug))
      (find-file content-file)
      (message "Created Touying presentation \"%s\" in %s" title project-dir))))

(defun compile-typst-lecture ()
  "Compiles the slides.typ and handout.typ files in the directory."
  (interactive)
    (shell-command "compile-touying-deck"))

(provide 'rlr-touying-scaffold)
;;; rlr-touying-scaffold.el ends here
