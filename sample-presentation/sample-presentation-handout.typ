// sample-presentation-handout.typ
// Handout compile: same content as sample-presentation-slides.typ, rendered as a single
// continuous document instead of paginated slides — no page break between
// slides, animations collapsed to their final state, handout notes shown,
// and speaker notes omitted. Compile with: typst compile sample-presentation-handout.typ

#import "config.typ": (
  handout-project,
  handout-title-slide,
  handout-pause,
  handout-speaker-note,
  handout-note,
  handout-two-column-slide,
  handout-full-slide,
  handout-statement,
)
#import "content.typ": content

#show: handout-project

#content(
  handout-title-slide,
  handout-pause,
  handout-speaker-note,
  handout-note,
  handout-two-column-slide,
  handout-full-slide,
  handout-statement,
)
